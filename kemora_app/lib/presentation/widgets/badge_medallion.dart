import 'package:flutter/material.dart';

/// LeetCode-style badge visuals drawn entirely in Flutter (no image assets).
/// Each badge maps — by name/criteria meaning — to a distinct Material icon and
/// a two-colour gradient so earned badges read as polished medallions and
/// locked ones as muted greyscale discs.
class BadgeVisualStyle {
  final IconData icon;
  final Color colorStart;
  final Color colorEnd;

  const BadgeVisualStyle(this.icon, this.colorStart, this.colorEnd);
}

class BadgeMedallion extends StatelessWidget {
  final String name;
  final String criteria;
  final bool earned;
  final double size;

  const BadgeMedallion({
    super.key,
    required this.name,
    required this.criteria,
    required this.earned,
    this.size = 72,
  });

  /// Resolves the icon + gradient for a badge from its meaning.
  static BadgeVisualStyle styleFor(String name, String criteria) {
    final key = '$name $criteria'.toLowerCase();

    if (key.contains('first') && key.contains('post')) {
      return const BadgeVisualStyle(Icons.photo_camera_rounded, Color(0xFF7C3AED), Color(0xFFC084FC));
    }
    if (key.contains('first') && key.contains('comment')) {
      return const BadgeVisualStyle(Icons.chat_bubble_rounded, Color(0xFF2563EB), Color(0xFF60A5FA));
    }
    if (key.contains('post')) {
      // "5 Posts" and other post-count milestones — a star for active creators.
      return const BadgeVisualStyle(Icons.auto_awesome_rounded, Color(0xFFF59E0B), Color(0xFFFCD34D));
    }
    if (key.contains('comment')) {
      // "5 Comments" — a lively discussion medal.
      return const BadgeVisualStyle(Icons.forum_rounded, Color(0xFF0D9488), Color(0xFF5EEAD4));
    }
    if (key.contains('explor') || key.contains('place') || key.contains('visit')) {
      return const BadgeVisualStyle(Icons.travel_explore_rounded, Color(0xFF059669), Color(0xFF6EE7B7));
    }
    if (key.contains('review')) {
      return const BadgeVisualStyle(Icons.rate_review_rounded, Color(0xFFDB2777), Color(0xFFF9A8D4));
    }
    if (key.contains('social') || key.contains('follow') || key.contains('friend')) {
      return const BadgeVisualStyle(Icons.groups_rounded, Color(0xFF4F46E5), Color(0xFFA5B4FC));
    }
    if (key.contains('lover') || key.contains('favorite') || key.contains('favourite')) {
      return const BadgeVisualStyle(Icons.favorite_rounded, Color(0xFFE11D48), Color(0xFFFDA4AF));
    }
    // Generic achievement fallback.
    return const BadgeVisualStyle(Icons.military_tech_rounded, Color(0xFFB45309), Color(0xFFFCD34D));
  }

  @override
  Widget build(BuildContext context) {
    final style = styleFor(name, criteria);
    final iconSize = size * 0.5;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: earned
            ? LinearGradient(
                colors: [style.colorStart, style.colorEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: earned ? Colors.white : Colors.grey.shade200,
          width: size * 0.05,
        ),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: style.colorStart.withValues(alpha: 0.35),
                  blurRadius: size * 0.18,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      child: Icon(
        style.icon,
        size: iconSize,
        color: earned ? Colors.white : Colors.grey.shade600,
      ),
    );
  }
}
