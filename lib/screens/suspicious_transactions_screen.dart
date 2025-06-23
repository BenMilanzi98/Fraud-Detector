import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';
import '../widgets/main_layout.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as app_models;
import '../models/system.dart';

class SuspiciousTransactionsScreen extends StatefulWidget {
  const SuspiciousTransactionsScreen({super.key});

  @override
  State<SuspiciousTransactionsScreen> createState() => _SuspiciousTransactionsScreenState();
}

class _SuspiciousTransactionsScreenState extends State<SuspiciousTransactionsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<app_models.Transaction> _suspiciousTransactions = [];
  List<System> _systems = [];
  List<app_models.Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'all';
  int? _selectedSystemId;
  String _searchQuery = '';
  app_models.PaymentMethod? _selectedMethod;
  app_models.TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final transactions = await _dbHelper.getAllTransactions();
      final systems = await _dbHelper.getAllSystems();
      
      if (mounted) {
        setState(() {
          _suspiciousTransactions = transactions.where((t) => t.isSuspicious).toList();
          _systems = systems;
          _filteredTransactions = _suspiciousTransactions;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading suspicious transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<app_models.Transaction> filtered = _suspiciousTransactions;

    // Period filter
    if (_selectedPeriod != 'all') {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        default:
          startDate = now;
      }
      
      filtered = filtered.where((t) => t.timestamp.isAfter(startDate)).toList();
    }

    // System filter
    if (_selectedSystemId != null) {
      filtered = filtered.where((t) => t.systemId == _selectedSystemId).toList();
    }

    // Method filter
    if (_selectedMethod != null) {
      filtered = filtered.where((t) => t.method == _selectedMethod).toList();
    }

    // Type filter
    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.transactionId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.fromNumber.contains(_searchQuery) ||
        t.toNumber.contains(_searchQuery) ||
        t.description?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
        t.suspiciousReason?.toLowerCase().contains(_searchQuery.toLowerCase()) == true
      ).toList();
    }

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Suspicious Transactions',
      currentIndex: 2,
      child: _isLoading
          ? const LoadingIndicator()
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildFilters(),
                          const SizedBox(height: 16),
                          _buildStats(),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 600,
                            child: _buildTransactionsList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.warning,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fraud Detection Alert',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor and investigate suspicious transactions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Search
          CustomTextField(
            label: 'Search suspicious transactions',
            hint: 'Search by ID, phone number, reason, or description',
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          // Filter options
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Period',
                  value: _selectedPeriod,
                  items: const [
                    {'value': 'all', 'label': 'All Time'},
                    {'value': 'day', 'label': 'Today'},
                    {'value': 'week', 'label': 'This Week'},
                    {'value': 'month', 'label': 'This Month'},
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPeriod = value ?? 'all');
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'System',
                  value: _selectedSystemId?.toString(),
                  items: [
                    {'value': null, 'label': 'All Systems'},
                    ..._systems.map((s) => {
                      'value': s.id.toString(),
                      'label': s.name,
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSystemId = value != null ? int.parse(value) : null);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Method',
                  value: _selectedMethod?.name,
                  items: [
                    {'value': null, 'label': 'All Methods'},
                    {'value': 'airtelMoney', 'label': 'Airtel Money'},
                    {'value': 'tnmMpamba', 'label': 'TNM Mpamba'},
                  ],
                  onChanged: (value) {
                    setState(() => _selectedMethod = value != null 
                        ? app_models.PaymentMethod.values.firstWhere((e) => e.name == value)
                        : null);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Type',
                  value: _selectedType?.name,
                  items: [
                    {'value': null, 'label': 'All Types'},
                    {'value': 'incoming', 'label': 'Incoming'},
                    {'value': 'outgoing', 'label': 'Outgoing'},
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value != null 
                        ? app_models.TransactionType.values.firstWhere((e) => e.name == value)
                        : null);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value']?.toString(),
                child: Text(item['label']),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final totalAmount = _filteredTransactions.fold<double>(
      0, (sum, t) => sum + t.amount);
    
    // Group by suspicious reason
    final reasonStats = <String, int>{};
    for (final transaction in _filteredTransactions) {
      final reason = transaction.suspiciousReason ?? 'Unknown';
      reasonStats[reason] = (reasonStats[reason] ?? 0) + 1;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      _filteredTransactions.length.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Suspicious Transactions'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      'MK ${NumberFormat('#,##0').format(totalAmount)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Total Amount'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      reasonStats.length.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Risk Types'),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (reasonStats.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...reasonStats.entries.map((entry) => _buildRiskItem(entry.key, entry.value)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRiskItem(String reason, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reason,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 64,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No suspicious transactions found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great! No fraud detected with current filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTransactions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return _buildSuspiciousTransactionCard(transaction);
      },
    );
  }

  Widget _buildSuspiciousTransactionCard(app_models.Transaction transaction) {
    final system = _systems.firstWhere(
      (s) => s.id == transaction.systemId,
      orElse: () => System(name: 'Unknown', description: '', apiEndpoint: '', apiKey: '', createdAt: DateTime.now()),
    );

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.formattedAmount,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'HIGH RISK',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.methodDisplayName} • ${transaction.typeDisplayName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSuspiciousDetails(transaction, system),
          const SizedBox(height: 16),
          _buildActionButtons(transaction),
        ],
      ),
    );
  }

  Widget _buildSuspiciousDetails(app_models.Transaction transaction, System system) {
    return Column(
      children: [
        _buildDetailRow('Transaction ID', transaction.transactionId),
        _buildDetailRow('From', transaction.fromNumber),
        _buildDetailRow('To', transaction.toNumber),
        _buildDetailRow('System', system.name),
        _buildDetailRow('Date', DateFormat('MMM dd, yyyy HH:mm').format(transaction.timestamp)),
        if (transaction.description != null)
          _buildDetailRow('Description', transaction.description!),
        _buildDetailRow('Suspicious Reason', transaction.suspiciousReason ?? 'Unknown', isWarning: true),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isWarning ? Colors.orange : null,
                fontWeight: isWarning ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(app_models.Transaction transaction) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Investigate',
            onPressed: () => _investigateTransaction(transaction),
            icon: Icons.search,
            backgroundColor: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Block',
            onPressed: () => _blockTransaction(transaction),
            icon: Icons.block,
            backgroundColor: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Mark Safe',
            onPressed: () => _markAsSafe(transaction),
            icon: Icons.check_circle,
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }

  void _investigateTransaction(app_models.Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Investigate Transaction'),
        content: Text('Investigation started for transaction ${transaction.transactionId}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _blockTransaction(app_models.Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Transaction'),
        content: Text('Are you sure you want to block transaction ${transaction.transactionId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction blocked successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _markAsSafe(app_models.Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Safe'),
        content: Text('Are you sure you want to mark transaction ${transaction.transactionId} as safe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction marked as safe'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Mark Safe'),
          ),
        ],
      ),
    );
  }
} 