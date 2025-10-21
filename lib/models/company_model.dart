/// Modelo de empresa con configuración completa
library;

/// Modelo de empresa con configuración completa
class CompanyModel {
  final String rnc;
  final String razonSocial;
  final String? nombreComercial;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String? website;
  final String? logoUrl;

  // Configuración del sistema
  final bool isConfigured;
  final String? activeSchemaId;
  final String? urlERPEndpoint; // Deprecated - mantener por compatibilidad
  final bool useFakeData;
  final Map<String, dynamic> erpConfig;
  final List<String> erpEndpointIds; // IDs de los endpoints configurados

  // Metadatos
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const CompanyModel({
    required this.rnc,
    required this.razonSocial,
    this.nombreComercial,
    this.direccion,
    this.telefono,
    this.email,
    this.website,
    this.logoUrl,
    this.isConfigured = false,
    this.activeSchemaId,
    this.urlERPEndpoint,
    this.useFakeData = true,
    this.erpConfig = const {},
    this.erpEndpointIds = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      rnc: json['rnc'],
      razonSocial: json['razonSocial'],
      nombreComercial: json['nombreComercial'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      email: json['email'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      isConfigured: json['isConfigured'] ?? false,
      activeSchemaId: json['activeSchemaId'],
      urlERPEndpoint: json['urlERPEndpoint'],
      useFakeData: json['useFakeData'] ?? true,
      erpConfig: json['erpConfig'] ?? {},
      erpEndpointIds: json['erpEndpointIds'] != null
          ? List<String>.from(json['erpEndpointIds'])
          : [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rnc': rnc,
      'razonSocial': razonSocial,
      'nombreComercial': nombreComercial,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'isConfigured': isConfigured,
      'activeSchemaId': activeSchemaId,
      'urlERPEndpoint': urlERPEndpoint,
      'useFakeData': useFakeData,
      'erpConfig': erpConfig,
      'erpEndpointIds': erpEndpointIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  CompanyModel copyWith({
    String? rnc,
    String? razonSocial,
    String? nombreComercial,
    String? direccion,
    String? telefono,
    String? email,
    String? website,
    String? logoUrl,
    bool? isConfigured,
    String? activeSchemaId,
    String? urlERPEndpoint,
    bool? useFakeData,
    Map<String, dynamic>? erpConfig,
    List<String>? erpEndpointIds,
    DateTime? updatedAt,
  }) {
    return CompanyModel(
      rnc: rnc ?? this.rnc,
      razonSocial: razonSocial ?? this.razonSocial,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      isConfigured: isConfigured ?? this.isConfigured,
      activeSchemaId: activeSchemaId ?? this.activeSchemaId,
      urlERPEndpoint: urlERPEndpoint ?? this.urlERPEndpoint,
      useFakeData: useFakeData ?? this.useFakeData,
      erpConfig: erpConfig ?? this.erpConfig,
      erpEndpointIds: erpEndpointIds ?? this.erpEndpointIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy,
    );
  }

  /// Verifica qué paso de configuración necesita
  int get currentSetupStep {
    // Paso 1: Información básica
    if (razonSocial.isEmpty ||
        direccion == null ||
        direccion!.isEmpty ||
        telefono == null ||
        telefono!.isEmpty) {
      return 1;
    }

    // Paso 2: Esquema de datos
    if (activeSchemaId == null ||
        activeSchemaId!.isEmpty ||
        activeSchemaId == 'Sin configurar') {
      return 2;
    }

    // Paso 3: Configuración ERP
    if (!useFakeData && erpEndpointIds.isEmpty) {
      return 3;
    }

    // Configuración completa
    return 0; // 0 = completado
  }

  /// Verifica si necesita configuración
  bool get needsSetup {
    return currentSetupStep > 0;
  }

  /// Helper para parsear DateTime desde String o Timestamp
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    // Si es un Timestamp de Firebase
    if (value.runtimeType.toString().contains('Timestamp')) {
      return (value as dynamic).toDate();
    }

    // Si es un String
    if (value is String) {
      return DateTime.parse(value);
    }

    // Fallback
    return DateTime.now();
  }
}
