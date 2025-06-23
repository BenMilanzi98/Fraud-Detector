import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';
import '../widgets/main_layout.dart';
import '../database/database_helper.dart';
import '../models/system.dart';
import '../models/transaction.dart' as app_models;
import '../theme/app_theme.dart';

class SystemsScreen extends StatefulWidget {
  const SystemsScreen({super.key});

  @override
  State<SystemsScreen> createState() => _SystemsScreenState();
}

class _SystemsScreenState extends State<SystemsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<System> _systems = [];
  List<app_models.Transaction> _transactions = [];
  System? _selectedSystem;
  bool _isLoading = true;
  String _selectedPeriod = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final systems = await _dbHelper.getAllSystems();
      final transactions = await _dbHelper.getAllTransactions();
      
      if (mounted) {
        setState(() {
          _systems = systems;
          _transactions = transactions;
          _selectedSystem = systems.isNotEmpty ? systems.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading systems: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<app_models.Transaction> get _filteredTransactions {
    if (_selectedSystem == null) return [];
    
    List<app_models.Transaction> filtered = _transactions
        .where((t) => t.systemId == _selectedSystem!.id)
        .toList();

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

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Systems',
      currentIndex: 5,
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
                          _buildSystemSelector(),
                          const SizedBox(height: 16),
                          if (_selectedSystem != null) ...[
                            _buildSystemOverview(),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 400, // or constraints.maxHeight * 0.5, adjust as needed
                              child: _buildSystemTransactions(),
                            ),
                          ],
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
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.dns,
              color: AppTheme.primaryPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor and manage connected financial systems',
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

  Widget _buildSystemSelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select System',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'System',
                  value: _selectedSystem?.id.toString(),
                  items: _systems.map((s) => {
                    'value': s.id.toString(),
                    'label': s.name,
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSystem = _systems.firstWhere(
                        (s) => s.id.toString() == value,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
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
            border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
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

  Widget _buildSystemOverview() {
    if (_selectedSystem == null) return const SizedBox.shrink();

    final systemTransactions = _filteredTransactions;
    final totalAmount = systemTransactions.fold<double>(
      0, (sum, t) => sum + t.amount);
    final suspiciousCount = systemTransactions.where((t) => t.isSuspicious).length;
    final incomingCount = systemTransactions.where((t) => t.type == app_models.TransactionType.incoming).length;
    final outgoingCount = systemTransactions.where((t) => t.type == app_models.TransactionType.outgoing).length;

    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'System Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSystemInfo(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      systemTransactions.length.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Total Transactions'),
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
                        color: AppTheme.primaryPurple,
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
                      suspiciousCount.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Suspicious'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      incomingCount.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Incoming'),
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
                      outgoingCount.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Outgoing'),
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
                      _selectedSystem!.isActive ? 'Active' : 'Inactive',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _selectedSystem!.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Status'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemInfo() {
    return Column(
      children: [
        _buildInfoRow('System Name', _selectedSystem!.name),
        _buildInfoRow('Description', _selectedSystem!.description),
        _buildInfoRow('API Endpoint', _selectedSystem!.apiEndpoint),
        _buildInfoRow('Status', _selectedSystem!.isActive ? 'Active' : 'Inactive'),
        _buildInfoRow('Created', DateFormat('MMM dd, yyyy').format(_selectedSystem!.createdAt)),
        if (_selectedSystem!.lastSyncAt != null)
          _buildInfoRow('Last Sync', DateFormat('MMM dd, yyyy HH:mm').format(_selectedSystem!.lastSyncAt!)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTransactions() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredTransactions.length} transactions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try selecting a different period',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(app_models.Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.isSuspicious 
                  ? Colors.orange.withValues(alpha: 0.1)
                  : AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.isSuspicious ? Icons.warning : Icons.payment,
              color: transaction.isSuspicious ? Colors.orange : AppTheme.primaryPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.formattedAmount,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (transaction.isSuspicious)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Suspicious',
                          style: TextStyle(
                            color: Colors.orange,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.fromNumber} → ${transaction.toNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MMM dd, HH:mm').format(transaction.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.transactionId,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 