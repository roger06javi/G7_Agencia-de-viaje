class Cliente {
  int? id;
  String? nombre;
  String? apellido;
  String? cedula;
  String? telefono;
  String? correo;

  Cliente({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.telefono,
    required this.correo,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre']?.toString(),
      apellido: json['apellido']?.toString(),
      cedula: json['cedula']?.toString(),
      telefono: json['telefono']?.toString(),
      correo: json['correo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'cedula': cedula,
      'telefono': telefono,
      'correo': correo,
    };
  }
}