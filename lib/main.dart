import 'package:flutter/material.dart';

import 'db/database_helper.dart';
import 'package:flutter_application_1/money_transaction.dart';

import 'screens/add_transaction_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/overview_screen.dart';

void main() {
  runApp(const MoneyFlowApp());
}

class MoneyFlowApp extends StatelessWidget {
  const MoneyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoneyFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  List<MoneyTransaction> transactions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data =
        await DatabaseHelper.instance.getTransactions();

    if (!mounted) {
      return;
    }

    setState(() {
      transactions = data;
      isLoading = false;
    });
  }

  Future<void> _addTransaction(
    MoneyTransaction transaction,
  ) async {
    await DatabaseHelper.instance.insertTransaction(
      transaction,
    );

    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewScreen(
        transactions: transactions,
      ),

      AnalyticsScreen(
        transactions: transactions,
      ),

      AddTransactionScreen(
        onSave: _addTransaction,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyFlow'),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : screens[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Overview',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart,
            ),
            label: 'Analytics',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.add_circle_outline,
            ),
            selectedIcon: Icon(
              Icons.add_circle,
            ),
            label: 'Add',
          ),
        ],
      ),
    );
  }
}