class Session {
  const Session({
    required this.sessionId,
    required this.eventId,
    required this.type,
    required this.status,
    this.name,
    this.circuit,
    this.externalKey,
    this.broadcastUrl,
    this.startTime,
    this.endTime,
  });

  final String sessionId;
  final String eventId;
  final String type;
  final String status;
  final String? name;
  final String? circuit;
  final String? externalKey;
  final String? broadcastUrl;
  final DateTime? startTime;
  final DateTime? endTime;
}
