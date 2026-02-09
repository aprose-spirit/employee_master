import 'dart:ui';
import 'package:employee_master/add_employee_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopHeader(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchBar(),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _EmptyStateCard(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= BACKGROUND ================= */

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [
            Color(0xFF0A0A0F),
            Color(0xFF1A0A2E),
            Color(0xFF0A0A0F),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double left;
  final double top;
  final double opacity;
  final Color color;

  const _GlowCircle({
    required this.left,
    required this.top,
    required this.opacity,
    required this.color,
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

/* ================= HEADER ================= */

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x5B141428),
        border: Border.all(color: const Color(0x4C00D9FF), width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.0, 0.5),
                  end: const Alignment(1.0, 0.5),
                  colors: [
                    const Color(0x1900D9FF),
                    Colors.black.withOpacity(0.0),
                    const Color(0x19FF0080),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _HeaderIcon(),
                    SizedBox(width: 12),
                    Expanded(child: _HeaderTitle()),
                  ],
                ),
                const SizedBox(height: 16),
                const _HeaderActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF00D9FF), Color(0xFFFF0080)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x7F00D9FF),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x7F00D9FF),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.badge_outlined, size: 22, color: Color(0xFF0A0A0F)),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Employee Master',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.33,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '0 employees',
          style: TextStyle(
            fontSize: 14,
            height: 1.43,
            color: Colors.white.withOpacity(0.60),
          ),
        ),
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: [
        _PrimaryActionButton(
          label: 'Add Employee',
          icon: Icons.person_add_alt_1,
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => const AddEmployeeOverlay(),
            );
          },
        ),
        _OutlineActionButton(
          label: 'Export CSV',
          icon: Icons.upload_file,
          borderColor: const Color(0x7F00D9FF),
          opacity: 0.50,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export CSV clicked (TODO)')),
            );
          },
        ),
        _OutlineActionButton(
          label: 'Import CSV',
          icon: Icons.download,
          borderColor: const Color(0x7FFF0080),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import CSV clicked (TODO)')),
            );
          },
        ),
        _OutlineActionButton(
          label: 'Logout',
          icon: Icons.logout,
          borderColor: const Color(0x7F9D00FF),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ],
    );

  }
}

/* ================= SEARCH + EMPTY ================= */

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        style: const TextStyle(fontSize: 16, color: Colors.white),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0x5B141428),
          hintText: 'Search employees...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.60)),
          prefixIcon: Icon(Icons.search, size: 18, color: Colors.white.withOpacity(0.70)),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
  return Container(
     width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x5B141428),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x4C00D9FF)),
      ),
      child: Text(
        'No employees found. Add your first employee to get started.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.white.withOpacity(0.60),
        ),
      ),
    );
  }
}

/* ================= BUTTONS ================= */

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.50, 0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4C00D9FF),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x4C00D9FF),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16, color: const Color(0xFF0A0A0F)),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: 1.43,
              color: Color(0xFF0A0A0F),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color borderColor;
  final double opacity;
  final VoidCallback onPressed;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.onPressed,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        height: 36,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16, color: Colors.white),
          label: Text(label, style: const TextStyle(fontSize: 14, height: 1.43)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor, width: 1),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF0A0A0F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
