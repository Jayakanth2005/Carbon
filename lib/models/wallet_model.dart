import 'package:hive/hive.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 3) // ⚠️ Use a unique typeId, don’t reuse Tree/Complaint/Note
class Wallet extends HiveObject {
  @HiveField(0)
  double balance;

  @HiveField(1)
  List<Transaction> transactions;

  Wallet({
    required this.balance,
    required this.transactions,
  });
}

@HiveType(typeId: 4) // Separate ID for Transaction class
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });
}
