class Student {
  final String id; 
  final String name;
  final String email;
  final String discipline;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.discipline,
  });

  // From Firestore document
  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      id: id, // document ID
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      discipline: map['discipline'] ?? '',
    );
  }

  // To Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'discipline': discipline,
    };
  }
}
