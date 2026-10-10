import 'package:flutter/material.dart';

import 'package:flutter_application_1/money_transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final Future<void> Function(MoneyTransaction transaction) onSave;

  const AddTransactionScreen({
    super.key,
    required this.onSave,
  });

  @override
  State<AddTransactionScreen> createState() {
    return _AddTransactionScreenState();
  }
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String selectedCategory = 'Food';

  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Salary',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Add Transaction',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // Expense / Income selector
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isExpense = true;
                    });
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isExpense
                            ? Colors.red
                            : Colors.grey.shade200,

                    foregroundColor:
                        isExpense
                            ? Colors.white
                            : Colors.black,
                  ),

                  child: const Text('Expense'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isExpense = false;
                    });
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !isExpense
                            ? Colors.green
                            : Colors.grey.shade200,

                    foregroundColor:
                        !isExpense
                            ? Colors.white
                            : Colors.black,
                  ),

                  child: const Text('Income'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Amount
          const Text(
            'Amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: amountController,

            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),

            decoration: const InputDecoration(
              prefixText: '₴ ',
              hintText: '0.00',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // Category
          const Text(
            'Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: selectedCategory,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),

            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),

            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // Date
          const Text(
            'Date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: _selectDate,

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),

                borderRadius:
                    BorderRadius.circular(4),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    '${selectedDate.day}.'
                    '${selectedDate.month}.'
                    '${selectedDate.year}',
                  ),

                  const Icon(
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Note
          const Text(
            'Note',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: noteController,

            decoration: const InputDecoration(
              hintText: 'Example: Groceries',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              onPressed: _saveTransaction,

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isExpense
                        ? Colors.red
                        : Colors.green,

                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Save Transaction',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      selectedDate = picked;
    });
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(
      amountController.text,
    );

    // Check that amount is valid
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount',
          ),
        ),
      );

      return;
    }

    // Create transaction object
    final transaction = MoneyTransaction(
      type: isExpense ? 'expense' : 'income',
      amount: amount,
      category: selectedCategory,
      date: selectedDate,
      note: noteController.text.trim(),
    );

    // Send transaction to MainScreen
    await widget.onSave(transaction);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Transaction saved!',
        ),
      ),
    );

    // Clear input fields
    amountController.clear();
    noteController.clear();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();

    super.dispose();
  }
}