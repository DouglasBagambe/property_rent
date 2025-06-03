import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/api_service.dart';
import '../widgets/property_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];

  // Filter states
  PropertyType? _selectedType;
  PropertyPurpose? _selectedPurpose;
  RangeValues _priceRange = const RangeValues(0, 1000000000);
  bool _showFurnished = false;
  bool _showParking = false;
  bool _showSecurity = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final properties = await _apiService.getProperties();
      setState(() {
        _properties = properties;
        _filteredProperties = properties;
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

  void _applyFilters() {
    setState(() {
      _filteredProperties = _properties.where((property) {
        // Type filter
        if (_selectedType != null && property.type != _selectedType) {
          return false;
        }

        // Purpose filter
        if (_selectedPurpose != null && property.purpose != _selectedPurpose) {
          return false;
        }

        // Price range filter
        if (property.price < _priceRange.start || property.price > _priceRange.end) {
          return false;
        }

        // Amenities filters
        if (_showFurnished && !property.amenities.contains('Furnished')) {
          return false;
        }
        if (_showParking && !property.amenities.contains('Parking')) {
          return false;
        }
        if (_showSecurity && !property.amenities.contains('Security')) {
          return false;
        }

        // Search text filter
        if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          return property.title.toLowerCase().contains(searchLower) ||
              property.location.toLowerCase().contains(searchLower) ||
              property.description.toLowerCase().contains(searchLower);
        }

        return true;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = null;
                        _selectedPurpose = null;
                        _priceRange = const RangeValues(0, 1000000000);
                        _showFurnished = false;
                        _showParking = false;
                        _showSecurity = false;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Property Type
              Text(
                'Property Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PropertyType.values.map((type) {
                  return FilterChip(
                    label: Text(type.toString().split('.').last),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = selected ? type : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Property Purpose
              Text(
                'Purpose',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PropertyPurpose.values.map((purpose) {
                  return FilterChip(
                    label: Text(purpose.toString().split('.').last),
                    selected: _selectedPurpose == purpose,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPurpose = selected ? purpose : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Price Range
              Text(
                'Price Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000000000,
                divisions: 100,
                labels: RangeLabels(
                  'UGX ${_priceRange.start.round()}',
                  'UGX ${_priceRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() => _priceRange = values);
                },
              ),
              const SizedBox(height: 16),
              // Amenities
              Text(
                'Amenities',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Furnished'),
                    selected: _showFurnished,
                    onSelected: (selected) {
                      setState(() => _showFurnished = selected);
                    },
                  ),
                  FilterChip(
                    label: const Text('Parking'),
                    selected: _showParking,
                    onSelected: (selected) {
                      setState(() => _showParking = selected);
                    },
                  ),
                  FilterChip(
                    label: const Text('Security'),
                    selected: _showSecurity,
                    onSelected: (selected) {
                      setState(() => _showSecurity = selected);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverAppBar(
            floating: true,
            title: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search properties...',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _applyFilters,
                ),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          // Property List
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredProperties.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No properties found',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final property = _filteredProperties[index];
                    return PropertyCard(
                      property: property,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(
                              propertyId: property.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _filteredProperties.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 