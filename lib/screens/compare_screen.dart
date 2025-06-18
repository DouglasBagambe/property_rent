import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../providers/compare_provider.dart';
import '../services/api_service.dart';
import '../widgets/property_card.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final compareProvider = Provider.of<CompareProvider>(context, listen: false);
      final ids = List<String>.from(compareProvider.compareList);
      final properties = <Property>[];
      for (final id in ids) {
        try {
          final property = await ApiService.getPropertyById(id);
          properties.add(property);
        } catch (e) {
          // If any property fails to load, clear the compare list and break
          await compareProvider.clearCompare();
          setState(() {
            _error = 'One or more compared properties no longer exist. Compare list has been cleared.';
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_properties.length != 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please select exactly 2 properties to compare'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              Provider.of<CompareProvider>(context, listen: false).clearCompare();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PropertyCard(propertyId: _properties[0].id),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PropertyCard(propertyId: _properties[1].id),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildComparisonSection(
                'Price',
                [
                  'UGX ${_properties[0].price.toStringAsFixed(0)}',
                  'UGX ${_properties[1].price.toStringAsFixed(0)}',
                ],
              ),
              _buildComparisonSection(
                'Location',
                [_properties[0].location, _properties[1].location],
              ),
              _buildComparisonSection(
                'Type',
                [
                  _properties[0].type.toString().split('.').last,
                  _properties[1].type.toString().split('.').last,
                ],
              ),
              _buildComparisonSection(
                'Purpose',
                [
                  _properties[0].purpose.toString().split('.').last,
                  _properties[1].purpose.toString().split('.').last,
                ],
              ),
              _buildComparisonSection(
                'Size',
                [
                  '${_properties[0].size.totalArea} sq ft',
                  '${_properties[1].size.totalArea} sq ft',
                ],
              ),
              _buildComparisonSection(
                'Bedrooms',
                [
                  _properties[0].size.bedrooms.toString(),
                  _properties[1].size.bedrooms.toString(),
                ],
              ),
              _buildComparisonSection(
                'Bathrooms',
                [
                  _properties[0].size.bathrooms.toString(),
                  _properties[1].size.bathrooms.toString(),
                ],
              ),
              _buildComparisonSection(
                'Amenities',
                [
                  _properties[0].amenities.join(', '),
                  _properties[1].amenities.join(', '),
                ],
              ),
              _buildComparisonSection(
                'Date Posted',
                [
                  _properties[0].datePosted.toString().split(' ')[0],
                  _properties[1].datePosted.toString().split(' ')[0],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonSection(String title, List<String> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Text(values[0]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Text(values[1]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 