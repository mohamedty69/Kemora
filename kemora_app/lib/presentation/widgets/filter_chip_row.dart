import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> chips;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterChipRow({
    super.key,
    required this.chips,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(chips.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  chips[index],
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
