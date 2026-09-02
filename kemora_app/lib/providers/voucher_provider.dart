import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/viewmodels/badge_view_model.dart';

/// Reward item available for redemption.
class RewardItem {
  final String id;
  final String title;
  final String partner;
  final int pointsCost;
  final IconData icon;

  const RewardItem({
    required this.id,
    required this.title,
    required this.partner,
    required this.pointsCost,
    required this.icon,
  });
}

/// A voucher that has been redeemed by the user.
class RedeemedVoucher {
  final String id;
  final String title;
  final String partner;
  final String code;
  final DateTime redeemedAt;
  final DateTime expiresAt;
  final IconData icon;

  const RedeemedVoucher({
    required this.id,
    required this.title,
    required this.partner,
    required this.code,
    required this.redeemedAt,
    required this.expiresAt,
    required this.icon,
  });
}

/// Available rewards catalog
const List<RewardItem> availableRewards = [
  RewardItem(id: 'r1', title: '5% Off Flights', partner: 'EgyptAir', pointsCost: 500, icon: Icons.flight),
  RewardItem(id: 'r2', title: 'Free Coffee', partner: 'Cilantro Cafe', pointsCost: 150, icon: Icons.local_cafe),
  RewardItem(id: 'r3', title: '1 Night Stay', partner: 'Marriott Mena House', pointsCost: 2000, icon: Icons.hotel),
  RewardItem(id: 'r4', title: '10% Off Dinner', partner: 'Abou El Sid', pointsCost: 300, icon: Icons.restaurant),
  RewardItem(id: 'r5', title: 'Museum Pass', partner: 'Egyptian Museum', pointsCost: 200, icon: Icons.museum),
  RewardItem(id: 'r6', title: 'Spa Session', partner: 'Old Cataract Hotel', pointsCost: 1000, icon: Icons.spa),
];

/// Manages user points and voucher redemption.
class VoucherProvider with ChangeNotifier {
  List<RedeemedVoucher> _redeemedVouchers = [];
  int _spentPoints = 0;

  List<RedeemedVoucher> get redeemedVouchers => _redeemedVouchers;

  int totalEarnedPoints(BuildContext context) {
    final badgeVM = Provider.of<BadgeViewModel>(context, listen: false);
    return badgeVM.userBadges.fold(0, (sum, ub) => sum + ub.badge.pointsReward);
  }

  int availablePoints(BuildContext context) => totalEarnedPoints(context) - _spentPoints;

  bool canAfford(BuildContext context, int cost) => availablePoints(context) >= cost;

  /// Redeems a reward: deducts points, generates a random code, stores the voucher.
  /// Returns the generated voucher or null if insufficient points.
  RedeemedVoucher? redeemVoucher(BuildContext context, RewardItem reward) {
    if (!canAfford(context, reward.pointsCost)) return null;

    _spentPoints += reward.pointsCost;

    final code = _generateCode();
    final voucher = RedeemedVoucher(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      title: reward.title,
      partner: reward.partner,
      code: code,
      redeemedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 180)),
      icon: reward.icon,
    );

    _redeemedVouchers.insert(0, voucher);
    notifyListeners();
    return voucher;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
