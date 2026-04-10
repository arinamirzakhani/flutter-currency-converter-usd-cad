import 'package:flutter/material.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'USD to CAD Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const CurrencyInputScreen(),
    );
  }
}

class CurrencyInputScreen extends StatefulWidget {
  const CurrencyInputScreen({super.key});

  @override
  State<CurrencyInputScreen> createState() => _CurrencyInputScreenState();
}

class _CurrencyInputScreenState extends State<CurrencyInputScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usdController = TextEditingController();
  final TextEditingController cadController = TextEditingController();

  static const double exchangeRate = 1.35; // 1 USD = 1.35 CAD

  bool isUpdating = false;
  String errorMessage = '';

  void convertFromUSD(String value) {
    if (isUpdating) return;

    setState(() {
      errorMessage = '';
    });

    if (value.trim().isEmpty) {
      isUpdating = true;
      cadController.clear();
      isUpdating = false;
      return;
    }

    final double? usd = double.tryParse(value);

    if (usd == null) {
      setState(() {
        errorMessage = 'Please enter a valid numeric USD value.';
      });
      isUpdating = true;
      cadController.clear();
      isUpdating = false;
      return;
    }

    final double cad = usd * exchangeRate;

    isUpdating = true;
    cadController.text = cad.toStringAsFixed(2);
    isUpdating = false;
  }

  void convertFromCAD(String value) {
    if (isUpdating) return;

    setState(() {
      errorMessage = '';
    });

    if (value.trim().isEmpty) {
      isUpdating = true;
      usdController.clear();
      isUpdating = false;
      return;
    }

    final double? cad = double.tryParse(value);

    if (cad == null) {
      setState(() {
        errorMessage = 'Please enter a valid numeric CAD value.';
      });
      isUpdating = true;
      usdController.clear();
      isUpdating = false;
      return;
    }

    final double usd = cad / exchangeRate;

    isUpdating = true;
    usdController.text = usd.toStringAsFixed(2);
    isUpdating = false;
  }

  void goToSummaryScreen() {
    final String usdText = usdController.text.trim();
    final String cadText = cadController.text.trim();

    if (usdText.isEmpty && cadText.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a value in either USD or CAD.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double usdValue =
        double.tryParse(usdController.text.trim().isEmpty ? '0' : usdController.text.trim()) ?? 0.0;

    final double cadValue =
        double.tryParse(cadController.text.trim().isEmpty ? '0' : cadController.text.trim()) ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversionSummaryScreen(
          usdAmount: usdValue,
          cadAmount: cadValue,
          exchangeRate: exchangeRate,
        ),
      ),
    );
  }

  String? validateCurrency(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid numeric $fieldName value';
    }

    return null;
  }

  @override
  void dispose() {
    usdController.dispose();
    cadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Input Screen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usdController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'USD',
                  hintText: 'Enter USD amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) => validateCurrency(value, 'USD'),
                onChanged: convertFromUSD,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: cadController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'CAD',
                  hintText: 'Enter CAD amount',
                  border: OutlineInputBorder(),
                  prefixText: 'C\$ ',
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                validator: (value) => validateCurrency(value, 'CAD'),
                onChanged: convertFromCAD,
              ),
              const SizedBox(height: 16),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: goToSummaryScreen,
                  child: const Text('Go to Screen 2'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversionSummaryScreen extends StatelessWidget {
  final double usdAmount;
  final double cadAmount;
  final double exchangeRate;

  const ConversionSummaryScreen({
    super.key,
    required this.usdAmount,
    required this.cadAmount,
    required this.exchangeRate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Summary Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Conversion Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'USD Amount: \$${usdAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'CAD Amount: C\$${cadAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Exchange Rate Used: 1 USD = ${exchangeRate.toStringAsFixed(2)} CAD',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Screen 1'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}