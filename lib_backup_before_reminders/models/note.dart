

class Note {
  final String id;
  final String? parentId;
  String title;
  String content;
  int colorIndex;
  List<String> childIds;
  Map<String, String> childPreviews; // childId → original text that was nested
  DateTime createdAt;
  DateTime updatedAt;
  bool pinned;
  bool isList; // Checkbox mode
  List<String> images; // Paths to local image files

  Note({
    required this.id,
    this.parentId,
    this.title = '',
    this.content = '',
    this.colorIndex = 0,
    List<String>? childIds,
    Map<String, String>? childPreviews,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.pinned = false,
    this.isList = false,
  })  : childIds = childIds ?? [],
        childPreviews = childPreviews ?? {},
        images = images ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    int? colorIndex,
    List<String>? childIds,
    Map<String, String>? childPreviews,
    List<String>? images,
    DateTime? updatedAt,
    bool? pinned,
    bool? isList,
  }) {
    return Note(
      id: id,
      parentId: parentId,
      title: title ?? this.title,
      content: content ?? this.content,
      colorIndex: colorIndex ?? this.colorIndex,
      childIds: childIds ?? List.from(this.childIds),
      childPreviews: childPreviews ?? Map.from(this.childPreviews),
      images: images ?? List.from(this.images),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      pinned: pinned ?? this.pinned,
      isList: isList ?? this.isList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'content': content,
      'colorIndex': colorIndex,
      'childIds': childIds,
      'childPreviews': childPreviews,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pinned': pinned,
      'isList': isList,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      parentId: json['parentId'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      colorIndex: json['colorIndex'] as int? ?? 0,
      childIds: (json['childIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      childPreviews: (json['childPreviews'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      pinned: json['pinned'] as bool? ?? false,
      isList: json['isList'] as bool? ?? false, // Safe default for new field
    );
  }
}
