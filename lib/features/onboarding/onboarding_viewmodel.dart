import 'package:flutter/material.dart';

class OnboardingViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final bool isOnboardingComplete = false;

  String? selectedOption;
  bool isUrgent = false;

  void setOption(String? value) {
    selectedOption = value;
    notifyListeners();
  }

  void toggleUrgent(bool? value) {
    isUrgent = value ?? false;
    notifyListeners();
  }

  void resetForm() {
    nameController.clear();
    amountController.clear();
    selectedOption = null;
    isUrgent = false;
    notifyListeners();
  }

  bool submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      debugPrint('✅ Submitted:');
      debugPrint('Name: ${nameController.text}');
      debugPrint('Amount: ${amountController.text}');
      debugPrint('Category: $selectedOption');
      debugPrint('Urgent: $isUrgent');
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
