import 'package:flutter/material.dart';
import '../models/property_model.dart';

class PropertyTags extends StatelessWidget {
  final List<PropertyTag> tags;

  const PropertyTags({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final tagData = _getTagData(tag);
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: tagData.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: tagData.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tagData.icon,
                size: 12,
                color: tagData.color,
              ),
              const SizedBox(width: 4),
              Text(
                tagData.label,
                style: TextStyle(
                  color: tagData.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  TagData _getTagData(PropertyTag tag) {
    switch (tag) {
      case PropertyTag.new_:
        return TagData(
          label: 'New',
          color: Colors.blue,
          icon: Icons.fiber_new_rounded,
        );
      case PropertyTag.popular:
        return TagData(
          label: 'Popular',
          color: Colors.orange,
          icon: Icons.trending_up_rounded,
        );
      case PropertyTag.sold:
        return TagData(
          label: 'Sold',
          color: Colors.red,
          icon: Icons.check_circle_rounded,
        );
      case PropertyTag.rented:
        return TagData(
          label: 'Rented',
          color: Colors.green,
          icon: Icons.home_rounded,
        );
    }
  }
}

class TagData {
  final String label;
  final Color color;
  final IconData icon;

  TagData({
    required this.label,
    required this.color,
    required this.icon,
  });
} 