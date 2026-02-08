import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

import 'verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:developer' as dev;
import '../../main.dart';

class SignupData {
  final String name;
  final String email;
  final String password;
  final UserRole role;

  SignupData({
    required this.name,
    required this.email,
    required this.password,
    required this.role
  });
}

String loginErrorEmail = '';
String loginErrorPassword = '';
String signupErrorName = '';
String signupErrorEmail = '';
String signupErrorPassword = '';
String otpError = '';
Color passwordHintColor = Colors.black;
bool shakePassword = false;
int resendSeconds = 30;
bool canResend = false;
Timer? _resendTimer;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

String loginError = '';
enum UserRole { client, lawyer, judge }
class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool isLoginSelected = true;
  bool isLawyer = false;
  bool isJudge=false;
  UserRole selectedRole = UserRole.client;
  bool obscurePassword = true;
  bool showForgotPasswordField = false;
  bool isLoading = false; // for showing buffer
  String? errorMessage; // kept but not shown inline anymore
  late void Function(AnimationStatus) _statusListener;
  // Controllers
  final TextEditingController loginEmail = TextEditingController();
  final TextEditingController loginPassword = TextEditingController();
  final TextEditingController signupName = TextEditingController();
  final TextEditingController signupEmail = TextEditingController();
  final TextEditingController signupPassword = TextEditingController();

  final TextEditingController otpController = TextEditingController();

  // Keys
  final GlobalKey _loginKey = GlobalKey();
  final GlobalKey _signupKey = GlobalKey();

  // Circular reveal
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  Offset _buttonCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeInOut,
    );
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _statusListener = (_) {};
  }

  @override
  void dispose() {
    loginEmail.dispose();
    loginPassword.dispose();
    signupName.dispose();
    signupEmail.dispose();
    signupPassword.dispose();
    otpController.dispose();
    _revealController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> resendOtp() async {
    dev.log("Dummy resendOtp called"); // log instead of print
    startResendTimer(); // start timer for UI
  }

  void startResendTimer() {
    canResend = false;
    resendSeconds = 30;

    _resendTimer?.cancel(); // cancel previous timer if any
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      setState(() => isLoading = true);

      // 1️⃣ Create GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // 2️⃣ Let user pick a Google account
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return; // User cancelled login
      }

      // 3️⃣ Get authentication tokens from Google
      final googleAuth = await googleUser.authentication;

      // 4️⃣ Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5️⃣ Sign in with Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      // 6️⃣ Get or Create Firestore user document
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Auto-register new Google users
        await docRef.set({
          'name': user.displayName ?? 'Unnamed User',
          'email': user.email,
          'phone': user.phoneNumber ?? '',
          'isLawyer': false,
          'lawyerId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() => isLoading = false);

      // 8️⃣ Navigate with user data
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()), // Reloads RootPage()
        (route) => false,
      );
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnack('Google Sign-In failed: $e');
    }
  }

  // Show snackbars for errors (notification-style) as requested
  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool validateLogin() {
    bool isValid = true;

    setState(() {
      if (loginEmail.text.isEmpty) {
        loginErrorEmail = "Enter email";
        isValid = false;
      } else {
        loginErrorEmail = "";
      }

      if (loginPassword.text.isEmpty) {
        loginErrorPassword = "Enter password";
        isValid = false;
      } else {
        loginErrorPassword = "";
      }
    });

    return isValid;
  }

  bool validateSignup() {
    bool isValid = true;

    setState(() {
      signupErrorName = signupName.text.isEmpty ? 'Enter name' : '';
      signupErrorEmail = '';
      signupErrorPassword = '';

      if (signupName.text.isEmpty) {
        isValid = false;
      }

      if (signupEmail.text.isEmpty) {
        signupErrorEmail = 'Enter email';
        isValid = false;
      } else if (!RegExp(
        r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(signupEmail.text.trim())) {

        signupErrorEmail = 'Enter a valid email';
        isValid = false;
      }

      final password = signupPassword.text;
      final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{8,}$');
      if (!passwordRegex.hasMatch(password)) {
        signupErrorPassword =
            'Password must be at least 8 characters, include 1 uppercase, 1 lowercase & 1 special character.';
        isValid = false;
      }
    });

    return isValid;
  }

  void toggleLawyer(bool? value) {
  setState(() {
    isLawyer = value ?? false;
    if (isLawyer) isJudge = false; // prevent both being checked
  });
}

void toggleJudge(bool? value) {
  setState(() {
    isJudge = value ?? false;
    if (isJudge) isLawyer = false; // prevent both being checked
  });
}


  void toggleAuth(bool? value) {
    setState(() {
      isLoginSelected = value ?? true;
    });
  }

  void triggerReveal({
    bool isSignup = false,
    required VoidCallback onComplete,
  }) {
    // If signup is false, validate login
    if (!isSignup && !validateLogin()) return;

    final key = isSignup ? _signupKey : _loginKey;
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final pos = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      setState(() {
        _buttonCenter = Offset(
          pos.dx + size.width / 2,
          pos.dy + size.height / 2,
        );
      });

      // Remove previous listeners to prevent multiple triggers
      _revealController.removeStatusListener(_statusListener);

      // Add a one-time listener
      _statusListener = (status) {
        if (status == AnimationStatus.completed) {
          onComplete();
        }
      };
      _revealController.addStatusListener(_statusListener);

      _revealController.forward(from: 0);
    }
  }

  // Add this at the top of your State class

  void navigateToVerification() {
  if (!validateSignup()) return;

  UserRole selectedRole;
  if (isLawyer) {
    selectedRole = UserRole.lawyer;
  } else if (isJudge) {
    selectedRole = UserRole.judge;
  } else {
    selectedRole = UserRole.client;
  }

  final data = SignupData(
    name: signupName.text.trim(),
    email: signupEmail.text.trim(),
    password: signupPassword.text.trim(),
    role: selectedRole, // pass enum
  );

  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => VerificationPage(signupData: data),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters, // new
    String? prefixText, // new
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        inputFormatters: inputFormatters, // added
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: '$hint *',
          hintStyle: const TextStyle(height: 1.2),
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          prefixText: prefixText, // added
          suffixIcon: suffix,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF004AAD), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // show a dialog with off-white background and consistent fonts
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[100], // slightly off-white
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exit App?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to exit the application?',
          style: TextStyle(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: const Text('No', style: TextStyle(fontSize: 14)),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF004AAD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: const Text('Yes', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double logoSize = 100;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ---------------- Section 1: Fixed Logo ----------------
                  SizedBox(
                    height: size.height * 0.20,
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                    ),
                  ),

                  // ---------------- Section 2: Heading + Fields ----------------
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header (Welcome / Sign Up) - small fade
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: isLoginSelected
                                ? Column(
                                    key: const ValueKey('login_header'),
                                    children: [
                                      Text(
                                        'Welcome!',
                                        style: TextStyle(
                                          fontSize: size.width * 0.065,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF004AAD),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Justice delivered digitally for users and lawyers.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: size.width * 0.03,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('signup_header'),
                                    children: [
                                      Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: size.width * 0.065,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF004AAD),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Justice delivered digitally for users and lawyers.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: size.width * 0.03,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 12),

                          // ===== EXPAND/COLLAPSE CONTENT AREA =====
                          // We use AnimatedSize + ClipRect to smoothly expand/collapse the large
                          // content block (heading -> social buttons for login, heading -> verification for signup)
                          // ===== EXPAND/COLLAPSE CONTENT AREA =====
                          ClipRect(
                            child: AnimatedSize(
                              curve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 350),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: size.width * 0.88,
                                ),
                                child: isLoginSelected
                                    ? Column(
                                        key: const ValueKey('login_form'),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,

                                        children: [
                                          _buildTextField(
                                            controller: loginEmail,
                                            hint: 'Email Address',
                                            icon: Icons.mail_outline,
                                          ),
                                          if (loginErrorEmail.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                                left: 4,
                                              ),
                                              child: Text(
                                                loginErrorEmail,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          _buildTextField(
                                            controller: loginPassword,
                                            hint: 'Password',
                                            icon: Icons.lock_outline,
                                            obscure: obscurePassword,
                                            suffix: IconButton(
                                              icon: Icon(
                                                obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  obscurePassword =
                                                      !obscurePassword;
                                                });
                                              },
                                            ),
                                          ),
                                          if (loginErrorPassword.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                                left: 4,
                                              ),
                                              child: Text(
                                                loginErrorPassword,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),

                                          const SizedBox(height: 6),

                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  showForgotPasswordField =
                                                      !showForgotPasswordField;
                                                });
                                              },
                                              child: const Text(
                                                'Forgot Password?',
                                                style: TextStyle(
                                                  color: Color(0xFF38B6FF),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // === EXPANDING FORGOT PASSWORD SECTION ===
                                          // === EXPANDING FORGOT PASSWORD SECTION ===
                                          AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: showForgotPasswordField
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 25,
                                                          vertical: 8,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        const Text(
                                                          'We have sent a confirmation/OTP mail to your registered email account',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),

                                                        // OTP input field
                                                        _buildTextField(
                                                          controller:
                                                              otpController,
                                                          hint: 'Enter OTP',
                                                          obscure: true,
                                                        ),

                                                        // Display any error or info message
                                                        if (otpError.isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 2,
                                                                  left: 4,
                                                                ),
                                                            child: Text(
                                                              otpError,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                            ),
                                                          ),

                                                        const SizedBox(
                                                          height: 4,
                                                        ),

                                                        // Resend link (dummy, just shows timer)
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              // Currently dummy: clicking does not resend email.
                                                              // After upgrade, implement actual resend logic here
                                                              resendOtp();
                                                            },
                                                            child: RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        "Didn't receive OTP? ",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        canResend
                                                                        ? "Resend"
                                                                        : "Resend in $resendSeconds s", // shows countdown
                                                                    style: TextStyle(
                                                                      color: const Color(
                                                                        0xFF38B6FF,
                                                                      ),
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 6,
                                                        ),

                                                        // Verify OTP button
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF38B6FF,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            minimumSize:
                                                                const Size(
                                                                  double
                                                                      .infinity,
                                                                  45,
                                                                ),
                                                          ),
                                                          onPressed: isLoading
                                                              ? null
                                                              : () async {
                                                                  if (loginEmail
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(() {
                                                                      otpError =
                                                                          "Enter your email";
                                                                    });
                                                                    return;
                                                                  } else {
                                                                    setState(() {
                                                                      otpError =
                                                                          '';
                                                                    });
                                                                  }

                                                                  try {
                                                                    setState(
                                                                      () => isLoading =
                                                                          true,
                                                                    );

                                                                    // --- DUMMY VERSION ---
                                                                    // Here, send verification email to user's registered email.
                                                                    // For now, we just show a message.
                                                                    otpError =
                                                                        "Verification email sent. Check your inbox.";

                                                                    // --- DUMMY NAVIGATION ---
                                                                    // After Blanza upgrade, check OTP and Firestore 'isLawyer' field:
                                                                    // final doc = await FirebaseFirestore.instance
                                                                    //     .collection('users')
                                                                    //     .doc(user.uid)
                                                                    //     .get();
                                                                    // final isLawyer = doc['isLawyer'] ?? false;
                                                                    // if (isLawyer) navigate to HomeScreenLawyer
                                                                    // else navigate to HomeScreenUser

                                                                    startResendTimer(); // start timer for resend link
                                                                    setState(
                                                                      () => isLoading =
                                                                          false,
                                                                    );
                                                                  } catch (e) {
                                                                    setState(() {
                                                                      // In real version, show actual error from backend
                                                                      otpError =
                                                                          "Failed to send verification email";
                                                                      isLoading =
                                                                          false;
                                                                    });
                                                                  }
                                                                },
                                                          child: const Text(
                                                            'Verify OTP', // button text
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        key: const ValueKey('signup_form'),
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          _buildTextField(
                                            controller: signupName,
                                            hint: 'Full Name',
                                            icon: Icons.person_outline,
                                          ),
                                          if (signupErrorName.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                                left: 4,
                                              ),
                                              child: Text(
                                                signupErrorName,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          _buildTextField(
                                            controller: signupEmail,
                                            hint: 'Email Address',
                                            icon: Icons.mail_outline,
                                          ),

                                          if (signupErrorEmail.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 2,
                                                left: 4,
                                              ),
                                              child: Text(
                                                signupErrorEmail,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          _buildTextField(
                                            controller: signupPassword,
                                            hint: 'Password',
                                            icon: Icons.lock_outline,
                                            obscure: obscurePassword,
                                            suffix: IconButton(
                                              icon: Icon(
                                                obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  obscurePassword =
                                                      !obscurePassword;
                                                });
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 4),
                                          if (signupErrorPassword.isNotEmpty)
                                            Text(
                                              signupErrorPassword,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors
                                                    .red, // turn error red
                                              ),
                                            ),

                                          const SizedBox(height: 12),
                                          Row(
                                            children: const [
                                              Expanded(child: Divider()),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                child: Text('Or'),
                                              ),
                                              Expanded(child: Divider()),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Google Button
                                              GestureDetector(
                                                onTap: () async {
                                                  // TODO: Google Sign In action
                                                  await signInWithGoogle(
                                                    context,
                                                  );
                                                },
                                                child: Container(
                                                  width: 280,
                                                  height: 45,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ), // Google red
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/google.jpg',
                                                        height: 34,
                                                      ), // your icon
                                                      SizedBox(width: 10),
                                                      Text(
                                                        "Continue with Google",
                                                        style: TextStyle(
                                                          color:
                                                              const Color.fromARGB(
                                                                255,
                                                                0,
                                                                0,
                                                                0,
                                                              ),
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                width: 10,
                                              ), // spacing between buttons
                                            ],
                                          ),

                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: const Text(
                                              'Terms & Conditions Apply.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          CheckboxListTile(
                                            activeColor: const Color(
                                              0xFF004AAD,
                                            ),
                                            checkColor: Colors.white,
                                            value: isLawyer,
                                            onChanged: toggleLawyer,
                                            title: const Text(
                                              'Register as a lawyer',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                  255,
                                                  84,
                                                  135,
                                                  202,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            contentPadding: EdgeInsets.zero,
                                            visualDensity: const VisualDensity(
                                              horizontal: -2,
                                              vertical: -4,
                                            ),
                                          ),
                                          CheckboxListTile(
                                            activeColor: const Color(
                                              0xFF004AAD,
                                            ),
                                            checkColor: Colors.white,
                                            value: isJudge,
                                            onChanged: toggleJudge,
                                            title: const Text(
                                              'Register as a Judge',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                  255,
                                                  84,
                                                  135,
                                                  202,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            contentPadding: EdgeInsets.zero,
                                            visualDensity: const VisualDensity(
                                              horizontal: -2,
                                              vertical: -4,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ---------------- Section 4: Bottom Toggle + Info ----------------
              // This section kept EXACTLY as you had it (only bottom padding reduced to 10 as requested)
              // ---------------- Section 4: Bottom Toggle + Info ----------------
              Positioned(
                bottom: 10,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---------- SIGNUP TOGGLE ----------
                    GestureDetector(
                      key: _signupKey,
                      onTap: () async {
                        if (isLoginSelected) {
                          setState(() {
                            isLoginSelected = false;
                          });
                          return; // stop here, just expand the UI
                        }
                        if (!validateSignup()) return;

                        // optional if you want reveal animation for signup

                        setState(() {}); // Ensure layout is done
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          triggerReveal(
                            isSignup: true,
                            onComplete: () {
                              // ✅ Determine actual user role from checkboxes
                              final UserRole finalRole = isLawyer
                                  ? UserRole.lawyer
                                  : isJudge
                                  ? UserRole.judge
                                  : UserRole.client;


                              // ✅ Debug print for confirmation
                              debugPrint("🧾 Selected Role before verification: $finalRole");

                              // ✅ Create SignupData with correct role
                              final data = SignupData(
                                name: signupName.text.trim(),
                                email: signupEmail.text.trim(),
                                password: signupPassword.text.trim(),
                                role: finalRole,
                              );


                              // ✅ Navigate to verification page
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      VerificationPage(signupData: data),
                                  transitionsBuilder: (_, animation, __, child) =>
                                      FadeTransition(opacity: animation, child: child),
                                ),
                              );
                            },
                          );

                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLoginSelected ? 12 : 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isLoginSelected
                              ? Colors.grey[300]
                              : const Color(0xFF004AAD),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.app_registration,
                              color: isLoginSelected
                                  ? Colors.black
                                  : Colors.white,
                              size: 20,
                            ),
                            if (!isLoginSelected)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ---------- LOGIN TOGGLE ----------
                    GestureDetector(
                      key: _loginKey,
                      onTap: () async {
                        // 1️⃣ Expand login if not selected
                        if (!isLoginSelected) {
                          setState(() {
                            isLoginSelected = true;
                          });
                          return;
                        }

                        // 2️⃣ Validate input fields
                        if (!validateLogin()) return;

                        try {
                          // 3️⃣ Try signing in with Firebase Auth
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: loginEmail.text.trim(),
                                password: loginPassword.text.trim(),
                              );

                          // ✅ If login succeeds, trigger reveal animation
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            triggerReveal(
                              isSignup: false,
                              onComplete: () {
                                // 4️⃣ Navigate to RootPage via MyApp
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyApp(),
                                  ),
                                  (route) => false,
                                );
                              },
                            );
                          });
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            if (e.code == 'user-not-found') {
                              loginErrorEmail = 'No account found';
                            } else if (e.code == 'wrong-password') {
                              loginErrorPassword = 'Invalid password';
                            } else {
                              loginErrorEmail = e.message ?? 'Login failed';
                            }
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLoginSelected ? 20 : 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isLoginSelected
                              ? const Color(0xFF004AAD)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.login,
                              color: isLoginSelected
                                  ? Colors.white
                                  : Colors.black,
                              size: 20,
                            ),
                            if (isLoginSelected)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- Info button for signup ----------
              Positioned(
                bottom: 10,
                left: 20,
                child: AnimatedOpacity(
                  opacity: isLoginSelected ? 0 : 1,
                  duration: const Duration(milliseconds: 400),
                  child: isLoginSelected
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text('Signup Info'),
                                content: const Text(
                                  'Please fill all fields carefully. Lawyer documents are required for verification.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.black87,
                              size: 24,
                            ),
                          ),
                        ),
                ),
              ),

              // ---------------- Circular reveal ----------------
              AnimatedBuilder(
                animation: _revealAnimation,
                builder: (_, child) {
                  if (_revealAnimation.value == 0) {
                    return const SizedBox.shrink();
                  }
                  final radius =
                      sqrt(pow(size.width, 2) + pow(size.height, 2)) *
                      _revealAnimation.value;
                  return ClipPath(
                    clipper: CircleClipper(
                      center: _buttonCenter,
                      radius: radius,
                    ),
                    child: Container(color: const Color(0xFF004AAD)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
