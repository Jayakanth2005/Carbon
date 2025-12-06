// lib/widgets/wallet_card.dart
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../theme/app_theme.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  const WalletCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: AppTheme.gradient, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            CircleAvatar(radius: 28, child: Icon(Icons.account_balance_wallet, size: 30)),
            SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Carbon Credits', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text(wallet.balance.toStringAsFixed(2), style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Withdraw'),
              style: ElevatedButton.styleFrom(foregroundColor: Colors.green, backgroundColor: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
