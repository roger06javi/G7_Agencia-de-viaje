class Destino {
  int? id;
  String? nombreDestino;
  String? pais;
  String? ciudad;
  String? descripcion;

  Destino({
    this.id,
    required this.nombreDestino,
    required this.pais,
    required this.ciudad,
    required this.descripcion,
  });

  factory Destino.fromJson(Map<String, dynamic> json) {
    return Destino(
      id: json['id'],
      nombreDestino: json['nombre_destino']?.toString(),
      pais: json['pais']?.toString(),
      ciudad: json['ciudad']?.toString(),
      descripcion: json['descripcion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_destino': nombreDestino,
      'pais': pais,
      'ciudad': ciudad,
      'descripcion': descripcion,
    };
  }
}
