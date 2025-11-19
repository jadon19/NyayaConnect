import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '../main.dart';
import 'dart:math';

class VerificationPage extends StatefulWidget {
  final SignupData signupData;

  const VerificationPage({super.key, required this.signupData});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  bool isLoading = false;
  bool otpSent = false;
  int resendSeconds = 30;
  bool canResend = false;
  String? phoneError;
  String? otpError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void startResendTimer() {
    _resendTimer?.cancel();
    canResend = false;
    resendSeconds = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (resendSeconds > 0) {
            resendSeconds--;
          } else {
            canResend = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> sendOTP(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      setState(() {
        phoneError = "Please enter a valid phone number";
      });
      return;
    }

    if (phoneNumber.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
      setState(() {
        phoneError = "Please enter a valid 10-digit phone number";
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      phoneError = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            await _saveUserToFirebase();
          } catch (e) {
            if (mounted) {
              setState(() => isLoading = false);
              _showError('Auto-verification failed: $e');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => isLoading = false);
            String errorMsg = "Verification failed";
            if (e.code == 'invalid-phone-number') {
              errorMsg = "Invalid phone number format";
            } else if (e.code == 'too-many-requests') {
              errorMsg = "Too many requests. Please try again later";
            } else {
              errorMsg = e.message ?? errorMsg;
            }
            setState(() => phoneError = errorMsg);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              otpSent = true;
              isLoading = false;
            });
            _animationController.forward();
            startResendTimer();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          phoneError = "Failed to send OTP: $e";
        });
      }
    }
  }

  Future<void> verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        otpError = "Please enter the OTP";
      });
      return;
    }

    if (_verificationId == null) {
      setState(() {
        otpError = "OTP not sent. Please send OTP first";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        otpError = null;
      });

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      await _saveUserToFirebase(userCredential.user);
      
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          if (e.code == 'invalid-verification-code') {
            otpError = "Invalid OTP. Please try again.";
          } else if (e.code == 'session-expired') {
            otpError = "OTP expired. Please request a new one.";
          } else {
            otpError = "Verification failed: ${e.message}";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          otpError = "Error: $e";
        });
      }
    }
  }

  String generateUserId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'USR${List.generate(6, (index) => chars[random.nextInt(chars.length)]).join()}';
  }

  // ✅ FIXED: Save user to Firestore with password and proper error handling
  Future<void> _saveUserToFirebase([User? phoneAuthUser]) async {
    if (!mounted) return;
    
    setState(() => isLoading = true);

    try {
      User? firebaseUser = phoneAuthUser ?? _auth.currentUser;
      
      // If no user exists, create one with email/password
      if (firebaseUser == null) {
        try {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: widget.signupData.email.trim(),
            password: widget.signupData.password,
          );
          firebaseUser = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            try {
              final userCredential = await _auth.signInWithEmailAndPassword(
                email: widget.signupData.email.trim(),
                password: widget.signupData.password,
              );
              firebaseUser = userCredential.user;
            } catch (signInError) {
              throw Exception('Email already in use and password incorrect');
            }
          } else {
            rethrow;
          }
        }
      } else {
        // User exists from phone auth, link email/password if not already linked
        if (firebaseUser.email == null || firebaseUser.email!.isEmpty) {
          try {
            final credential = EmailAuthProvider.credential(
              email: widget.signupData.email.trim(),
              password: widget.signupData.password,
            );
            await firebaseUser.linkWithCredential(credential);
          } catch (e) {
            debugPrint('Could not link email: $e');
          }
        }
      }

      if (firebaseUser == null) {
        throw Exception('Failed to create or retrieve user');
      }

      // Prepare user data - ✅ ADDED PASSWORD FIELD
      final userId = generateUserId();
      final selectedRole = widget.signupData.role.toString().split('.').last;

      debugPrint("🧾 User Role being saved: $selectedRole");
      debugPrint("📱 Phone number: ${_phoneController.text.trim()}");

      final userData = {
        'userId': userId,
        'name': widget.signupData.name.trim(),
        'email': widget.signupData.email.trim(),
        'phone': _phoneController.text.trim(),
        'password': widget.signupData.password, // ✅ ADDED: Save password for Firestore login
        'role': selectedRole,
        'lawyerId': selectedRole == 'lawyer' ? 'LAW${userId.substring(3, 9)}' : null,
        'judgeId': selectedRole == 'judge' ? 'JDG${userId.substring(3, 9)}' : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // ✅ Save user to Firestore 'users' collection with error handling
      try {
        await _firestore.collection('users').doc(firebaseUser.uid).set(
          userData,
          SetOptions(merge: true),
        );
        debugPrint('✅ User saved to Firestore: ${firebaseUser.uid}');
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          throw Exception('Permission denied. Please check Firestore security rules.');
        } else {
          rethrow;
        }
      }

      // Create role-specific document
      if (selectedRole == 'lawyer') {
        final lawyerId = userData['lawyerId'] as String?;
        if (lawyerId != null) {
          try {
            await _firestore.collection('lawyers').doc(lawyerId).set({
              'userId': firebaseUser.uid,
              'name': widget.signupData.name.trim(),
              'email': widget.signupData.email.trim(),
              'phone': _phoneController.text.trim(),
              'isVerified': false,
              'verificationStatus': 'not_submitted',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            debugPrint('📄 Lawyer doc created: $lawyerId');
          } on FirebaseException catch (e) {
            debugPrint('⚠️ Error creating lawyer doc: $e');
            // Continue even if lawyer doc creation fails
          }
        }
      } else if (selectedRole == 'judge') {
        final judgeId = userData['judgeId'] as String?;
        if (judgeId != null) {
          try {
            await _firestore.collection('judges').doc(judgeId).set({
              'userId': firebaseUser.uid,
              'name': widget.signupData.name.trim(),
              'email': widget.signupData.email.trim(),
              'phone': _phoneController.text.trim(),
              'isVerified': false,
              'verificationStatus': 'not_submitted',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            debugPrint('📄 Judge doc created: $judgeId');
          } on FirebaseException catch (e) {
            debugPrint('⚠️ Error creating judge doc: $e');
            // Continue even if judge doc creation fails
          }
        }
      }

      // Verify the data was saved
      final check = await _firestore.collection('users').doc(firebaseUser.uid).get();
      debugPrint("🔥 Firestore saved data: ${check.data()}");

      // Navigate to home
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RootPage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed.';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please login instead.';
      } else if (e.code == 'weak-password') {
        message = 'Please use a stronger password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      } else {
        message = e.message ?? message;
      }
      
      if (mounted) {
        setState(() => isLoading = false);
        _showError(message);
      }
    } on FirebaseException catch (e) {
      // ✅ Handle Firestore permission errors
      String message = 'Database error occurred.';
      if (e.code == 'permission-denied') {
        message = 'Permission denied. Please check your Firestore security rules.';
      } else if (e.code == 'unavailable') {
        message = 'Service temporarily unavailable. Please try again.';
      } else {
        message = e.message ?? message;
      }
      
      debugPrint('❌ Firestore error: ${e.code} - ${e.message}');
      if (mounted) {
        setState(() => isLoading = false);
        _showError(message);
      }
    } catch (e) {
      debugPrint('❌ Error saving user: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showError("Unable to save user to Firebase: $e");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: Lottie.asset(
                      'assets/verification.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: otpSent
                        ? FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildOTPCard(defaultPinTheme),
                          )
                        : _buildPhoneCard(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneCard() {
    return Center(
      child: Card(
        key: const ValueKey('phoneCard'),
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF004AAD),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Verify your account to continue!",
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 163, 157, 157),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: const Text(
                      '+91',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Enter mobile number*',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (phoneError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    phoneError!,
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_phoneController.text.trim().isEmpty) {
                            setState(() {
                              phoneError = "Enter mobile number";
                            });
                            return;
                          }
                          sendOTP(_phoneController.text.trim());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AAD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Send",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPCard(PinTheme defaultPinTheme) {
    return Center(
      child: Card(
        key: const ValueKey('otpCard'),
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Verify Account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF004AAD),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We have sent the OTP on +91${_phoneController.text}, it will auto-fill the fields.",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Pinput(
                controller: _otpController,
                length: 6,
                onCompleted: (pin) {
                  verifyOTP();
                },
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (otpError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    otpError!,
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_otpController.text.trim().isEmpty) {
                            setState(() {
                              otpError = "Enter OTP";
                            });
                            return;
                          }
                          verifyOTP();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AAD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Verify",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: (isLoading || !canResend)
                    ? null
                    : () {
                        sendOTP(_phoneController.text.trim());
                        startResendTimer();
                      },
                child: Text(
                  canResend ? "Resend" : "Resend in $resendSeconds s",
                  style: TextStyle(
                    color: (isLoading || !canResend)
                        ? Colors.grey
                        : const Color(0xFF004AAD),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}