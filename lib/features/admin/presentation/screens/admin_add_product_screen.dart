import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons/ha_button.dart';

class AdminAddProductScreen extends ConsumerStatefulWidget {
  final String? productId;
  const AdminAddProductScreen({super.key, this.productId});

  @override
  ConsumerState<AdminAddProductScreen> createState() =>
      _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends ConsumerState<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _skuCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  String _selectedCategory = '';
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isFlashSale = false;
  bool _isLoading = false;

  final List<String> _imageUrls = [];
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Home & Kitchen',
    'Sports',
    'Beauty',
    'Toys',
    'Food & Beverage',
    'Automotive',
    'Other'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _salePriceCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productId = const Uuid().v4();
      final price = double.parse(_priceCtrl.text);
      final salePrice = _salePriceCtrl.text.isNotEmpty
          ? double.tryParse(_salePriceCtrl.text)
          : null;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .set({
        'id': productId,
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': price,
        'salePrice': salePrice,
        'stockQuantity': int.parse(_stockCtrl.text),
        'sku': _skuCtrl.text.trim().isEmpty
            ? productId.substring(0, 8).toUpperCase()
            : _skuCtrl.text.trim(),
        'images': _imageUrls,
        'categoryId': _selectedCategory.toLowerCase().replaceAll(' ', '_'),
        'category': _selectedCategory,
        'isActive': _isActive,
        'isFeatured': _isFeatured,
        'isFlashSale': _isFlashSale,
        'rating': 0.0,
        'reviewCount': 0,
        'soldCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: HAColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: HAColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addImageUrl() {
    final url = _imageUrlCtrl.text.trim();
    if (url.isNotEmpty && !_imageUrls.contains(url)) {
      setState(() {
        _imageUrls.add(url);
        _imageUrlCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Add Product',
            style: HATextStyles.h3
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Basic Info
            const _SectionHeader('Basic Information'),
            _Field(
                label: 'Product Name *',
                controller: _nameCtrl,
                hint: 'e.g. Premium Wireless Headphones',
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            _Field(
                label: 'Description *',
                controller: _descCtrl,
                hint: 'Describe the product...',
                maxLines: 4,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            _Field(
                label: 'SKU',
                controller: _skuCtrl,
                hint: 'Auto-generated if blank'),
            const SizedBox(height: 16),

            // Pricing
            const _SectionHeader('Pricing & Stock'),
            Row(children: [
              Expanded(
                  child: _Field(
                      label: 'Price *',
                      controller: _priceCtrl,
                      hint: '0.00',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      })),
              const SizedBox(width: 12),
              Expanded(
                  child: _Field(
                      label: 'Sale Price',
                      controller: _salePriceCtrl,
                      hint: 'Optional',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true))),
            ]),
            _Field(
                label: 'Stock Quantity *',
                controller: _stockCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Must be integer';
                  return null;
                }),
            const SizedBox(height: 16),

            // Category
            const _SectionHeader('Category'),
            DropdownButtonFormField<String>(
              initialValue:
                  _selectedCategory.isEmpty ? null : _selectedCategory,
              hint: const Text('Select category'),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isDark ? HAColors.darkBackground : HAColors.lightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color:
                          isDark ? HAColors.darkBorder : HAColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color:
                          isDark ? HAColors.darkBorder : HAColors.lightBorder),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v ?? ''),
            ),
            const SizedBox(height: 16),

            // Images
            const _SectionHeader('Product Images'),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _imageUrlCtrl,
                  decoration: InputDecoration(
                    hintText: 'Paste image URL...',
                    filled: true,
                    fillColor: isDark
                        ? HAColors.darkBackground
                        : HAColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: isDark
                              ? HAColors.darkBorder
                              : HAColors.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: isDark
                              ? HAColors.darkBorder
                              : HAColors.lightBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addImageUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HAColors.secondary,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ]),
            if (_imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(_imageUrls[i],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: HAColors.primary.withValues(alpha: 0.1),
                                child:
                                    const Icon(Icons.broken_image_outlined))),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageUrls.removeAt(i)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            child: const Icon(Icons.close_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Flags
            const _SectionHeader('Visibility'),
            _ToggleRow(
              label: 'Active (visible to customers)',
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            _ToggleRow(
              label: 'Featured on home screen',
              value: _isFeatured,
              onChanged: (v) => setState(() => _isFeatured = v),
            ),
            _ToggleRow(
              label: 'Include in Flash Sale',
              value: _isFlashSale,
              onChanged: (v) => setState(() => _isFlashSale = v),
            ),
            const SizedBox(height: 24),

            HAButton(
              label: _isLoading ? 'Saving...' : 'Add Product',
              onPressed: _isLoading ? null : _saveProduct,
              isLoading: _isLoading,
              leadingIcon: Icons.check_rounded,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: HATextStyles.h5.copyWith(color: HAColors.secondary)),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: HATextStyles.labelMedium),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor:
                  isDark ? HAColors.darkBackground : HAColors.lightBackground,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color:
                          isDark ? HAColors.darkBorder : HAColors.lightBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color:
                          isDark ? HAColors.darkBorder : HAColors.lightBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: HAColors.secondary, width: 2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? HAColors.darkSurface : HAColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? HAColors.darkBorder : HAColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: HATextStyles.bodyMedium),
          Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: HAColors.secondary),
        ],
      ),
    );
  }
}
