class MenuItem {
  final String id;
  final String name;
  final String? subItem;
  final DateTime createdAt;

  MenuItem({
    required this.id,
    required this.name,
    this.subItem,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subItem': subItem,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, String documentId) {
    return MenuItem(
      id: documentId,
      name: map['name'] ?? '',
      subItem: map['subItem'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  @override
  String toString() {
    if (subItem != null && subItem!.isNotEmpty) {
      return '$name (With $subItem)';
    }
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
