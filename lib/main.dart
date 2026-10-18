import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroBank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BankApp(),
    );
  }
}

class BankUser {
  BankUser({
    required this.fullName,
    required this.email,
    required this.password,
    this.balance = 1500,
  }) : transactions = [
          BankTransaction(
            title: 'Initial deposit',
            amount: 1500,
            date: DateTime.now(),
            isIncoming: true,
          ),
        ];

  final String fullName;
  final String email;
  final String password;
  double balance;
  final List<BankTransaction> transactions;
}

class BankTransaction {
  BankTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncoming,
  });

  final String title;
  final double amount;
  final DateTime date;
  final bool isIncoming;
}

enum AuthMode { welcome, signUp, login }

class BankApp extends StatefulWidget {
  const BankApp({super.key});

  @override
  State<BankApp> createState() => _BankAppState();
}

class _BankAppState extends State<BankApp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<BankUser> _users = [];
  BankUser? _currentUser;
  AuthMode _authMode = AuthMode.welcome;
  String _selectedAction = 'Deposit';

  void _handleCreateAccount() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
      _showMessage('An account for this email already exists.');
      return;
    }

    final newUser = BankUser(
      fullName: fullName,
      email: email,
      password: password,
    );

    _users.add(newUser);
    setState(() {
      _currentUser = newUser;
      _authMode = AuthMode.welcome;
    });
    _clearAuthForm();
    _showMessage('Account created successfully.');
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final existingUser = _users.firstWhere(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
      orElse: () => BankUser(
        fullName: '',
        email: '',
        password: '',
      ),
    );

    if (existingUser.email.isEmpty || existingUser.password != password) {
      _showMessage('Incorrect email or password.');
      return;
    }

    setState(() {
      _currentUser = existingUser;
      _authMode = AuthMode.welcome;
    });
    _clearAuthForm();
    _showMessage('Welcome back!');
  }

  void _handleLogout() {
    setState(() {
      _currentUser = null;
      _authMode = AuthMode.welcome;
    });
    _clearAuthForm();
  }

  void _performTransaction() {
    if (_currentUser == null) {
      return;
    }

    final rawValue = _amountController.text.trim();
    if (rawValue.isEmpty) {
      _showMessage('Enter an amount to continue.');
      return;
    }

    final amount = double.tryParse(rawValue);
    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount greater than zero.');
      return;
    }

    if (_selectedAction == 'Withdraw' && amount > _currentUser!.balance) {
      _showMessage('Insufficient funds for this withdrawal.');
      return;
    }

    setState(() {
      if (_selectedAction == 'Deposit') {
        _currentUser!.balance += amount;
        _currentUser!.transactions.insert(
          0,
          BankTransaction(
            title: 'Deposit',
            amount: amount,
            date: DateTime.now(),
            isIncoming: true,
          ),
        );
      } else if (_selectedAction == 'Withdraw') {
        _currentUser!.balance -= amount;
        _currentUser!.transactions.insert(
          0,
          BankTransaction(
            title: 'Withdrawal',
            amount: amount,
            date: DateTime.now(),
            isIncoming: false,
          ),
        );
      } else {
        _currentUser!.balance -= amount;
        _currentUser!.transactions.insert(
          0,
          BankTransaction(
            title: 'Transfer to Aero Savings',
            amount: amount,
            date: DateTime.now(),
            isIncoming: false,
          ),
        );
      }
      _amountController.clear();
    });

    _showMessage('Transaction complete.');
  }

  void _clearAuthForm() {
    _fullNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _amountController.clear();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildWelcomeScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                'AeroBank',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Secure everyday banking made simple.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const ValueKey('welcomeCreateAccountButton'),
                  onPressed: () => setState(() => _authMode = AuthMode.signUp),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Create account'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _authMode = AuthMode.login),
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Colors.indigo),
                    SizedBox(width: 12),
                    Expanded(child: Text('Banking protection with instant card controls')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    final isSignUp = _authMode == AuthMode.signUp;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUp ? 'Create account' : 'Welcome back'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSignUp)
                  TextFormField(
                    key: const ValueKey('fullNameField'),
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter your full name' : null,
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('emailField'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Enter your email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('passwordField'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                      (value == null || value.length < 6) ? 'Use at least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const ValueKey('authSubmitButton'),
                    onPressed: isSignUp ? _handleCreateAccount : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(isSignUp ? 'Create account' : 'Login'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _authMode = AuthMode.welcome),
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final balance = _currentUser?.balance ?? 0;
    final transactions = _currentUser?.transactions ?? <BankTransaction>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _currentUser?.fullName ?? 'Customer',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your balance', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Deposit'),
                      selected: _selectedAction == 'Deposit',
                      onSelected: (_) => setState(() => _selectedAction = 'Deposit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Withdraw'),
                      selected: _selectedAction == 'Withdraw',
                      onSelected: (_) => setState(() => _selectedAction = 'Withdraw'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Transfer'),
                      selected: _selectedAction == 'Transfer',
                      onSelected: (_) => setState(() => _selectedAction = 'Transfer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _performTransaction,
                  icon: const Icon(Icons.send),
                  label: Text(_selectedAction),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text('No transactions yet.'))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final sign = transaction.isIncoming ? '+' : '-';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.isIncoming
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                child: Icon(
                                  transaction.isIncoming
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: transaction.isIncoming
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                ),
                              ),
                              title: Text(transaction.title),
                              subtitle: Text(
                                '//',
                              ),
                              trailing: Text(
                                '$sign\$${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: transaction.isIncoming ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return _buildDashboard();
    }

    return _authMode == AuthMode.welcome ? _buildWelcomeScreen() : _buildAuthForm();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
