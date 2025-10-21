class ERPEndpoint {
  final String id;
  final String name;
  final String url;
  final String method; // GET, POST, etc.
  final Map<String, String>? headers;
  final Map<String, dynamic>? queryParams;
  final String? body;
  final EndpointType type;
  final Map<String, String> fieldMapping; // Mapeo de campos ERP -> DGII
  final DateTime createdAt;
  final DateTime updatedAt;

  ERPEndpoint({
    required this.id,
    required this.name,
    required this.url,
    this.method = 'GET',
    this.headers,
    this.queryParams,
    this.body,
    required this.type,
    this.fieldMapping = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory ERPEndpoint.fromJson(Map<String, dynamic> json) {
    return ERPEndpoint(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      method: json['method'] as String? ?? 'GET',
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      queryParams: json['queryParams'] != null
          ? Map<String, dynamic>.from(json['queryParams'] as Map)
          : null,
      body: json['body'] as String?,
      type: EndpointType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EndpointType.invoices,
      ),
      fieldMapping: json['fieldMapping'] != null
          ? Map<String, String>.from(json['fieldMapping'] as Map)
          : {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'method': method,
      'headers': headers,
      'queryParams': queryParams,
      'body': body,
      'type': type.name,
      'fieldMapping': fieldMapping,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ERPEndpoint copyWith({
    String? id,
    String? name,
    String? url,
    String? method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    String? body,
    EndpointType? type,
    Map<String, String>? fieldMapping,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ERPEndpoint(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      queryParams: queryParams ?? this.queryParams,
      body: body ?? this.body,
      type: type ?? this.type,
      fieldMapping: fieldMapping ?? this.fieldMapping,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum EndpointType {
  invoices, // Facturas
  clients, // Clientes
  products, // Productos
  services, // Servicios
  payments, // Pagos
  custom, // Personalizado
}

extension EndpointTypeExtension on EndpointType {
  String get displayName {
    switch (this) {
      case EndpointType.invoices:
        return 'Facturas';
      case EndpointType.clients:
        return 'Clientes';
      case EndpointType.products:
        return 'Productos';
      case EndpointType.services:
        return 'Servicios';
      case EndpointType.payments:
        return 'Pagos';
      case EndpointType.custom:
        return 'Personalizado';
    }
  }

  String get description {
    switch (this) {
      case EndpointType.invoices:
        return 'Endpoint para obtener facturas del ERP';
      case EndpointType.clients:
        return 'Endpoint para obtener información de clientes';
      case EndpointType.products:
        return 'Endpoint para obtener productos/servicios';
      case EndpointType.services:
        return 'Endpoint para obtener servicios';
      case EndpointType.payments:
        return 'Endpoint para obtener información de pagos';
      case EndpointType.custom:
        return 'Endpoint personalizado';
    }
  }
}
