// class Course {
//   final String id;
//   final String name;
//   final int credithour;
//   Course({
//     required this.id,
//     required this.name,
//     required this.credithour,
//   });
//
//   // From Firestore document
//   factory Course.fromMap(String id, Map<String, dynamic> map) {
//     return Course(
//       id: id, // document ID
//       name: map['name'] ?? '',
//       credithour: map['credithour'] ?? '',
//     );
//   }
//
//   // To Firestore document
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'credithour': credithour,
//     };
//   }
// }

class Course {
  final String id;
  final String name;
  final int credithour;
  final List<String> assignedTeachers;

  Course({
    required this.id,
    required this.name,
    required this.credithour,
    this.assignedTeachers = const [],
  });

  factory Course.fromMap(String id, Map<String, dynamic> map) {
    return Course(
      id: id,
      name: map['name'] ?? '',
      credithour: map['credithour'] ?? 0,
      assignedTeachers: List<String>.from(map['assignedTeachers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'credithour': credithour,
      'assignedTeachers': assignedTeachers,
    };
  }
}


