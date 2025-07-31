// models/event.dart
class Event {
  final List<double> position;
  final String cop;
  final String copId;
  final String type;

  Event({
    required this.position,
    required this.cop,
    required this.copId,
    required this.type,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      position: List<double>.from(json['position']),
      cop: json['cop'],
      copId: json['cop_id'],
      type: json['type'],
    );
  }
}