import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'models/employee.dart';

class ViewEmployeeOverlay extends StatelessWidget {
  final Employee employee;

  const ViewEmployeeOverlay({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = _ensureQr(employee);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        // ✅ whole dialog is constrained (prevents overflow)
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: _CardShell(
          title: 'Employee Details',
          subtitle: employee.name,

          // ✅ scrollable content only
          child: _ScrollableBody(
            qrData: qrData,
            employee: employee,
          ),

          // ✅ fixed footer (not scrolling)
          footer: Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x7F00D9FF), width: 1),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0A0A0F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _ensureQr(Employee e) {
    final raw = (e.qrData).trim();
    if (raw.isNotEmpty) return raw;

    // ✅ short QR for better scanning
    return 'EMP:${e.idNumber}';
  }
}

/* ================= SCROLL BODY ================= */

class _ScrollableBody extends StatelessWidget {
  final String qrData;
  final Employee employee;

  const _ScrollableBody({
    required this.qrData,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 6),

          _SectionTitle('QR Code'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4C00D9FF), width: 1.1),
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 160,
                  gapless: true,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  qrData,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _SectionTitle('Information'),
          const SizedBox(height: 10),

          _InfoGrid(
            items: [
              _InfoItem('ID Number', employee.idNumber),
              _InfoItem('Name', employee.name),
              _InfoItem('Company', employee.company),
              _InfoItem('Position', employee.position),
              _InfoItem('Birthday', employee.birthday),
              _InfoItem('Address', employee.address),
              _InfoItem('Government Info', employee.govInfo),
              _InfoItem('Email', employee.email),
              _InfoItem('Contact Number', employee.contactNumber),
              _InfoItem('Emergency Name', employee.emergencyName),
              _InfoItem('Emergency Number', employee.emergencyNumber),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/* ================= UI HELPERS ================= */

class _CardShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget footer;

  const _CardShell({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: ShapeDecoration(
        color: const Color(0x5B141428),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0x4C00D9FF), width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
        shadows: const [
          BoxShadow(color: Color(0x1900D9FF), blurRadius: 18, offset: Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Container(
          color: const Color(0xFF0A0A0F),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(title: title, subtitle: subtitle),
              const SizedBox(height: 12),

              // ✅ takes remaining height (so scroll works)
              Expanded(child: child),

              const SizedBox(height: 12),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TopBar({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.badge_outlined, color: Color(0xFF00D9FF), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final twoCols = c.maxWidth >= 640;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((it) {
            final w = twoCols ? (c.maxWidth - 12) / 2 : c.maxWidth;
            return SizedBox(
              width: w,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x5B141428),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x4C00D9FF), width: 1.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      it.label,
                      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      it.value.trim().isEmpty ? '—' : it.value,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
