class Team {
  const Team({
    required this.teamId,
    required this.name,
    this.code,
    this.color,
  });

  final String teamId;
  final String name;
  final String? code;
  final String? color;
}
