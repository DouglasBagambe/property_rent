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
  final _apiService = ApiService();
  bool _isLoading = false;
  List<Property> _properties = [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final compareProvider = Provider.of<CompareProvider>(context, listen: false);
    if (compareProvider.compareList.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final properties = await Future.wait(
        compareProvider.compareList.map((id) => _apiService.getPropertyById(id)),
      );
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading properties: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Properties'),
        actions: [
          Consumer<CompareProvider>(
            builder: (context, compare, child) {
              if (compare.compareList.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Comparison'),
                      content: const Text(
                        'Are you sure you want to clear all properties from comparison?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            compare.clearCompare();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CompareProvider>(
        builder: (context, compare, child) {
          if (compare.compareList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No properties to compare',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add properties to compare from the property details screen',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Cards
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      final property = _properties[index];
                      return SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: PropertyCard(property: property),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Comparison Table
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildComparisonTable(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Amenities Comparison
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amenities',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAmenitiesComparison(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(3),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          children: [
            const SizedBox.shrink(),
            ..._properties.map((property) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                property.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
        ),
        // Price
        _buildTableRow(
          'Price',
          _properties.map((p) => 'UGX ${p.price.toStringAsFixed(0)}').toList(),
        ),
        // Type
        _buildTableRow(
          'Type',
          _properties.map((p) => p.type.toString().split('.').last).toList(),
        ),
        // Purpose
        _buildTableRow(
          'Purpose',
          _properties.map((p) => p.purpose.toString().split('.').last).toList(),
        ),
        // Location
        _buildTableRow(
          'Location',
          _properties.map((p) => p.location).toList(),
        ),
        // Size
        _buildTableRow(
          'Size',
          _properties.map((p) => p.size.dimensions ?? 'N/A').toList(),
        ),
        // Bedrooms
        _buildTableRow(
          'Bedrooms',
          _properties.map((p) => p.size.bedrooms?.toString() ?? 'N/A').toList(),
        ),
        // Bathrooms
        _buildTableRow(
          'Bathrooms',
          _properties.map((p) => p.size.bathrooms?.toString() ?? 'N/A').toList(),
        ),
        // Appointment Fee
        _buildTableRow(
          'Appointment Fee',
          _properties.map((p) => 'UGX ${p.appointmentFee.toStringAsFixed(0)}').toList(),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, List<String> values) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ...values.map((value) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(value),
        )),
      ],
    );
  }

  Widget _buildAmenitiesComparison() {
    // Get all unique amenities
    final allAmenities = _properties
        .expand((p) => p.amenities)
        .toSet()
        .toList()
      ..sort();

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(3),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          children: [
            const SizedBox.shrink(),
            ..._properties.map((property) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                property.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
        ),
        // Amenities
        ...allAmenities.map((amenity) => TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                amenity,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ..._properties.map((property) => Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                property.amenities.contains(amenity)
                    ? Icons.check_circle
                    : Icons.cancel,
                color: property.amenities.contains(amenity)
                    ? Colors.green
                    : Colors.red,
              ),
            )),
          ],
        )),
      ],
    );
  }
} 