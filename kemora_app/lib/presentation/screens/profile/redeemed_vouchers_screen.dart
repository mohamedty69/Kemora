import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../../providers/voucher_provider.dart';
import 'package:intl/intl.dart';

class RedeemedVouchersScreen extends StatelessWidget {
  const RedeemedVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vouchers = context.watch<VoucherProvider>().redeemedVouchers;

    return Scaffold(
      appBar: KemoraAppBar(
        showBack: true,
        trailing: Text('Redeemed Vouchers', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
      ),
      body: vouchers.isEmpty
          ? Center(
              child: Text(
                'No vouchers redeemed yet.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final v = vouchers[index];
                return _buildVoucherItem(
                  context,
                  v.title,
                  v.partner,
                  'Valid until ${DateFormat('MMM dd, yyyy').format(v.expiresAt)}',
                  v.icon,
                  v.code,
                );
              },
            ),
    );
  }

  Widget _buildVoucherItem(BuildContext context, String title, String subtitle, String validity, IconData icon, String code) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              title: Text(title, style: AppTypography.headlineSmall),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(code, style: AppTypography.headlineMedium.copyWith(letterSpacing: 4)),
                  ),
                  const SizedBox(height: 16),
                  Text(validity, style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleMedium),
                    Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('View Code', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
