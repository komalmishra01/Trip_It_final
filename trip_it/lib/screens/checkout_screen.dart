import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/suggestion_service.dart';
import '../currency_controller.dart';

// --- NEW SCREEN: BookingConfirmedScreen (Jahan user payment ke baad aayega) ---
class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Title ko Center mein kiya
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // Back button chhupa diya, user ko seedhe home par bhejenge
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Confirmation Icon (Google Pay Blue color)
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4A8CFF),
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Aapki travel package safaltapoorvak book ho chuki hai. Kripya confirmation details ke liye apna email check karein.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Home Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A8CFF), Color(0xFF00C6FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Saare pichle screens band karke home (first route) par jaana.
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// --- END NEW SCREEN ---

// --- EXISTING CHECKOUT SCREEN (MODIFIED) ---

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> destination;
  final Map<String, dynamic> package;

  const CheckoutScreen({
    super.key,
    required this.destination,
    required this.package,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _travelDate;

  static const double _taxAndFees = 1200.0;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  double get pricePerPerson {
    final p = widget.package['price'];
    if (p is int) return p.toDouble();
    if (p is double) return p;
    return double.tryParse(p.toString()) ?? 0.0;
  }

  int get travelers {
    final peopleRange = widget.package['people'] as String? ?? '1';
    final firstNum = peopleRange.split('-').first.trim();
    return int.tryParse(firstNum) ?? 1;
  }

  double get subtotal {
    return pricePerPerson * travelers;
  }

  double get totalAmount {
    return subtotal + _taxAndFees;
  }

  // Date Picker Logic (Unmodified)
  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF4A8CFF),
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A8CFF)),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _travelDate = picked);
  }

  // Show QR Payment Dialog Logic (Unmodified)
  void _showQrPaymentDialog() {
    final String destinationName =
        widget.destination['name'] ?? 'Unknown Destination';
    final String packageName = widget.package['title'] ?? 'Unknown Package';

    debugPrint(
      'Booking Data Prepared: '
      'Destination: $destinationName, '
      'Package: $packageName, '
      'Total: ${Currency.formatINR(totalAmount)}, '
      'Traveler: ${_firstNameCtrl.text} ${_lastNameCtrl.text}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _QrPaymentBottomSheet(
          totalAmount: totalAmount,
          destination: destinationName,
          packageTitle: packageName,
        );
      },
    );
  }

  // Booking Confirmation Logic (Unmodified)
  void _confirmBooking() {
    if (!_formKey.currentState!.validate()) return;

    if (_travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a travel date to proceed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _showQrPaymentDialog();
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the CheckoutScreen build method is unchanged)
    return ValueListenableBuilder<String>(
      valueListenable: currencyController,
      builder: (context, code, _) {
        return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8), // Light gray background
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // White AppBar as suggested by image
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange, color: Colors.black),
            initialValue: code,
            onSelected: (c) => setCurrencyPersisted(c),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'INR', child: Text('₹ INR')),
              PopupMenuItem(value: 'USD', child: Text('\$ USD')),
              PopupMenuItem(value: 'GBP', child: Text('£ GBP')),
              PopupMenuItem(value: 'EUR', child: Text('€ EUR')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Personal Information Section ---
                  const _SectionHeader(
                    title: 'Personal Information',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextFormField(
                          controller: _firstNameCtrl,
                          label: 'First Name',
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter first name'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CustomTextFormField(
                          controller: _lastNameCtrl,
                          label: 'Last Name',
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter last name'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CustomTextFormField(
                    controller: _emailCtrl,
                    label: 'Email',
                    validator: (v) =>
                        (v == null || !v.contains('@') || v.length < 5)
                        ? 'Enter a valid email'
                        : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _CustomTextFormField(
                    controller: _phoneCtrl,
                    label: 'Phone number',
                    validator: (v) => (v == null || v.length < 10)
                        ? 'Enter a valid phone'
                        : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // --- 2. Travel Date Section ---
                  const _SectionHeader(
                    title: 'Travel Date',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Departure Date',
                        hintText: 'dd-mm-yyyy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(
                        _travelDate == null
                            ? 'dd-mm-yyyy'
                            : '${_travelDate!.day.toString().padLeft(2, '0')}-${_travelDate!.month.toString().padLeft(2, '0')}-${_travelDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _travelDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 3. Payment Method Section (Only Google Pay) ---
                  const _SectionHeader(
                    title: 'Payment Method',
                    icon: Icons.payment,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Google Pay Option (selected by default)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              // Placeholder for GPay logo
                              const Icon(
                                Icons.payment,
                                color: Colors.green,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Google Pay',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Pay with QR Code',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.radio_button_checked,
                                color: Color(0xFF4A8CFF),
                              ),
                            ],
                          ),
                        ),

                        // Secure QR Payment (Styled to match the image's blue block)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3F2FD), // Light blue background
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.qr_code,
                                color: Color(0xFF4A8CFF),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Secure QR Payment',
                                style: TextStyle(
                                  color: Color(0xFF4A8CFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 4. Order Summary ---
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Subtotal',
                  value: Currency.formatINR(subtotal),
                  ),
                  _SummaryRow(
                    label: 'Taxes & Fees',
                  value: Currency.formatINR(_taxAndFees),
                  ),
                  const Divider(height: 30, color: Colors.grey),
                  _SummaryRow(
                    label: 'Total',
                  value: Currency.formatINR(totalAmount),
                    isTotal: true,
                  ),
                  const SizedBox(height: 100), // Space for the bottom button
                ],
              ),
            ),
          ),

          // --- 5. Floating Bottom Button ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4A8CFF),
                      Color(0xFF00C6FF),
                    ], // Blue gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _confirmBooking, // This now opens the QR dialog
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent, // Important for gradient to show
                    shadowColor: Colors.transparent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Proceed to Checkout - ${Currency.formatINR(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

// --- Helper Widgets (Unmodified) ---

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}

class _CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _CustomTextFormField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF4A8CFF), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      validator: validator,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF4A8CFF) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// --- QR Payment Bottom Sheet Widget (MODIFIED LOGIC) ---

class _QrPaymentBottomSheet extends StatelessWidget {
  final double totalAmount;
  final String destination;
  final String packageTitle;

  const _QrPaymentBottomSheet({
    required this.totalAmount,
    required this.destination,
    required this.packageTitle,
  });

  // MODIFIED: Yeh function pehle bottom sheet ko band karta hai (pop)
  // aur phir naye screen BookingConfirmedScreen par navigate karta hai.
  void _completePayment(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final uid = user?.uid;
    final dest = SuggestionService.getDestinationByName(destination);
    final image = dest?['image'] as String? ?? '';
    final destRating = (dest?['rating'] as num?)?.toDouble();
    final booking = {
      'destination': destination,
      'packageTitle': packageTitle,
      'total': totalAmount,
      'status': 'confirmed',
      'paymentMethod': 'gpay_qr',
      if (image.isNotEmpty) 'image': image,
      if (destRating != null) 'rating': destRating,
    };
    if (uid != null) {
      FirestoreService.instance.addBooking(uid, booking).catchError((_) {});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! Navigating to confirmation...'),
        backgroundColor: const Color(0xFF4A8CFF),
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.of(context).pop();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const BookingConfirmedScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F5F8), // Background color for the sheet
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Text(
            'Scan to Pay with Google Pay',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: currencyController,
            builder: (context, _, __) {
              return Text(
                'Total Amount: ${Currency.formatINR(totalAmount)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A8CFF),
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 24),

          // QR Code Placeholder
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 80,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'QR Code for $destination',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Package: $packageTitle',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'The booking is held for 15 minutes. Complete payment now.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Pay Now Button (MODIFIED onPressed)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF4A8CFF), Color(0xFF00C6FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: ElevatedButton(
              onPressed: () => _completePayment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Pay Now & Confirm Booking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
