import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart'; // For SignupData
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '../main.dart';

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
    super.dispose();
  }

  void startResendTimer() {
    canResend = false;
    resendSeconds = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendSeconds > 0) {
          resendSeconds--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  // Send OTP
  Future<void> sendOTP(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    setState(() {
      isLoading = true;
      phoneError = null;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        await _saveUserToFirebase();
      },
      verificationFailed: (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (verificationId, resendToken) {
        setState(() {
          _verificationId = verificationId;
          otpSent = true;
          isLoading = false;
        });
        _animationController.forward();
        startResendTimer();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Verify OTP entered manually
  Future<void> verifyOTP() async {
    if (_otpController.text.isEmpty || _verificationId == null) return;

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text,
    );

    try {
      setState(() => isLoading = true);
      await _auth.signInWithCredential(credential);
      await _saveUserToFirebase();
    } catch (e) {
      setState(() => isLoading = false);
      setState(() {
        otpError = "Invalid OTP. Try again.";
      });
    }
  }

  // Save user info to Firestore and navigate
  // Save user info to Firebase Auth & Firestore (exclude password from Firestore)
  Future<void> _saveUserToFirebase() async {
  setState(() => isLoading = true);

  try {
    // 1️⃣ Create Firebase Auth user (password hashed automatically)
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: widget.signupData.email.trim(),
      password: widget.signupData.password,
    );

    final user = userCredential.user;
    if (user == null) throw Exception('User creation failed.');

    // 2️⃣ Prepare user data map
    final userData = {
      'name': widget.signupData.name.trim(),
      'email': widget.signupData.email.trim(),
      'phone': _phoneController.text.trim(),
      'isLawyer': widget.signupData.isLawyer,
      'lawyerId': widget.signupData.isLawyer
          ? 'LAW${user.uid.substring(0, 6).toUpperCase()}'
          : null,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 3️⃣ Save user info to Firestore (no password)
    await _firestore.collection('users').doc(user.uid).set(userData);

    // 4️⃣ Ensure data sync before navigation
    await Future.delayed(const Duration(milliseconds: 300));

    // 5️⃣ Navigate to RootPage → auto-decides lawyer/user screen
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
      message = 'This email is already registered.';
    } else if (e.code == 'weak-password') {
      message = 'Please use a stronger password.';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email format.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving user: $e")),
    );
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
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

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top segment: Lottie animation (remains static)
                SizedBox(
                  height: 250,
                  child: Lottie.asset(
                    'assets/verification.json',
                    repeat: true, // loops indefinitely
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom segment: phone input / OTP card
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
    );
  }

  // New Phone input UI
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
                  // +91 prefix segment
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // slightly grey background
                      
                    ),
                    child: const Text(
                      '+91',
                      style: TextStyle(
                        color: Colors.black54, // dark grey text
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  

                  // Phone number input
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.black, fontSize: 12),
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

              // Send OTP button
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Send",
                          style: TextStyle(
                            color: Colors.white,
                          ), // <-- set text color here
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New OTP input UI
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
                "We have sent the OTP on ${_phoneController.text}, it will auto-fill the fields.",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // OTP input
              Pinput(
                controller: _otpController,
                length: 6,
                onCompleted: (pin) {
                  verifyOTP(); // automatically verifies once 6 digits are entered
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verify",style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),

              TextButton(
                onPressed: (isLoading || !canResend)
                    ? null
                    : () {
                        sendOTP(_phoneController.text.trim());
                        startResendTimer();
                      },
                child: canResend
                    ? const Text("Resend")
                    : Text("Resend in $resendSeconds s"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
