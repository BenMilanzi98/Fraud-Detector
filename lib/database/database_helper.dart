import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/system.dart';
import '../models/transaction.dart' as app_models;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static sqlite.Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<sqlite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqlite.Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fraud_buster.db');
    return await sqlite.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sqlite.Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Systems table
    await db.execute('''
      CREATE TABLE systems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        api_endpoint TEXT NOT NULL,
        api_key TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        last_sync_at TEXT
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        system_id INTEGER NOT NULL,
        transaction_id TEXT NOT NULL,
        amount REAL NOT NULL,
        from_number TEXT NOT NULL,
        to_number TEXT NOT NULL,
        type TEXT NOT NULL,
        method TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'completed',
        is_suspicious INTEGER NOT NULL DEFAULT 0,
        suspicious_reason TEXT,
        timestamp TEXT NOT NULL,
        created_at TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (system_id) REFERENCES systems (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_transactions_system_id ON transactions (system_id)');
    await db.execute('CREATE INDEX idx_transactions_timestamp ON transactions (timestamp)');
    await db.execute('CREATE INDEX idx_transactions_is_suspicious ON transactions (is_suspicious)');
    await db.execute('CREATE INDEX idx_users_email ON users (email)');
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // System operations
  Future<int> insertSystem(System system) async {
    final db = await database;
    return await db.insert('systems', system.toMap());
  }

  Future<List<System>> getAllSystems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('systems');
    return List.generate(maps.length, (i) => System.fromMap(maps[i]));
  }

  Future<System?> getSystemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'systems',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return System.fromMap(maps.first);
    }
    return null;
  }

  // Transaction operations
  Future<int> insertTransaction(app_models.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<app_models.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => app_models.Transaction.fromMap(maps[i]));
  }

  Future<List<app_models.Transaction>> getTransactionsBySystem(int systemId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'system_id = ?',
      whereArgs: [systemId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => app_models.Transaction.fromMap(maps[i]));
  }

  Future<List<app_models.Transaction>> getSuspiciousTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'is_suspicious = ?',
      whereArgs: [1],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => app_models.Transaction.fromMap(maps[i]));
  }

  Future<List<app_models.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? systemId,
    bool? isSuspicious,
  }) async {
    final db = await database;
    String whereClause = 'timestamp BETWEEN ? AND ?';
    List<dynamic> whereArgs = [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ];

    if (systemId != null) {
      whereClause += ' AND system_id = ?';
      whereArgs.add(systemId);
    }

    if (isSuspicious != null) {
      whereClause += ' AND is_suspicious = ?';
      whereArgs.add(isSuspicious ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => app_models.Transaction.fromMap(maps[i]));
  }

  // Statistics
  Future<Map<String, dynamic>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
    int? systemId,
  }) async {
    final db = await database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause += ' AND timestamp BETWEEN ? AND ?';
      whereArgs.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    }

    if (systemId != null) {
      whereClause += ' AND system_id = ?';
      whereArgs.add(systemId);
    }

    // Total transactions
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE $whereClause',
      whereArgs,
    );
    final totalTransactions = totalResult.first['count'] as int;

    // Total amount
    final amountResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $whereClause',
      whereArgs,
    );
    final totalAmount = amountResult.first['total'] as double? ?? 0.0;

    // Suspicious transactions
    final suspiciousResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE $whereClause AND is_suspicious = 1',
      whereArgs,
    );
    final suspiciousTransactions = suspiciousResult.first['count'] as int;

    // Suspicious amount
    final suspiciousAmountResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $whereClause AND is_suspicious = 1',
      whereArgs,
    );
    final suspiciousAmount = suspiciousAmountResult.first['total'] as double? ?? 0.0;

    return {
      'totalTransactions': totalTransactions,
      'totalAmount': totalAmount,
      'suspiciousTransactions': suspiciousTransactions,
      'suspiciousAmount': suspiciousAmount,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
} 