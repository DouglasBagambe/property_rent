import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';

class ApiService {
  // Use your machine's IP address instead of localhost
  static const String baseUrl = 'http://192.168.1.176:3000/api'; // Your actual IP address

  // Get all properties
  Future<List<Property>> getProperties() async {
    try {
      print('Fetching properties from: ${Uri.parse('$baseUrl/properties')}');
      final response = await http.get(Uri.parse('$baseUrl/properties'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Failed to load properties: ${response.statusCode}');
    } catch (e) {
      print('Error fetching properties: $e');
      throw Exception('Error: $e');
    }
  }

  // Get featured properties
  static Future<List<Property>> getFeaturedProperties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/featured'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Failed to load featured properties');
    } catch (e) {
      throw Exception('Error fetching featured properties: $e');
    }
  }

  // Get property by ID
  static Future<Property> getPropertyById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/$id'));
    if (response.statusCode == 200) {
      return Property.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load property');
    }
  }

  // Search properties
  static Future<List<Property>> searchProperties({
    String? query,
    PropertyType? type,
    PropertyPurpose? purpose,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, String>{};
    if (query != null) queryParams['query'] = query;
    if (type != null) queryParams['type'] = type.toString().split('.').last;
    if (purpose != null) queryParams['purpose'] = purpose.toString().split('.').last;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

    final uri = Uri.parse('$baseUrl/properties/search').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search properties');
    }
  }

  // Book appointment
  static Future<void> bookAppointment({
    required String propertyId,
    required String name,
    required String phone,
    required String email,
    required DateTime appointmentTime,
    required String duration,
    required String purpose,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'propertyId': propertyId,
        'name': name,
        'phone': phone,
        'email': email,
        'appointmentTime': appointmentTime.toIso8601String(),
        'duration': duration,
        'purpose': purpose,
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to book appointment');
    }
  }

  static Future<List<Property>> getRecentProperties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/recent'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Property.fromJson(json)).toList();
      }
      throw Exception('Failed to load recent properties');
    } catch (e) {
      throw Exception('Error fetching recent properties: $e');
    }
  }

  static Future<Property> getProperty(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Property.fromJson(data);
      }
      throw Exception('Failed to load property');
    } catch (e) {
      throw Exception('Error fetching property: $e');
    }
  }
} 