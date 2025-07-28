import 'package:flutter/material.dart';
import 'package:vruksha/services/api_service.dart';
import 'package:vruksha/core/theme/app_theme.dart';

class AddAddressSheet extends StatefulWidget {
  const AddAddressSheet({super.key});

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> address = {};
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      _formKey.currentState!.save();

      final result = await _apiService.addAddress(address);

      if (!mounted) return;
      Navigator.pop(context, result['addresses'][0]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Address',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textDark),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, color: AppTheme.borderGrey),

              // Form fields
              buildField(
                'Full Address',
                'address',
                theme,
                icon: Icons.home_outlined,
              ),

              buildField(
                'City',
                'city',
                theme,
                icon: Icons.location_city_outlined,
              ),
              buildField('State', 'state', theme, icon: Icons.map_outlined),
              buildField(
                'Pincode',
                'pincode',
                theme,
                keyboard: TextInputType.number,
                icon: Icons.pin_drop_outlined,
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    disabledBackgroundColor: AppTheme.textLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            'Save Address',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    String key,
    ThemeData theme, {
    bool required = true,
    TextInputType? keyboard,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGrey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryGreen,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.orange),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon:
              icon != null ? Icon(icon, color: AppTheme.textGrey) : null,
          filled: true,
          fillColor: Colors.white,
        ),
        style: theme.textTheme.bodyLarge,
        validator: (val) {
          if (required && (val == null || val.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
        onSaved: (val) => address[key] = val ?? '',
      ),
    );
  }
}

// Add this class to the address.dart file

class EditAddressSheet extends StatefulWidget {
  final Map<String, dynamic> address;

  const EditAddressSheet({super.key, required this.address});

  @override
  State<EditAddressSheet> createState() => _EditAddressSheetState();
}

class _EditAddressSheetState extends State<EditAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> addressData = {};
  bool isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Initialize form data with existing address
    addressData['address'] = widget.address['address'] ?? '';

    addressData['city'] = widget.address['city'] ?? '';
    addressData['state'] = widget.address['state'] ?? '';
    addressData['pincode'] = widget.address['pincode'] ?? '';
  }

  Future<void> updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      _formKey.currentState!.save();

      final result = await _apiService.updateAddress(
        widget.address['_id'],
        addressData,
      );

      if (!mounted) return;
      Navigator.pop(context, result['addresses'][0]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Address',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textDark),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, color: AppTheme.borderGrey),

              // Form fields
              buildField(
                'Full Address',
                'address',
                theme,
                icon: Icons.home_outlined,
                initialValue: addressData['line1'],
              ),

              buildField(
                'City',
                'city',
                theme,
                icon: Icons.location_city_outlined,
                initialValue: addressData['city'],
              ),
              buildField(
                'State',
                'state',
                theme,
                icon: Icons.map_outlined,
                initialValue: addressData['state'],
              ),
              buildField(
                'Pincode',
                'pincode',
                theme,
                keyboard: TextInputType.number,
                icon: Icons.pin_drop_outlined,
                initialValue: addressData['pincode'],
              ),

              const SizedBox(height: 24),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    disabledBackgroundColor: AppTheme.textLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            'Update Address',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    String key,
    ThemeData theme, {
    bool required = true,
    TextInputType? keyboard,
    IconData? icon,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGrey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryGreen,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.orange),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon:
              icon != null ? Icon(icon, color: AppTheme.textGrey) : null,
          filled: true,
          fillColor: Colors.white,
        ),
        style: theme.textTheme.bodyLarge,
        validator: (val) {
          if (required && (val == null || val.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
        onSaved: (val) => addressData[key] = val ?? '',
      ),
    );
  }
}
