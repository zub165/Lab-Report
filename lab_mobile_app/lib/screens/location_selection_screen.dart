import 'package:flutter/material.dart';

class LocationSelectionScreen extends StatefulWidget {
  final String? currentLocation;
  final Function(String) onLocationSelected;

  const LocationSelectionScreen({
    Key? key,
    this.currentLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? _selectedLocation;
  final List<String> _locations = [
    'Main Branch',
    'Downtown Branch',
    'Medical Center',
    'Home Visit',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.currentLocation ?? _locations.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.location_on,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose Laboratory Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the location for your appointment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Location List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                final isSelected = _selectedLocation == location;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey[300],
                      child: Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    title: Text(
                      location,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      _getLocationDescription(location),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          )
                        : const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey,
                            size: 24,
                          ),
                    onTap: () {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedLocation != null) {
                        widget.onLocationSelected(_selectedLocation!);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Select Location',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocationDescription(String location) {
    switch (location) {
      case 'Main Branch':
        return 'Primary laboratory facility with full services';
      case 'Downtown Branch':
        return 'Convenient downtown location for quick tests';
      case 'Medical Center':
        return 'Located within the medical complex';
      case 'Home Visit':
        return 'Mobile service - we come to you';
      default:
        return 'Laboratory location';
    }
  }
}
