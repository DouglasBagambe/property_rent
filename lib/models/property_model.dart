class Property {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String? videoTour;
  final String location;
  final PropertyType type;
  final PropertyPurpose purpose;
  final double price;
  final double appointmentFee;
  final PropertySize size;
  final List<PropertyTag> tags;
  final bool isActive;
  final bool isFeatured;
  final DateTime datePosted;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    this.videoTour,
    required this.location,
    required this.type,
    required this.purpose,
    required this.price,
    required this.appointmentFee,
    required this.size,
    required this.tags,
    required this.isActive,
    required this.isFeatured,
    required this.datePosted,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      images: List<String>.from(json['images']),
      videoTour: json['videoTour'],
      location: json['location'],
      type: PropertyType.values.firstWhere(
        (e) => e.toString() == 'PropertyType.${json['type']}',
      ),
      purpose: PropertyPurpose.values.firstWhere(
        (e) => e.toString() == 'PropertyPurpose.${json['purpose']}',
      ),
      price: json['price'].toDouble(),
      appointmentFee: json['appointmentFee'].toDouble(),
      size: PropertySize.fromJson(json['size']),
      tags: (json['tags'] as List)
          .map((tag) => PropertyTag.values.firstWhere(
                (e) => e.toString() == 'PropertyTag.$tag',
              ))
          .toList(),
      isActive: json['isActive'],
      isFeatured: json['isFeatured'],
      datePosted: DateTime.parse(json['datePosted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'images': images,
      'videoTour': videoTour,
      'location': location,
      'type': type.toString().split('.').last,
      'purpose': purpose.toString().split('.').last,
      'price': price,
      'appointmentFee': appointmentFee,
      'size': size.toJson(),
      'tags': tags.map((tag) => tag.toString().split('.').last).toList(),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'datePosted': datePosted.toIso8601String(),
    };
  }
}

enum PropertyType {
  house,
  studio,
  apartment,
  plot,
  commercialSpace,
}

enum PropertyPurpose {
  sale,
  rent,
}

enum PropertyTag {
  new_,
  popular,
  sold,
  rented,
}

class PropertySize {
  final int? bedrooms;
  final int? bathrooms;
  final String? dimensions;

  PropertySize({
    this.bedrooms,
    this.bathrooms,
    this.dimensions,
  });

  factory PropertySize.fromJson(Map<String, dynamic> json) {
    return PropertySize(
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      dimensions: json['dimensions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'dimensions': dimensions,
    };
  }
} 