class EventModel {
  String? id;
  final String title;
  final String description;
  final String locationAddress;
  final double? locationLat;
  final double? locationLng;
  final String organizerId;
  final String organizerName;
  final String startTime;
  final String endTime;
  final DateTime createdAt;
  final String? bannerUrl;
  final String? photoUrl;
  final String? skUrl;
  final String eventType;
  final String eventDay;
  final String tags;
  final bool isOnline;
  final String? onlineLink;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.locationAddress,
    this.locationLat,
    this.locationLng,
    required this.organizerId,
    required this.organizerName,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.bannerUrl,
    this.photoUrl,
    this.skUrl,
    required this.eventType,
    required this.eventDay,
    required this.tags,
    required this.isOnline,
    this.onlineLink,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'locationAddress': locationAddress,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt.toIso8601String(),
      'bannerUrl': bannerUrl,
      'photoUrl': photoUrl,
      'skUrl': skUrl,
      'eventType': eventType,
      'eventDay': eventDay,
      'tags': tags,
      'isOnline': isOnline,
      'onlineLink': onlineLink,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      locationAddress: json['locationAddress'] ?? '',
      locationLat: (json['locationLat'] as num?)?.toDouble(),
      locationLng: (json['locationLng'] as num?)?.toDouble(),
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      bannerUrl: json['bannerUrl'],
      photoUrl: json['photoUrl'],
      skUrl: json['skUrl'],
      eventType: json['eventType'] ?? '',
      eventDay: json['eventDay'] ?? '',
      tags: json['tags'] ?? '',
      isOnline: json['isOnline'] ?? false,
      onlineLink: json['onlineLink'],
    );
  }
}
