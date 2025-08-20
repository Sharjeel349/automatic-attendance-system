class Teacher {
  final String id;
  final String name;
  final String email;
  final List<String> assignedCourses;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    this.assignedCourses = const [], // default to empty list
  });

  factory Teacher.fromMap(String id, Map<String, dynamic> map) {
    return Teacher(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      assignedCourses: List<String>.from(map['assignedCourses'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'assignedCourses': assignedCourses,
    };
  }
}


