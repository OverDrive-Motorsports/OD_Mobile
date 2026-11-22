class Championship {
  const Championship({
    this.id,
    required this.championshipCode,
    required this.name,
    this.provider,
    this.category,
    this.isActive = true,
  });

  final String? id;
  final String championshipCode;
  final String name;
  final String? provider;
  final String? category;
  final bool isActive;
}
