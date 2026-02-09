import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleLogin() {
    const hardcodedUsername = 'admin';
    const hardcodedPassword = 'password';

    final u = _usernameController.text.trim();
    final p = _passwordController.text;

    if (u == hardcodedUsername && p == hardcodedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundGlow(),
          Center(
            child: _GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LogoBubble(),
                    const SizedBox(height: 32),
                    const Text(
                      'Employee Master',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your credentials to access the employee management system',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 32),

                    _LabeledField(
                      label: 'Username',
                      child: _NeonTextField(
                        controller: _usernameController,
                        hintText: 'Enter your username',
                        prefixIcon: Icons.person_outline,
                        obscureText: false,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _LabeledField(
                      label: 'Password',
                      child: _NeonTextField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _LoginButton(onPressed: _handleLogin),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= BACKGROUND ================= */

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0F), Color(0xFF1A0A2E), Color(0xFF0A0A0F)],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double left;
  final double top;
  final Color color;
  final double opacity;

  const _GlowCircle({
    required this.left,
    required this.top,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 384,
          height: 384,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/* ================= GLASS CARD ================= */

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 448,
          decoration: BoxDecoration(
            color: const Color(0x7A141428),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x4C00D9FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3300D9FF),
                blurRadius: 50,
                offset: Offset(0, 25),
                spreadRadius: -12,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/* ================= WIDGETS ================= */

class _LogoBubble extends StatelessWidget {
  const _LogoBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF00D9FF), Color(0xFFFF0080)]),
      ),
      child: const Icon(Icons.badge_outlined, size: 36),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _NeonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _NeonTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.obscureText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          filled: true,
          fillColor: const Color(0x7F141428),
          prefixIcon: Icon(prefixIcon, size: 18, color: Colors.white.withOpacity(0.7)),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x4C00D9FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00D9FF), Color(0xFFFF0080)]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: const Text('Login'),
        ),
      ),
    );
  }
}
