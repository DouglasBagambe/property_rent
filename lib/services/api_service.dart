import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Change this to your backend URL

  // Get all properties
  Future<List<Property>> getProperties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Failed to load properties');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get featured properties
  Future<List<Property>> getFeaturedProperties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/featured'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Failed to load featured properties');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get property by ID
  Future<Property> getPropertyById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/$id'));
      if (response.statusCode == 200) {
        return Property.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load property');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Search properties
  Future<List<Property>> searchProperties({
    String? query,
    PropertyType? type,
    PropertyPurpose? purpose,
    double? minPrice,
    double? maxPrice,
    String? location,
    int? bedrooms,
    int? bathrooms,
  }) async {
    try {
      final queryParams = {
        if (query != null) 'query': query,
        if (type != null) 'type': type.toString().split('.').last,
        if (purpose != null) 'purpose': purpose.toString().split('.').last,
        if (minPrice != null) 'minPrice': minPrice.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
        if (location != null) 'location': location,
        if (bedrooms != null) 'bedrooms': bedrooms.toString(),
        if (bathrooms != null) 'bathrooms': bathrooms.toString(),
      };

      final uri = Uri.parse('$baseUrl/properties/search').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Failed to search properties');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Book appointment
  Future<bool> bookAppointment({
    required String propertyId,
    required String name,
    required String email,
    required String phone,
    required DateTime preferredDate,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'propertyId': propertyId,
          'name': name,
          'email': email,
          'phone': phone,
          'preferredDate': preferredDate.toIso8601String(),
          'message': message,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 