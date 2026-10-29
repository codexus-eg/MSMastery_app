import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_states.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_buttons.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_text_field.dart';

class AddressStep extends StatefulWidget {
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final VoidCallback onNext;

  const AddressStep({
    super.key,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.onNext,
  });

  @override
  State<AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<AddressStep> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedGovernorate;
  late final TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    final c = context.read<RegisterCubit>();
    _selectedGovernorate = c.government.isEmpty ? null : c.government;
    _areaController = TextEditingController(text: c.area);
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickGovernorate() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GovernoratePicker(
        items: Constants.governorates,
        selected: _selectedGovernorate,
        primaryColor: widget.primaryColor,
        fontFamily: widget.fontFamily,
        isAr: widget.isAr,
      ),
    );
    if (result != null) {
      setState(() => _selectedGovernorate = result);
      if (mounted) context.read<RegisterCubit>().setGovernment(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (_, s) => s is RegisterFieldChanged || s is RegisterInitial,
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();

        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isAr ? 'العنوان' : 'Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1a1a1a),
                  fontFamily: widget.fontFamily,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isAr
                    ? 'حدد المحافظة والمنطقة التابع لها'
                    : 'Choose your governorate and area',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                  fontFamily: widget.fontFamily,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _GovernorateField(
                value: _selectedGovernorate,
                primaryColor: widget.primaryColor,
                fontFamily: widget.fontFamily,
                isAr: widget.isAr,
                onTap: _pickGovernorate,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _areaController,
                label: widget.isAr ? 'المنطقة / الحي' : 'Area / district',
                icon: Icons.map_rounded,
                primaryColor: widget.primaryColor,
                fontFamily: widget.fontFamily,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.done,
                onChanged: cubit.setArea,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) {
                    return widget.isAr ? 'ادخل المنطقة' : 'Enter your area';
                  }
                  if (value.length < 2) {
                    return widget.isAr ? 'منطقة غير صحيحة' : 'Invalid area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              AuthSecondaryButton(
                primaryColor: widget.primaryColor,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (_selectedGovernorate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.isAr
                              ? 'برجاء اختيار المحافظة'
                              : 'Please pick a governorate',
                          style: TextStyle(fontFamily: widget.fontFamily),
                        ),
                      ),
                    );
                    return;
                  }
                  if (!_formKey.currentState!.validate()) return;
                  widget.onNext();
                },
                //  isLoading: false,
                text: widget.isAr ? 'التالي' : 'Next',
                // loadingText: '',
                icon: Icons.arrow_forward_rounded,
                fontFamily: widget.fontFamily,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GovernorateField extends StatelessWidget {
  final String? value;
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final VoidCallback onTap;

  const _GovernorateField({
    required this.value,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final hintColor = Colors.black.withValues(alpha: 0.45);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasValue
                  ? primaryColor.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.08),
              width: hasValue ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.location_city_rounded, color: primaryColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue
                      ? value!
                      : (isAr ? 'اختر المحافظة' : 'Choose governorate'),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 15,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                    color: hasValue ? const Color(0xff1a1a1a) : hintColor,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: primaryColor.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GovernoratePicker extends StatefulWidget {
  final List<String> items;
  final String? selected;
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;

  const _GovernoratePicker({
    required this.items,
    required this.selected,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
  });

  @override
  State<_GovernoratePicker> createState() => _GovernoratePickerState();
}

class _GovernoratePickerState extends State<_GovernoratePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((g) => g.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xfffafbfd),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  widget.isAr ? 'اختر المحافظة' : 'Choose governorate',
                  style: TextStyle(
                    fontFamily: widget.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff1a1a1a),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  cursorColor: widget.primaryColor,
                  style: TextStyle(fontFamily: widget.fontFamily),
                  decoration: InputDecoration(
                    hintText: widget.isAr ? 'بحث...' : 'Search...',
                    hintStyle: TextStyle(
                      fontFamily: widget.fontFamily,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: widget.primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: widget.primaryColor, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    final isSelected = item == widget.selected;
                    return Material(
                      color: isSelected
                          ? widget.primaryColor.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).pop(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? widget.primaryColor
                                  : Colors.black.withValues(alpha: 0.06),
                              width: isSelected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                color: isSelected
                                    ? widget.primaryColor
                                    : Colors.black.withValues(alpha: 0.5),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontFamily: widget.fontFamily,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? widget.primaryColor
                                        : const Color(0xff1a1a1a),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded,
                                    color: widget.primaryColor, size: 20),
                            ],
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
}
