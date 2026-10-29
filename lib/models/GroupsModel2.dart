class GroupAttendanceModel2 {
  final String Name;
  final String id;
  final List<dynamic>? lectures;

  GroupAttendanceModel2({
    required this.Name,
    required this.id,
    required this.lectures,
  });

  factory GroupAttendanceModel2.fromJson(Map<String, dynamic> json) {
    return GroupAttendanceModel2(
        id: json['id'], Name: json['Name'], lectures: json['lectures']);
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'name': Name,
  //   };
  // }
}
