// ── CLIENTE ───────────────────────────────────────────────
class Cliente {
  final int id;
  final String nombre;
  final String apellido;
  final String cedula;
  final String telefono;
  final String correo;

  Cliente({required this.id, required this.nombre, required this.apellido,
      required this.cedula, required this.telefono, required this.correo});

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
    id: j['id'], nombre: j['nombre'] ?? '', apellido: j['apellido'] ?? '',
    cedula: j['cedula'] ?? '', telefono: j['telefono'] ?? '', correo: j['correo'] ?? '',
  );

  Map<String, dynamic> toJson() =>
      {'nombre': nombre, 'apellido': apellido, 'cedula': cedula, 'telefono': telefono, 'correo': correo};
}

// ── DESTINO ───────────────────────────────────────────────
class Destino {
  final int id;
  final String nombreDestino;
  final String ciudad;
  final String pais;
  final String descripcion;

  Destino({required this.id, required this.nombreDestino, required this.ciudad,
      required this.pais, required this.descripcion});

  factory Destino.fromJson(Map<String, dynamic> j) => Destino(
    id: j['id'], nombreDestino: j['nombre_destino'] ?? '',
    ciudad: j['ciudad'] ?? '', pais: j['pais'] ?? '', descripcion: j['descripcion'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'nombre_destino': nombreDestino, 'ciudad': ciudad,
    'pais': pais, 'descripcion': descripcion,
  };
}

// ── PAQUETE ───────────────────────────────────────────────
class Paquete {
  final int id;
  final String nombrePaquete;
  final double precio;
  final int duracionDias;
  final int destino;
  final String nombreDestino;

  Paquete({required this.id, required this.nombrePaquete, required this.precio,
      required this.duracionDias, required this.destino, required this.nombreDestino});

  factory Paquete.fromJson(Map<String, dynamic> j) => Paquete(
    id: j['id'], nombrePaquete: j['nombre_paquete'] ?? '',
    precio: double.tryParse(j['precio'].toString()) ?? 0,
    duracionDias: j['duracion_dias'] ?? 0,
    destino: j['destino'] ?? 0, nombreDestino: j['nombre_destino'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'nombre_paquete': nombrePaquete, 'precio': precio,
    'duracion_dias': duracionDias, 'destino': destino,
  };
}

// ── RESERVA ───────────────────────────────────────────────
class Reserva {
  final int id;
  final String fechaReserva;
  final int cantidadPersonas;
  final String estado;
  final int cliente;
  final int paquete;
  final String nombreCliente;
  final String apellidoCliente;
  final String nombrePaquete;

  Reserva({required this.id, required this.fechaReserva, required this.cantidadPersonas,
      required this.estado, required this.cliente, required this.paquete,
      required this.nombreCliente, required this.apellidoCliente, required this.nombrePaquete});

  factory Reserva.fromJson(Map<String, dynamic> j) => Reserva(
    id: j['id'], fechaReserva: j['fecha_reserva'] ?? '',
    cantidadPersonas: j['cantidad_personas'] ?? 0, estado: j['estado'] ?? 'Pendiente',
    cliente: j['cliente'] ?? 0, paquete: j['paquete'] ?? 0,
    nombreCliente: j['nombre_cliente'] ?? '', apellidoCliente: j['apellido_cliente'] ?? '',
    nombrePaquete: j['nombre_paquete'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'fecha_reserva': fechaReserva, 'cantidad_personas': cantidadPersonas,
    'estado': estado, 'cliente': cliente, 'paquete': paquete,
  };
}

// ── PAGO ──────────────────────────────────────────────────
class Pago {
  final int id;
  final String fechaPago;
  final double monto;
  final String metodoPago;
  final int reserva;
  final String reservaInfo;

  Pago({required this.id, required this.fechaPago, required this.monto,
      required this.metodoPago, required this.reserva, required this.reservaInfo});

  factory Pago.fromJson(Map<String, dynamic> j) => Pago(
    id: j['id'], fechaPago: j['fecha_pago'] ?? '',
    monto: double.tryParse(j['monto'].toString()) ?? 0,
    metodoPago: j['metodo_pago'] ?? '', reserva: j['reserva'] ?? 0,
    reservaInfo: j['reserva_info'] ?? 'Reserva #${j['reserva']}',
  );

  Map<String, dynamic> toJson() => {
    'fecha_pago': fechaPago, 'monto': monto,
    'metodo_pago': metodoPago, 'reserva': reserva,
  };
}

// ── GUIA ──────────────────────────────────────────────────
class Guia {
  final int id;
  final String nombre;
  final String telefono;
  final String experiencia;
  final int destino;
  final String nombreDestino;

  Guia({required this.id, required this.nombre, required this.telefono,
      required this.experiencia, required this.destino, required this.nombreDestino});

  factory Guia.fromJson(Map<String, dynamic> j) => Guia(
    id: j['id'], nombre: j['nombre'] ?? '', telefono: j['telefono'] ?? '',
    experiencia: j['experiencia'] ?? '', destino: j['destino'] ?? 0,
    nombreDestino: j['nombre_destino'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre, 'telefono': telefono,
    'experiencia': experiencia, 'destino': destino,
  };
}
