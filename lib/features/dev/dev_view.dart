import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dev_viewmodel.dart';

class DevView extends StatelessWidget {
  const DevView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DevViewModel>(
      builder: (_, vm, __) {
        return Scaffold(
          appBar: AppBar(title: const Text("Developer Console")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: vm.resetAllTables,
                      child: const Text("Reset ALL Tables"),
                    ),
                    ElevatedButton(
                      onPressed: vm.logContext,
                      child: const Text("Dump App Context"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                DropdownButton<String>(
                  hint: const Text("Select Table"),
                  value: vm.allTables.contains(vm.output)
                      ? vm.output
                      : null,
                  items: vm.allTables
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (_) {},
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: vm.allTables.length,
                    itemBuilder: (_, index) {
                      final table = vm.allTables[index];
                      return Card(
                        child: ListTile(
                          title: Text(table),
                          subtitle: const Text("Table actions"),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => vm.clearTable(table),
                                tooltip: "Clear Records",
                              ),
                              IconButton(
                                icon: const Icon(Icons.restart_alt),
                                onPressed: () => vm.resetSingleTable(table),
                                tooltip: "Drop & Recreate",
                              ),
                              IconButton(
                                icon: const Icon(Icons.list_alt),
                                onPressed: () => vm.logTable(table),
                                tooltip: "Log Contents",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        vm.output,
                        style: const TextStyle(
                            fontFamily: "monospace", fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
