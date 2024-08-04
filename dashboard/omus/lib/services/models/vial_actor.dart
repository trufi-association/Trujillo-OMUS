class VialActor {
  final int id;
  final String? name;

  VialActor({
    required this.id,
    this.name,
  });

  factory VialActor.fromJson(Map<String, dynamic> json) {
    return VialActor(
      id: json['id'],
      name: json['name'],
    );
  }
}
