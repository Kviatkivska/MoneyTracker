import 'package:flutter/material.dart';

import 'package:flutter_application_1/money_transaction.dart';

class OverviewScreen extends StatelessWidget {
  final List<MoneyTransaction> transactions;

  const OverviewScreen({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total income
    final double income = transactions
        .where(
          (transaction) => transaction.type == 'income',
        )
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );

    // Calculate total expenses
    final double expenses = transactions
        .where(
          (transaction) => transaction.type == 'expense',
        )
        .fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );

    // Current balance
    final double balance = income - expenses;

    // Sort transactions by date
    final recentTransactions = [...transactions]
      ..sort(
        (a, b) => b.date.compareTo(a.date),
      );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '₴${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Income and expenses
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Income',
                  amount: income,
                  icon: Icons.arrow_downward,
                  iconColor: Colors.green,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _SummaryCard(
                  title: 'Expenses',
                  amount: expenses,
                  icon: Icons.arrow_upward,
                  iconColor: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 30,
              ),

              child: Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...recentTransactions
                .take(5)
                .map(
                  (transaction) => _TransactionItem(
                    icon: _getCategoryIcon(
                      transaction.category,
                    ),

                    title: transaction.note.isEmpty
                        ? transaction.category
                        : transaction.note,

                    category: transaction.category,

                    date:
                        '${transaction.date.day}.'
                        '${transaction.date.month}.'
                        '${transaction.date.year}',

                    amount: transaction.type == 'income'
                        ? transaction.amount
                        : -transaction.amount,
                  ),
                ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;

      case 'Transport':
        return Icons.directions_bus;

      case 'Shopping':
        return Icons.shopping_cart;

      case 'Entertainment':
        return Icons.movie;

      case 'Salary':
        return Icons.attach_money;

      default:
        return Icons.receipt;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: iconColor,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '₴${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String category;
  final String date;
  final double amount;

  const _TransactionItem({
    required this.icon,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = amount > 0;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          '$category • $date',
        ),

        trailing: Text(
          '${isIncome ? '+' : '-'}'
          '₴${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}