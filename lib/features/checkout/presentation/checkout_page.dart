import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../../orders/presentation/orders_page.dart';

class CheckoutPage extends StatefulWidget {
  final int totalPrice;
  final List<CartItemModel> items;
  const CheckoutPage({super.key, required this.totalPrice, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'cash';
  String? _selectedAddressId;
  List<AddressModel> _addresses = [];
  UserModel? _user;
  bool _isLoading = true;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAndAddresses();
  }

  Future<void> _loadUserAndAddresses() async {
    final userRepo = context.read<UserRepositoryImpl>();
    final user = await userRepo.getCurrentUser();
    if (user != null) {
      final addresses = await userRepo.getAddresses(user.id);
      setState(() {
        _user = user;
        _addresses = addresses;
        _selectedAddressId = addresses.where((a) => a.isDefault).isNotEmpty ? addresses.firstWhere((a) => a.isDefault).id : (addresses.isNotEmpty ? addresses.first.id : null);
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtma berish')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info
                    Text('Shaxsiy ma\'lumotlar', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ism', prefixIcon: Icon(Icons.person_outline)), validator: AppValidators.validateName),
                    const SizedBox(height: 12),
                    TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Telefon', prefixIcon: Icon(Icons.phone_outlined), hintText: '+998 90 123 45 67'), validator: AppValidators.validatePhone),
                    const SizedBox(height: 20),

                    Text('Yetkazib berish manzili', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    if (_addresses.isNotEmpty) ...[
                      ..._addresses.map((addr) => RadioListTile<String>(
                            value: addr.id,
                            groupValue: _selectedAddressId,
                            onChanged: (v) => setState(() => _selectedAddressId = v),
                            title: Text(addr.title),
                            subtitle: Text(addr.fullAddress),
                          )),
                      const SizedBox(height: 8),
                    ],
                    TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Yangi manzil (ixtiyoriy)', prefixIcon: Icon(Icons.location_on_outlined)), validator: (v) => _addresses.isEmpty ? AppValidators.validateAddress(v) : null),
                    const SizedBox(height: 20),

                    Text('To\'lov usuli', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    RadioListTile(value: 'cash', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!), title: const Text('Naqd pul'), subtitle: const Text('Yetkazib berilganda to\'lash'), secondary: const Icon(Icons.money_rounded)),
                    RadioListTile(value: 'card', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!), title: const Text('Plastik karta'), subtitle: const Text('Test to\'lov - hozir sinov rejimida'), secondary: const Icon(Icons.credit_card_rounded)),
                    RadioListTile(value: 'payme', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!), title: const Text('Payme / Click'), subtitle: const Text('Onlayn to\'lov (test)'), secondary: const Icon(Icons.phone_android_rounded)),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Mahsulotlar (${widget.items.length})'), Text(widget.totalPrice.toPrice)]),
                          const SizedBox(height: 8),
                          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Yetkazib berish'), Text('Bepul', style: TextStyle(color: AppColors.success))]),
                          const Divider(height: 24),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Jami:', style: AppTextStyles.h3), Text(widget.totalPrice.toPrice, style: AppTextStyles.priceLarge.copyWith(color: AppColors.primary))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        child: const Text('Buyurtmani tasdiqlash'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(child: Text('Test to\'lov rejimi - real pul yechilmaydi', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight))),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure user exists
    final userRepo = context.read<UserRepositoryImpl>();
    UserModel? user = await userRepo.getCurrentUser();
    String userId;
    if (user == null) {
      userId = await userRepo.createUser(name: _nameController.text.trim(), phone: _phoneController.text.trim());
    } else {
      userId = user.id;
      // Update name/phone if changed
      if (user.name != _nameController.text.trim() || user.phone != _phoneController.text.trim()) {
        await userRepo.updateUser(user.copyWith(name: _nameController.text.trim(), phone: _phoneController.text.trim()));
      }
    }

    // Create address if provided
    String? addressId = _selectedAddressId;
    if (_addressController.text.trim().isNotEmpty) {
      final newAddr = AddressModel(id: DateTime.now().millisecondsSinceEpoch.toString(), userId: userId, title: 'Asosiy', fullAddress: _addressController.text.trim(), isDefault: _addresses.isEmpty);
      await userRepo.addAddress(newAddr);
      addressId = newAddr.id;
    }

    // Create order
    final orderRepo = context.read<OrderRepositoryImpl>();
    final orderItems = widget.items.map((e) => {'productId': e.productId, 'quantity': e.quantity, 'price': e.product?.price ?? 0}).toList();

    try {
      final orderId = await orderRepo.createOrder(userId: userId, items: orderItems, totalPrice: widget.totalPrice, addressId: addressId, paymentMethod: _paymentMethod);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buyurtma muvaffaqiyatli yaratildi!'), backgroundColor: AppColors.success));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OrdersPage()), (route) => false);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
