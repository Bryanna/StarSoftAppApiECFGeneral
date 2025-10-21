import 'erp_endpoint.dart';

class DynamicTab {
  final String id;
  final String label;
  final String description;
  final ERPEndpoint endpoint;
  final int count;

  const DynamicTab({
    required this.id,
    required this.label,
    required this.description,
    required this.endpoint,
    this.count = 0,
  });

  DynamicTab copyWith({
    String? id,
    String? label,
    String? description,
    ERPEndpoint? endpoint,
    int? count,
  }) {
    return DynamicTab(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      endpoint: endpoint ?? this.endpoint,
      count: count ?? this.count,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DynamicTab && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
