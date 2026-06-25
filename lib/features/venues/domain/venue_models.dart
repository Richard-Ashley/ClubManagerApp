class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  final int id;
  final String name;
  final String description;
  final bool isActive;

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
      );
}

class VenueSlot {
  const VenueSlot({
    required this.id,
    required this.venueId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  final int id;
  final int venueId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  String get timeRange => '$startTime – $endTime';

  factory VenueSlot.fromJson(Map<String, dynamic> json) => VenueSlot(
        id: json['id'] as int,
        venueId: json['venueId'] as int,
        dayOfWeek: json['dayOfWeek'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
      );
}
