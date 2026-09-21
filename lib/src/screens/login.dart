import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../bloc/login/login_bloc.dart';

import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

  void _login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        // --------------------------------------------------------
        // LOGIN SUCCESS
        // --------------------------------------------------------
        if (state is LoginSuccess) {
          context.go('/fleet-mode');
        }

        // --------------------------------------------------------
        // LOGIN FAILURE
        // --------------------------------------------------------
        if (state is LoginFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xff252b33),

        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,

            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 35,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),

            child: ClipRRect(
              child: Stack(
                children: [
                  // =====================================================
                  // BACKGROUND
                  // =====================================================
                  Positioned.fill(
                    child: Image.asset(
                      'images/fleet_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // =====================================================
                  // DARK OVERLAY
                  // =====================================================
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.08),
                            Colors.black.withOpacity(0.55),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // =====================================================
                  // TRAKFLEET LOGO
                  // =====================================================
                  Positioned(top: 30, left: 35, child: Row(children: [])),

                  // =====================================================
                  // LOGIN CARD
                  // =====================================================
                  Positioned(
                    right: 55,
                    top: 0,
                    bottom: 0,

                    child: Center(
                      child: Container(
                        width: 400,

                        // Increased because Google button is added
                        height: 470,

                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 25),

                        decoration: BoxDecoration(
                          color: const Color(0xff202b39).withOpacity(0.82),

                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.04),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // =================================================
                            // LOGIN TITLE
                            // =================================================
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'icons/shortlogo_light.svg',
                                    width: 38,
                                    height: 38,
                                  ),

                                  const SizedBox(width: 10),

                                  const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Center(
                              child: Text(
                                'TrakFleet Management Portal',
                                style: TextStyle(
                                  color: Color(0xff8d98a7),
                                  fontSize: 10,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // =================================================
                            // USERNAME
                            // =================================================
                            const Text(
                              'Email',
                              style: TextStyle(
                                color: Color(0xffaeb7c2),
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 7),

                            SizedBox(
                              height: 40,

                              child: TextField(
                                controller: emailController,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),

                                decoration: InputDecoration(
                                  hintText: 'Enter your email',

                                  hintStyle: const TextStyle(
                                    color: Color(0xff697482),
                                    fontSize: 11,
                                  ),

                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    size: 17,
                                    color: Color(0xff8994a2),
                                  ),

                                  filled: true,

                                  fillColor: Colors.white.withOpacity(0.025),

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),

                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.12),
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),

                                    borderSide: const BorderSide(
                                      color: Color(0xff1597ff),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // =================================================
                            // PASSWORD
                            // =================================================
                            const Text(
                              'Password',
                              style: TextStyle(
                                color: Color(0xffaeb7c2),
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 7),

                            SizedBox(
                              height: 40,

                              child: TextField(
                                controller: passwordController,

                                obscureText: obscurePassword,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),

                                decoration: InputDecoration(
                                  hintText: 'Enter your password',

                                  hintStyle: const TextStyle(
                                    color: Color(0xff697482),
                                    fontSize: 11,
                                  ),

                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 17,
                                    color: Color(0xff8994a2),
                                  ),

                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },

                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,

                                      size: 17,

                                      color: const Color(0xff8994a2),
                                    ),
                                  ),

                                  filled: true,

                                  fillColor: Colors.white.withOpacity(0.025),

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),

                                    borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.12),
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),

                                    borderSide: const BorderSide(
                                      color: Color(0xff1597ff),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // =================================================
                            // LOGIN BUTTON
                            // =================================================
                            SizedBox(
                              width: double.infinity,
                              height: 40,

                              child: BlocBuilder<LoginBloc, LoginState>(
                                builder: (context, state) {
                                  final isLoading = state is LoginLoading;

                                  return ElevatedButton(
                                    onPressed: isLoading ? null : _login,

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff078df5),

                                      disabledBackgroundColor: const Color(
                                        0xff078df5,
                                      ).withOpacity(0.5),

                                      foregroundColor: Colors.white,

                                      elevation: 0,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                    child: isLoading
                                        ? const SizedBox(
                                            width: 17,
                                            height: 17,

                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,

                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            'Login',

                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 14),

                            // =================================================
                            // OR DIVIDER
                            // =================================================
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.12),
                                    thickness: 1,
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),

                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Color(0xff697482),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.12),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // =================================================
                            // CONTINUE WITH GOOGLE
                            // =================================================
                            SizedBox(
                              width: double.infinity,
                              height: 40,

                              child: OutlinedButton(
                                onPressed: () {
                                  // Google login will be added later
                                },

                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.025,
                                  ),

                                  foregroundColor: Colors.white,

                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.14),
                                  ),

                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    // -----------------------------------------
                                    // GOOGLE ICON
                                    // -----------------------------------------
                                    Container(
                                      width: 18,
                                      height: 18,

                                      alignment: Alignment.center,

                                      child: const Text(
                                        'G',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 9),

                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // =================================================
                            // FORGOT PASSWORD
                            // =================================================
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  // Forgot password
                                },

                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,

                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),

                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(0xff8994a2),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
