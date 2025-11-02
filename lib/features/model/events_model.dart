import 'package:cloud_firestore/cloud_firestore.dart';

class EventsModel {
  final String id;
  String title;
  String description;
  DateTime date;
  String location;
  String? imageUrl;
  DateTime createdAt;

  EventsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "date": Timestamp.fromDate(date),
      "location": location,
      "imageUrl": imageUrl,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  static EventsModel empty() => EventsModel(
    id: '',
    title: '',
    description: '',
    date: DateTime.now(),
    location: '',
    imageUrl: null,
    createdAt: DateTime.now(),
  );

  factory EventsModel.fromJson(Map<String, dynamic>? events, String id) {
    if (events == null) return EventsModel.empty();
    return EventsModel(
      id: id,
      title: events['title'] ?? '',
      description: events['description'] ?? '',
      date: events['date'] is Timestamp
          ? (events['date'] as Timestamp).toDate()
          : DateTime.tryParse(events['date'] ?? '') ?? DateTime.now(),
      location: events['location'] ?? '',
      imageUrl: events['imageUrl'],
      createdAt: events['createdAt'] is Timestamp
          ? (events['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
