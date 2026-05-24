import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SimpleAddTestScreen extends StatefulWidget {
  const SimpleAddTestScreen({super.key});

  @override
  State<SimpleAddTestScreen> createState() => _SimpleAddTestScreenState();
}

class _SimpleAddTestScreenState extends State<SimpleAddTestScreen> {
  final _testNameController = TextEditingController();
  final _testTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Test'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTest,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _testNameController,
                      decoration: const InputDecoration(
                        labelText: 'Test Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _testTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Test Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Test'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveTest() {
    if (_testNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a test name')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test saved successfully')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _testNameController.dispose();
    _testTypeController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
