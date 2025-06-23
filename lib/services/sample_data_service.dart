import 'dart:math';
import '../database/database_helper.dart';
import '../models/system.dart';
import '../models/transaction.dart' as app_models;
import '../models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SampleDataService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static final Random _random = Random();

  static Future<void> generateSampleData() async {
    // Only generate users/systems if missing
    final existingUsers = await _dbHelper.getAllUsers();
    if (existingUsers.isEmpty) {
      await _generateSampleUsers();
    }
    final systems = await _dbHelper.getAllSystems();
    if (systems.isEmpty) {
      await _generateSampleSystems();
    }
    // Always attempt to generate missing transactions for all systems
    await _generateSampleTransactions();
  }

  static Future<void> _generateSampleUsers() async {
    final users = [
      User(
        email: 'admin@fraudbuster.com',
        passwordHash: _hashPassword('admin123'),
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        email: 'john.doe@example.com',
        passwordHash: _hashPassword('password123'),
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      User(
        email: 'jane.smith@example.com',
        passwordHash: _hashPassword('password123'),
        firstName: 'Jane',
        lastName: 'Smith',
        role: 'user',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    for (final user in users) {
      await _dbHelper.insertUser(user);
    }
  }

  static Future<void> _generateSampleSystems() async {
    final systems = [
      System(
        name: 'Old Mutual',
        description: 'Old Mutual Banking Services - Mobile Money Integration',
        apiEndpoint: 'https://api.oldmutual.com/v1/transactions',
        apiKey: 'om_api_key_${_randomString(32)}',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      System(
        name: 'NedBank',
        description: 'NedBank Digital Banking - Payment Processing System',
        apiEndpoint: 'https://api.nedbank.com/v2/payments',
        apiKey: 'nb_api_key_${_randomString(32)}',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastSyncAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      System(
        name: 'Village Bank',
        description: 'Village Bank Community Banking - Rural Finance Solutions',
        apiEndpoint: 'https://api.villagebank.com/v1/mobile-money',
        apiKey: 'vb_api_key_${_randomString(32)}',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastSyncAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    for (final system in systems) {
      await _dbHelper.insertSystem(system);
    }
  }

  static Future<void> _generateSampleTransactions() async {
    final systems = await _dbHelper.getAllSystems();
    
    for (final system in systems) {
      await _generateTransactionsForSystem(system);
    }
  }

  static Future<void> _generateTransactionsForSystem(System system) async {
    final now = DateTime.now();
    final yearAgo = now.subtract(const Duration(days: 365));
    // Get all existing transactions for this system
    final existingTx = await _dbHelper.getTransactionsBySystem(system.id!);
    final existingDates = existingTx.map((t) => DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day)).toSet();
    final allTransactions = <app_models.Transaction>[];
    int totalDays = 365;
    int totalTransactions = 0;
    // Generate missing transactions for the year
    for (int day = 0; day < totalDays; day++) {
      final date = yearAgo.add(Duration(days: day));
      if (existingDates.contains(DateTime(date.year, date.month, date.day))) continue;
      final transactionsPerDay = 10 + _random.nextInt(11);
      for (int i = 0; i < transactionsPerDay; i++) {
        final transaction = _generateRandomTransaction(system.id!, date, totalTransactions);
        allTransactions.add(transaction);
        totalTransactions++;
      }
    }
    // Mark 15% as suspicious, distributed randomly
    final fraudCount = (allTransactions.length * 0.15).round();
    final fraudIndexes = <int>{};
    while (fraudIndexes.length < fraudCount) {
      fraudIndexes.add(_random.nextInt(allTransactions.length));
    }
    for (int i = 0; i < allTransactions.length; i++) {
      if (fraudIndexes.contains(i)) {
        allTransactions[i] = allTransactions[i].copyWith(
          isSuspicious: true,
          suspiciousReason: _generateSuspiciousReason(
            allTransactions[i].amount,
            allTransactions[i].type,
          ),
        );
      }
      await _dbHelper.insertTransaction(allTransactions[i]);
    }

    // --- ADDITIONAL DATA: June 20, 2025 to December 30, 2025 ---
    final futureStart = DateTime(2025, 6, 20);
    final futureEnd = DateTime(2025, 12, 30);
    final futureDays = futureEnd.difference(futureStart).inDays + 1;
    final futureTransactions = <app_models.Transaction>[];
    int futureSeed = 1000000; // ensure unique transaction IDs
    for (int day = 0; day < futureDays; day++) {
      final date = futureStart.add(Duration(days: day));
      if (existingDates.contains(DateTime(date.year, date.month, date.day))) continue;
      final transactionsPerDay = 10 + _random.nextInt(11);
      for (int i = 0; i < transactionsPerDay; i++) {
        final transaction = _generateRandomTransaction(system.id!, date, futureSeed);
        futureTransactions.add(transaction);
        futureSeed++;
      }
    }
    // Mark 17% as suspicious in the future data
    final futureFraudCount = (futureTransactions.length * 0.17).round();
    final futureFraudIndexes = <int>{};
    while (futureFraudIndexes.length < futureFraudCount) {
      futureFraudIndexes.add(_random.nextInt(futureTransactions.length));
    }
    for (int i = 0; i < futureTransactions.length; i++) {
      if (futureFraudIndexes.contains(i)) {
        futureTransactions[i] = futureTransactions[i].copyWith(
          isSuspicious: true,
          suspiciousReason: _generateSuspiciousReason(
            futureTransactions[i].amount,
            futureTransactions[i].type,
          ),
        );
      }
      await _dbHelper.insertTransaction(futureTransactions[i]);
    }
  }

  static app_models.Transaction _generateRandomTransaction(int systemId, DateTime date, int uniqueSeed) {
    // Use uniqueSeed to help ensure uniqueness
    final amount = _generateRandomAmount(false);
    final type = _random.nextBool() ? app_models.TransactionType.incoming : app_models.TransactionType.outgoing;
    final method = _random.nextBool() ? app_models.PaymentMethod.airtelMoney : app_models.PaymentMethod.tnmMpamba;
    return app_models.Transaction(
      systemId: systemId,
      transactionId: 'TXN${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${uniqueSeed}_${_randomString(4).toUpperCase()}',
      amount: amount,
      fromNumber: _generatePhoneNumber(),
      toNumber: _generatePhoneNumber(),
      type: type,
      method: method,
      status: app_models.TransactionStatus.completed,
      isSuspicious: false, // Will be set later
      suspiciousReason: null,
      timestamp: date.add(Duration(
        hours: _random.nextInt(24),
        minutes: _random.nextInt(60),
        seconds: _random.nextInt(60),
      )),
      createdAt: date,
      description: _generateTransactionDescription(type, method, amount),
    );
  }

  static double _generateRandomAmount(bool isSuspicious) {
    if (isSuspicious) {
      // Suspicious transactions tend to be larger amounts
      return _random.nextDouble() * 50000 + 10000; // 10,000 - 60,000
    } else {
      // Normal transactions are smaller
      return _random.nextDouble() * 5000 + 100; // 100 - 5,100
    }
  }

  static String _generateSuspiciousReason(double amount, app_models.TransactionType type) {
    final reasons = [
      'Unusual transaction amount (MK ${amount.toStringAsFixed(2)})',
      'Multiple rapid transactions detected',
      'Transaction from blacklisted number',
      'Amount exceeds daily limit',
      'Suspicious transaction pattern',
      'High-risk recipient number',
      'Unusual time of transaction',
      'Transaction from new device',
    ];
    return reasons[_random.nextInt(reasons.length)];
  }

  static String _generatePhoneNumber() {
    final prefixes = ['088', '099', '077', '0888', '0999'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final number = _random.nextInt(10000000).toString().padLeft(7, '0');
    return '$prefix$number';
  }

  static String _generateTransactionDescription(
    app_models.TransactionType type,
    app_models.PaymentMethod method,
    double amount,
  ) {
    final descriptions = [
      'Mobile money transfer',
      'Payment for services',
      'Bill payment',
      'Money transfer',
      'Cash deposit',
      'Withdrawal',
      'Payment received',
      'Fund transfer',
    ];
    
    final description = descriptions[_random.nextInt(descriptions.length)];
    return '$description via ${method == app_models.PaymentMethod.airtelMoney ? 'Airtel Money' : 'TNM Mpamba'}';
  }

  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> validateUser(String email, String password) async {
    final user = await _dbHelper.getUserByEmail(email);
    if (user == null) return false;
    
    final hashedPassword = _hashPassword(password);
    return user.passwordHash == hashedPassword;
  }
} 