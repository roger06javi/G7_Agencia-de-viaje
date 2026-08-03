class Cliente {
    int? id;
    String? nombre;
    String? apellido;   
    String? email;
    String? telefono;
    String? direccion;  
    string? estado;

Cliente ({
    this.id,    
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.estado,
});
factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
        id: json['id'],
        nombre: json['nombre'],
        apellido: json['apellido'],
        email: json['email'],
        telefono: json['telefono'],
        direccion: json['direccion'],
        estado: json['estado'],
    );
  }

Map<String, dynamic> toJson() {
    return {
        'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'direccion': direccion,
        'estado': estado,
    };
  }
}