import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/floating_menu.dart';
import 'home_viewmodel.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('HOME GENERIC EXAMPLE'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.resetForm,
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FloatingMenu(
                    destinations: [
                      MenuDestination(label: 'Home', icon: Icons.home, route: '/home'),
                      MenuDestination(
                          label: 'Budgeting', icon: Icons.wallet, route: '/budgeting'),
                      MenuDestination(
                          label: 'Participants',
                          icon: Icons.people,
                          route: '/onboarding'),
                    ],
                  ),
                  // Common widgets
                  const Text(
                    'Welcome to a sample feature page!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Example Dropdown
                  DropdownButtonFormField<String>(
                    value: viewModel.selectedOption,
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Food', 'Transport', 'Utilities']
                        .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) => viewModel.setOption(value),
                    validator: (value) =>
                    value == null ? 'Please select a category' : null,
                  ),

                  const SizedBox(height: 16),

                  // Example TextField
                  TextFormField(
                    controller: viewModel.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
                  ),

                  const SizedBox(height: 16),

                  // Example Number Field
                  TextFormField(
                    controller: viewModel.amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter amount';
                      }
                      final num? val = num.tryParse(value);
                      return val == null ? 'Invalid number' : null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Checkbox
                  CheckboxListTile(
                    title: const Text('Mark as urgent'),
                    value: viewModel.isUrgent,
                    onChanged: viewModel.toggleUrgent,
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Submit'),
                      onPressed: () {
                        if (viewModel.submitForm()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Form submitted successfully!')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
