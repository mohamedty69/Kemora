/// Local trip data models used by the Trip Planner tab.
/// Will be replaced by backend API calls in the future.

class TripStop {
  final String placeId; // links to PlaceInfo.id in place_data.dart
  final String name;
  final String time; // e.g. "09:00 AM"
  final String category;
  final double reviewScore;
  final List<String> tags;
  final bool isCompleted;

  const TripStop({
    required this.placeId,
    required this.name,
    required this.time,
    required this.category,
    required this.reviewScore,
    this.tags = const [],
    this.isCompleted = false,
  });

  TripStop copyWith({
    String? placeId,
    String? name,
    String? time,
    String? category,
    double? reviewScore,
    List<String>? tags,
    bool? isCompleted,
  }) {
    return TripStop(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      time: time ?? this.time,
      category: category ?? this.category,
      reviewScore: reviewScore ?? this.reviewScore,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TripDay {
  final int dayNumber;
  final String title; // e.g. "Cairo"
  final List<TripStop> stops;

  const TripDay({
    required this.dayNumber,
    required this.title,
    required this.stops,
  });

  TripDay copyWith({
    int? dayNumber,
    String? title,
    List<TripStop>? stops,
  }) {
    return TripDay(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      stops: stops ?? this.stops,
    );
  }
}

class LocalTrip {
  final String id;
  final String title;
  final String governorate;
  final int durationDays;
  final List<TripDay> days;
  final DateTime createdAt;

  const LocalTrip({
    required this.id,
    required this.title,
    required this.governorate,
    required this.durationDays,
    required this.days,
    required this.createdAt,
  });

  LocalTrip copyWith({
    String? id,
    String? title,
    String? governorate,
    int? durationDays,
    List<TripDay>? days,
    DateTime? createdAt,
  }) {
    return LocalTrip(
      id: id ?? this.id,
      title: title ?? this.title,
      governorate: governorate ?? this.governorate,
      durationDays: durationDays ?? this.durationDays,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ── Seed Trips ─────────────────────────────────────────────────────

final List<LocalTrip> seedTrips = [
  LocalTrip(
    id: 'trip1',
    title: 'Pharaohs & Pyramids',
    governorate: 'Cairo & Giza',
    durationDays: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    days: [
      const TripDay(
        dayNumber: 1,
        title: 'Cairo',
        stops: [
          TripStop(
            placeId: 'p5',
            name: 'Egyptian Museum',
            time: '09:00 AM',
            category: 'Museums',
            reviewScore: 4.7,
            tags: ['Museum', 'Cultural', 'History'],
            isCompleted: true,
          ),
          TripStop(
            placeId: 'p6',
            name: 'Khan el-Khalili',
            time: '02:00 PM',
            category: 'Others',
            reviewScore: 4.6,
            tags: ['Market', 'Shopping', 'Cultural'],
            isCompleted: true,
          ),
          TripStop(
            placeId: 'p13',
            name: 'Abou El Sid',
            time: '07:00 PM',
            category: 'Restaurants',
            reviewScore: 4.5,
            tags: ['Dining', 'Egyptian Cuisine'],
            isCompleted: true,
          ),
        ],
      ),
      const TripDay(
        dayNumber: 2,
        title: 'Giza',
        stops: [
          TripStop(
            placeId: 'p1',
            name: 'Great Pyramid of Giza',
            time: '08:00 AM',
            category: 'Ancient Places',
            reviewScore: 4.9,
            tags: ['UNESCO', 'Historical', 'Wonder'],
          ),
          TripStop(
            placeId: 'p12',
            name: 'Marriott Mena House',
            time: '01:00 PM',
            category: 'Hotels',
            reviewScore: 4.7,
            tags: ['Luxury', 'Pyramid View'],
          ),
        ],
      ),
      const TripDay(
        dayNumber: 3,
        title: 'Luxor - East Bank',
        stops: [
          TripStop(
            placeId: 'p2',
            name: 'Luxor Temple',
            time: '09:00 AM',
            category: 'Ancient Places',
            reviewScore: 4.8,
            tags: ['Temple', 'Ancient Egypt'],
          ),
          TripStop(
            placeId: 'p3',
            name: 'Karnak Temple',
            time: '02:00 PM',
            category: 'Ancient Places',
            reviewScore: 4.9,
            tags: ['Temple', 'UNESCO', 'Colossal'],
          ),
        ],
      ),
      const TripDay(
        dayNumber: 4,
        title: 'Luxor - West Bank',
        stops: [
          TripStop(
            placeId: 'p4',
            name: 'Valley of the Kings',
            time: '07:00 AM',
            category: 'Ancient Places',
            reviewScore: 4.9,
            tags: ['Tombs', 'Pharaohs', 'UNESCO'],
          ),
          TripStop(
            placeId: 'p14',
            name: 'Sofra Restaurant',
            time: '01:00 PM',
            category: 'Restaurants',
            reviewScore: 4.6,
            tags: ['Traditional', 'Local Cuisine'],
          ),
        ],
      ),
      const TripDay(
        dayNumber: 5,
        title: 'Aswan',
        stops: [
          TripStop(
            placeId: 'p7',
            name: 'Philae Temple',
            time: '08:00 AM',
            category: 'Ancient Places',
            reviewScore: 4.8,
            tags: ['Island Temple', 'Isis', 'UNESCO'],
          ),
          TripStop(
            placeId: 'p11',
            name: 'Old Cataract Hotel',
            time: '04:00 PM',
            category: 'Hotels',
            reviewScore: 4.9,
            tags: ['Legendary', 'Nile View', 'Luxury'],
          ),
        ],
      ),
    ],
  ),
  LocalTrip(
    id: 'trip2',
    title: 'Red Sea Escape',
    governorate: 'South Sinai',
    durationDays: 3,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    days: [
      const TripDay(
        dayNumber: 1,
        title: 'Sharm El Sheikh',
        stops: [
          TripStop(
            placeId: 'p15',
            name: 'Ras Mohammed Park',
            time: '08:00 AM',
            category: 'Others',
            reviewScore: 4.9,
            tags: ['Nature', 'Diving', 'Snorkeling'],
          ),
        ],
      ),
      const TripDay(
        dayNumber: 2,
        title: 'Dahab',
        stops: [
          TripStop(
            placeId: 'p15',
            name: 'Blue Hole Diving',
            time: '09:00 AM',
            category: 'Others',
            reviewScore: 4.8,
            tags: ['Adventure', 'Diving', 'Famous'],
          ),
        ],
      ),
      const TripDay(
        dayNumber: 3,
        title: 'Alexandria Day',
        stops: [
          TripStop(
            placeId: 'p9',
            name: 'Qaitbay Citadel',
            time: '10:00 AM',
            category: 'Ancient Places',
            reviewScore: 4.7,
            tags: ['Fortress', 'Mediterranean', 'History'],
          ),
          TripStop(
            placeId: 'p10',
            name: 'Bibliotheca Alexandrina',
            time: '02:00 PM',
            category: 'Museums',
            reviewScore: 4.8,
            tags: ['Library', 'Modern', 'Cultural'],
          ),
        ],
      ),
    ],
  ),
];
