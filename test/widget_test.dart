import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/money_transaction.dart';
import 'package:flutter_application_1/screens/add_transaction_screen.dart';
import 'package:flutter_application_1/screens/analytics_screen.dart';
import 'package:flutter_application_1/screens/overview_screen.dart';

void main() {
  // ---------------------------------------------------------
  // TEST 1: Overview screen
  // ---------------------------------------------------------
//test new changes in git
  testWidgets(
    'Overview screen displays calculated income, expenses and balance',
    (WidgetTester tester) async {
      final transactions = [
        MoneyTransaction(
          type: 'income',
          amount: 1000,
          category: 'Salary',
          date: DateTime(2026, 10, 8),
          note: 'Salary',
        ),
        MoneyTransaction(
          type: 'expense',
          amount: 200,
          category: 'Food',
          date: DateTime(2026, 10, 8),
          note: 'Groceries',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverviewScreen(
              transactions: transactions,
            ),
          ),
        ),
      );

      expect(
        find.text('Overview'),
        findsOneWidget,
      );

      expect(
        find.text('€800.00'),
        findsOneWidget,
      );

      expect(
        find.text('€1000.00'),
        findsOneWidget,
      );

      expect(
        find.text('€200.00'),
        findsOneWidget,
      );

      expect(
        find.text('Salary'),
        findsOneWidget,
      );

      expect(
        find.text('Groceries'),
        findsOneWidget,
      );
    },
  );

  // ---------------------------------------------------------
  // TEST 2: Analytics screen
  // ---------------------------------------------------------

  testWidgets(
    'Analytics screen displays weekly and monthly buttons',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnalyticsScreen(
              transactions: [],
            ),
          ),
        ),
      );

      expect(
        find.text('Analytics'),
        findsOneWidget,
      );

      expect(
        find.text('Weekly'),
        findsOneWidget,
      );

      expect(
        find.text('Monthly'),
        findsOneWidget,
      );

      expect(
        find.text('Income & Expenses'),
        findsOneWidget,
      );

      expect(
        find.text('Expense Categories'),
        findsOneWidget,
      );
    },
  );

  // ---------------------------------------------------------
  // TEST 3: Add Transaction validation
  // ---------------------------------------------------------

  testWidgets(
    'Add Transaction shows error when amount is empty',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddTransactionScreen(
              onSave: (transaction) async {},
            ),
          ),
        ),
      );

      expect(
        find.text('Add Transaction'),
        findsOneWidget,
      );

      expect(
        find.text('Expense'),
        findsOneWidget,
      );

      expect(
        find.text('Income'),
        findsOneWidget,
      );

      // Press Save without entering amount
      await tester.tap(
        find.text('Save Transaction'),
      );

      await tester.pump();

      expect(
        find.text('Please enter a valid amount'),
        findsOneWidget,
      );
    },
  );
}