import 'package:vruksha/screens/order_screen.dart';
import 'package:vruksha/utils/address.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vruksha/core/theme/app_theme.dart';
import 'package:vruksha/services/api_service.dart';

// Replace the showCheckoutSheet function with this navigation function
void navigateToCheckout(BuildContext context, double totalPrice) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckoutScreen(totalPrice: totalPrice),
    ),
  );
}

// New CheckoutScreen class that replaces the bottom sheet
class CheckoutScreen extends StatefulWidget {
  final double totalPrice;
  const CheckoutScreen({Key? key, required this.totalPrice}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isRecurring = false;
  List<String> selectedDays = [];
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> addresses = [];
  String? selectedAddress;
  bool isLoadingAddresses = true;
  final ApiService _apiService = ApiService();
  
  // Replace the fetchAddresses method with this:
  Future<List<Map<String, dynamic>>> fetchAddresses() async {
    try {
      return await _apiService.getAddresses();
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  bool isPlacingOrder = false;

  Future<void> placeOrder() async {
    if (isPlacingOrder) return;

    try {
      setState(() => isPlacingOrder = true);

      if (selectedAddress == null) {
        throw Exception('Please select a delivery address');
      }

      // Base data structure
      Map<String, dynamic> data = {
        'addressId': selectedAddress,
        'isRecurring': isRecurring,
        'startDate':
            DateTime.now()
                .add(const Duration(days: 1))
                .toIso8601String()
                .split('T')[0],
      };

      if (isRecurring) {
        if (selectedDays.isEmpty) {
          throw Exception('Please select delivery days for recurring order');
        }
        if (startDate == null || endDate == null) {
          throw Exception(
            'Please select start and end dates for recurring order',
          );
        }
        data['schedule'] =
            selectedDays
                .map((day) => day.toLowerCase().substring(0, 3))
                .toList();
        data['startDate'] = startDate!.toIso8601String().split('T')[0];
        data['endDate'] = endDate!.toIso8601String().split('T')[0];
      }

      // Use the ApiService to place the order
      await _apiService.placeOrder(data);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error placing order: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isPlacingOrder = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAddresses().then((fetchedAddresses) {
      if (!mounted) return;
      setState(() {
        addresses = List<Map<String, dynamic>>.from(fetchedAddresses);
        if (addresses.isNotEmpty && selectedAddress == null) {
          selectedAddress = addresses[0]['_id'];
        }
        isLoadingAddresses = false;
      });
    });
  }

  Widget checkoutTile(
    String title,
    String value,
    Widget? trailing, {
    bool trailingBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          trailing ??
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight:
                      trailingBold ? FontWeight.bold : FontWeight.normal,
                  color:
                      trailingBold ? AppTheme.primaryGreen : AppTheme.textDark,
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: theme.textTheme.displaySmall),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 24, color: AppTheme.borderGrey),

                      checkoutTile(
                        'Total Cost',
                        '₹${widget.totalPrice.toStringAsFixed(2)}',
                        null,
                        trailingBold: true,
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery Address',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isLoadingAddresses)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen,
                            strokeWidth: 3,
                          ),
                        )
                      else if (addresses.isNotEmpty)
                        Column(
                          children: addresses.map((address) {
                            final addressId = address['_id'];
                            final isSelected = selectedAddress == addressId;
                            final addressLine = address['address'] ?? '';
                            final city = address['city'] ?? '';
                            final state = address['state'] ?? '';
                            final pincode = address['pincode'] ?? '';
                            
                            // Determine address type icon (home/work/other)
                            IconData addressIcon = Icons.home_outlined;
                            if (addressLine.toLowerCase().contains('office') || 
                                addressLine.toLowerCase().contains('work')) {
                              addressIcon = Icons.business_outlined;
                            } else if (!addressLine.toLowerCase().contains('home')) {
                              addressIcon = Icons.place_outlined;
                            }
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.lightGreen : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryGreen : AppTheme.borderGrey,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ] : null,
                              ),
                              child: RadioListTile<String>(
                                value: addressId,
                                groupValue: selectedAddress,
                                onChanged: (value) {
                                  setState(() => selectedAddress = value);
                                },
                                activeColor: AppTheme.primaryGreen,
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? AppTheme.primaryGreen 
                                            : AppTheme.backgroundGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        addressIcon,
                                        color: isSelected 
                                            ? Colors.white 
                                            : AppTheme.textGrey,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            addressLine,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$city, $state - $pincode',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, 
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundGrey,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderGrey),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 48,
                                color: AppTheme.textGrey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No addresses found',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add a delivery address to continue',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  "Add Address",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24, 
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () async {
                                  final result =
                                      await showModalBottomSheet<Map<String, String>>(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (context) => const AddAddressSheet(),
                                      );

                                  if (result != null) {
                                    final newAddresses = await fetchAddresses();
                                    setState(() {
                                      addresses = newAddresses;
                                      if (addresses.isNotEmpty) {
                                        selectedAddress = addresses.last['_id'];
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.lightGreen),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.repeat,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recurring Order',
                                  style: theme.textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            Switch(
                              value: isRecurring,
                              activeColor: AppTheme.primaryGreen,
                              onChanged:
                                  (val) => setState(() => isRecurring = val),
                            ),
                          ],
                        ),
                      ),

                      if (isRecurring) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Select Delivery Days',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ].map((day) {
                                final isSelected = selectedDays.contains(day);
                                return FilterChip(
                                  label: Text(
                                    day,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : AppTheme.textDark,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  backgroundColor: Colors.white,
                                  selectedColor: AppTheme.primaryGreen,
                                  checkmarkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? AppTheme.primaryGreen
                                              : AppTheme.borderGrey,
                                    ),
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedDays.add(day);
                                      } else {
                                        selectedDays.remove(day);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365),
                                        ),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary:
                                                        AppTheme.primaryGreen,
                                                    onPrimary: Colors.white,
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (date != null) {
                                        setState(() => startDate = date);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.borderGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            startDate?.toString().split(
                                                  ' ',
                                                )[0] ??
                                                'Select Date',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      startDate != null
                                                          ? AppTheme.textDark
                                                          : AppTheme.textGrey,
                                                ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Date',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            startDate ?? DateTime.now(),
                                        firstDate: startDate ?? DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365),
                                        ),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary:
                                                        AppTheme.primaryGreen,
                                                    onPrimary: Colors.white,
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (date != null) {
                                        setState(() => endDate = date);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.borderGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            endDate?.toString().split(' ')[0] ??
                                                'Select Date',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      endDate != null
                                                          ? AppTheme.textDark
                                                          : AppTheme.textGrey,
                                                ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Place Order button at the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      disabledBackgroundColor: AppTheme.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        selectedAddress == null || isPlacingOrder
                            ? null
                            : () async {
                              if (isRecurring && selectedDays.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please select delivery days',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              await placeOrder();
                            },
                    child:
                        isPlacingOrder
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Place Order',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
