import 'package:flutter/material.dart';

import 'package:flutter_application_1/money_transaction.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<MoneyTransaction> transactions;

  const AnalyticsScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<AnalyticsScreen> createState() {
    return _AnalyticsScreenState();
  }
}

class _AnalyticsScreenState
    extends State<AnalyticsScreen> {
  bool isWeekly = true;

  @override
  Widget build(BuildContext context) {
    final incomeData = isWeekly
        ? _getWeeklyData('income')
        : _getMonthlyData('income');

    final expenseData = isWeekly
        ? _getWeeklyData('expense')
        : _getMonthlyData('expense');

    final labels = isWeekly
        ? [
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat',
            'Sun',
          ]
        : _getMonthlyLabels();

    final categoryTotals =
        _getExpenseCategoryTotals();

    final totalCategoryExpenses =
        categoryTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Weekly / Monthly selector
          Row(
            children: [
              Expanded(
                child: _PeriodButton(
                  text: 'Weekly',
                  selected: isWeekly,

                  onPressed: () {
                    setState(() {
                      isWeekly = true;
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _PeriodButton(
                  text: 'Monthly',
                  selected: !isWeekly,

                  onPressed: () {
                    setState(() {
                      isWeekly = false;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            'Income & Expenses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 300,
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),

            child: _SimpleBarChart(
              labels: labels,
              income: incomeData,
              expenses: expenseData,
            ),
          ),

          const SizedBox(height: 15),

          const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              _LegendItem(
                color: Colors.green,
                text: 'Income',
              ),

              SizedBox(width: 25),

              _LegendItem(
                color: Colors.red,
                text: 'Expenses',
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            'Expense Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          if (totalCategoryExpenses == 0)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 30,
              ),

              child: Center(
                child: Text(
                  'No expense data yet',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...categoryTotals.entries
                .where(
                  (entry) => entry.value > 0,
                )
                .map(
                  (entry) {
                    final percentage =
                        entry.value /
                            totalCategoryExpenses;

                    return _CategoryRow(
                      name: entry.key,
                      amount: entry.value,
                      percentage: percentage,
                    );
                  },
                ),
        ],
      ),
    );
  }

  // -------------------------
  // WEEKLY DATA
  // -------------------------

  List<double> _getWeeklyData(
    String type,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // Monday of current week
    final startOfWeek = today.subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );

    final result = List<double>.filled(
      7,
      0,
    );

    for (final transaction
        in widget.transactions) {
      if (transaction.type != type) {
        continue;
      }

      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(
          Duration(days: i),
        );

        if (_isSameDay(
          transaction.date,
          day,
        )) {
          result[i] += transaction.amount;
        }
      }
    }

    return result;
  }

  // -------------------------
  // MONTHLY DATA
  // -------------------------

  List<double> _getMonthlyData(
    String type,
  ) {
    final now = DateTime.now();

    final result = List<double>.filled(
      6,
      0,
    );

    for (final transaction
        in widget.transactions) {
      if (transaction.type != type) {
        continue;
      }

      for (int i = 0; i < 6; i++) {
        final month = DateTime(
          now.year,
          now.month - 5 + i,
        );

        if (transaction.date.year ==
                month.year &&
            transaction.date.month ==
                month.month) {
          result[i] += transaction.amount;
        }
      }
    }

    return result;
  }

  List<String> _getMonthlyLabels() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final now = DateTime.now();

    return List.generate(
      6,
      (index) {
        final date = DateTime(
          now.year,
          now.month - 5 + index,
        );

        return months[
            date.month - 1];
      },
    );
  }

  // -------------------------
  // EXPENSE CATEGORIES
  // -------------------------

  Map<String, double>
      _getExpenseCategoryTotals() {
    final result = <String, double>{
      'Food': 0,
      'Transport': 0,
      'Shopping': 0,
      'Entertainment': 0,
      'Other': 0,
    };

    for (final transaction
        in widget.transactions) {
      if (transaction.type != 'expense') {
        continue;
      }

      if (result.containsKey(
        transaction.category,
      )) {
        result[transaction.category] =
            result[transaction.category]! +
                transaction.amount;
      } else {
        result['Other'] =
            result['Other']! +
                transaction.amount;
      }
    }

    return result;
  }

  bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _PeriodButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onPressed;

  const _PeriodButton({
    required this.text,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor:
            selected
                ? Colors.green
                : Colors.grey.shade200,

        foregroundColor:
            selected
                ? Colors.white
                : Colors.black,
      ),

      child: Text(text),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> income;
  final List<double> expenses;

  const _SimpleBarChart({
    required this.labels,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final allValues = [
      ...income,
      ...expenses,
    ];

    double maxValue = 1;

    if (allValues.isNotEmpty) {
      maxValue = allValues.reduce(
        (a, b) => a > b ? a : b,
      );

      if (maxValue == 0) {
        maxValue = 1;
      }
    }

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final chartHeight =
            constraints.maxHeight - 35;

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,

          children: List.generate(
            labels.length,
            (index) {
              final incomeHeight =
                  (income[index] /
                          maxValue) *
                      chartHeight;

              final expenseHeight =
                  (expenses[index] /
                          maxValue) *
                      chartHeight;

              return Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.end,

                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        crossAxisAlignment:
                            CrossAxisAlignment.end,

                        children: [
                          Container(
                            width: 10,
                            height: incomeHeight,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.green,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                5,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          Container(
                            width: 10,
                            height:
                                expenseHeight,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.red,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      labels[index],
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(text),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final double amount;
  final double percentage;

  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Text(name),

              Text(
                '₴${amount.toStringAsFixed(2)} '
                '(${(percentage * 100).toStringAsFixed(0)}%)',
              ),
            ],
          ),

          const SizedBox(height: 6),

          LinearProgressIndicator(
            value: percentage,
            minHeight: 8,

            borderRadius:
                BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}