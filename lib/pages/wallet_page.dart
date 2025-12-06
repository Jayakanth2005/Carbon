import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/wallet_model.dart';
import '../widgets/wallet_card.dart';
import '../theme/app_theme.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late Wallet wallet;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    wallet = HiveService.getWallet();
    setState(() {});
  }

  void _addDummyCredit() async {
    await HiveService.addTransaction('Sample Credit', 1.0);
    _load();
  }

  void _addDummyDebit() async {
    await HiveService.addTransaction('Payout', -0.5);
    _load();
  }

  void _deleteTransaction(String txId, double amount) async {
    await HiveService.deleteTransaction(txId); // we need to add this in HiveService
    wallet.balance -= amount; // adjust balance
    _load();
  }

  @override
  Widget build(BuildContext context) {
    wallet = HiveService.getWallet();
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.gradient)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            WalletCard(wallet: wallet),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: wallet.transactions.length,
                itemBuilder: (context, idx) {
                  final t = wallet.transactions[idx];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        t.amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                        color: t.amount >= 0 ? Colors.green : Colors.red,
                      ),
                      title: Text(t.description),
                      subtitle: Text("Amount: ${t.amount.toStringAsFixed(2)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${t.date.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTransaction(t.id, t.amount),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            label: Text('Credit +1'),
            icon: Icon(Icons.add),
            onPressed: _addDummyCredit,
          ),
          SizedBox(height: 8),
          FloatingActionButton.extended(
            label: Text('Payout -0.5'),
            icon: Icon(Icons.remove),
            onPressed: _addDummyDebit,
          ),
        ],
      ),
    );
  }
}
