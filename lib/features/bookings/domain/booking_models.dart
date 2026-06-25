class Booking {
  const Booking({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.venueId,
    required this.venueName,
    required this.slotId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.bookingDate,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int memberId;
  final String memberName;
  final int venueId;
  final String venueName;
  final int slotId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String bookingDate; // yyyy-MM-dd
  final String status;
  final DateTime createdAt;

  bool get isConfirmed => status == 'Confirmed';
  bool get isCancelled => status == 'Cancelled';

  DateTime get bookingDateTime => DateTime.parse(bookingDate);

  bool get isUpcoming {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    return isConfirmed && !bookingDateTime.isBefore(dateOnly);
  }

  String get timeRange => '$startTime – $endTime';

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as int,
        memberId: json['memberId'] as int,
        memberName: json['memberName'] as String,
        venueId: json['venueId'] as int,
        venueName: json['venueName'] as String,
        slotId: json['slotId'] as int,
        dayOfWeek: json['dayOfWeek'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        bookingDate: json['bookingDate'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class CreateBookingRequest {
  const CreateBookingRequest({
    required this.venueId,
    required this.slotId,
    required this.bookingDate,
  });

  final int venueId;
  final int slotId;
  final String bookingDate; // yyyy-MM-dd

  Map<String, dynamic> toJson() => {
        'venueId': venueId,
        'slotId': slotId,
        'bookingDate': bookingDate,
      };
}
