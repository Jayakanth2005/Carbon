// lib/services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import '../models/tree_model.dart';
import '../models/complaint_model.dart';
import '../models/note_model.dart';
import '../models/wallet_model.dart';

class HiveService {
  // Box names
  static const String treesBox = 'trees';
  static const String complaintsBox = 'complaints';
  static const String notesBox = 'notes';
  static const String walletBox = 'wallet';

  /// init Hive and open boxes; call from main()
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (ensure you have run build_runner)
    Hive.registerAdapter(TreeAdapter());
    Hive.registerAdapter(ComplaintAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(WalletAdapter());
    Hive.registerAdapter(TransactionAdapter());

    // Open boxes
    await Hive.openBox<Tree>(treesBox);
    await Hive.openBox<Complaint>(complaintsBox);
    await Hive.openBox<Note>(notesBox);
    await Hive.openBox<Wallet>(walletBox);

    // Ensure wallet exists
    var wbox = Hive.box<Wallet>(walletBox);
    if (wbox.isEmpty) {
      final initial = Wallet(balance: 0.0, transactions: []);
      await wbox.put('user_wallet', initial);
    }
  }

  // ---------- Trees ----------
  static Future<void> addTree(Tree tree) async {
    final box = Hive.box<Tree>(treesBox);
    await box.put(tree.id, tree);
  }

  static List<Tree> getAllTrees() {
    final box = Hive.box<Tree>(treesBox);
    return box.values.toList();
  }

  static Future<void> deleteTree(String id) async {
    final box = Hive.box<Tree>(treesBox);
    await box.delete(id);
  }

  // ---------- Complaints ----------
  static Future<void> addComplaint(Complaint c) async {
    final box = Hive.box<Complaint>(complaintsBox);
    await box.put(c.id, c);
  }

  static List<Complaint> getAllComplaints() {
    final box = Hive.box<Complaint>(complaintsBox);
    return box.values.toList();
  }

  static Future<void> updateComplaintStatus(String id, String status) async {
    final box = Hive.box<Complaint>(complaintsBox);
    final c = box.get(id);
    if (c != null) {
      c.status = status;
      await c.save();
    }
  }

  static Future<void> deleteComplaint(String id) async {
    final box = Hive.box<Complaint>(complaintsBox);
    await box.delete(id);
  }

  // ---------- Notes ----------
  static Future<void> addNote(Note n) async {
    final box = Hive.box<Note>(notesBox);
    await box.put(n.id, n);
  }

  static List<Note> getAllNotes() {
    final box = Hive.box<Note>(notesBox);
    return box.values.toList();
  }

  static Future<void> updateNote(Note n) async {
    final box = Hive.box<Note>(notesBox);
    await box.put(n.id, n);
  }

  // ---------- Wallet ----------
static Future<void> deleteTransaction(String txId) async {
  final box = Hive.box<Wallet>(walletBox);
  final w = box.get('user_wallet')!;
  w.transactions.removeWhere((tx) => tx.id == txId); // remove transaction
  await w.save();
}


  static Future<void> deleteNote(String id) async {
    final box = Hive.box<Note>(notesBox);
    await box.delete(id);
  }

  // ---------- Wallet ----------
  static Wallet getWallet() {
    final box = Hive.box<Wallet>(walletBox);
    return box.get('user_wallet')!;
  }

  static Future<void> addTransaction(String description, double amount) async {
  final box = Hive.box<Wallet>(walletBox);
  final w = box.get('user_wallet')!;

  final tx = Transaction(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    description: description,
    amount: amount,
    date: DateTime.now(),
  );

  w.transactions.insert(0, tx); // 👈 insert Transaction object
  w.balance += amount;
  await w.save();
}


  static Future<void> setBalance(double value) async {
    final box = Hive.box<Wallet>(walletBox);
    final w = box.get('user_wallet')!;
    w.balance = value;
    await w.save();
  }

  // ---------- Sync stub ----------
  /// This is a placeholder. Replace with actual sync logic calling your REST API.
  static Future<bool> syncAll() async {
    try {
      // Example: push local trees/complaints/notes to your backend, fetch updates.
      // For now, we simulate a delay:
      await Future.delayed(Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }
}
