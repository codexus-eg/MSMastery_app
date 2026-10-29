import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color primaryColor;
  final String fontFamily;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.primaryColor,
    required this.fontFamily,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? primaryColor : Colors.black.withValues(alpha: 0.08),
          width: selected ? 1.8 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? primaryColor.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Icon(
                    icon,
                    color: selected
                        ? primaryColor
                        : Colors.black.withValues(alpha: 0.55),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? primaryColor
                        : const Color(0xff1a1a1a),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
