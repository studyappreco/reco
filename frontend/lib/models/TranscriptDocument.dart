
/*
* This is the data structured used t represent a transcript.
* It is a n-ary tree with the maximum of 4 levels deep. We have the root class (TranscriptDocument) and a generic Node class (TranscriptNode)
* This is a flexible data model, not every transcript needs 4 level. This way we can be as abstract as possible.
*
* Root: represents the Entire Transcript
* 1. level: "categories". High-level components like "free electives", "Compulsary electices", ... (might hold course data already)
* 2. level:  "domains". Split the category in e.g. "information systems" , "computer science"
* 3. level. "subdomains". Splits the categories again in e.g. "Distributed Systems and networks", "Data and software engineering"
*
* Note : each node (except root) can hold course data.
* */


class TranscriptDocument {
  final List<TranscriptNode> children;

  TranscriptDocument({required this.children});

  factory TranscriptDocument.fromJson(Map<String, dynamic> json) {
    return TranscriptDocument(
      children: (json['children'] as List<dynamic>)
          .map((e) => TranscriptNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer('TranscriptDocument\n');
    for (final child in children) {
      buffer.write(child._toStringWithIndent('  '));
    }
    return buffer.toString();
  }
}

class TranscriptNode {
  final String name;
  final List<TranscriptCourse>? courses;
  final List<TranscriptNode>? children;

  TranscriptNode({
    required this.name,
    this.courses,
    this.children,
  }) ;

  factory TranscriptNode.fromJson(Map<String, dynamic> json) {
    return TranscriptNode(
      name: json['name'] as String,
      courses: (json['courses'] as List<dynamic>?)
          ?.map((e) => TranscriptCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => TranscriptNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (courses != null) 'courses': courses!.map((e) => e.toJson()).toList(),
      if (children != null) 'children': children!.map((e) => e.toJson()).toList(),
    };
  }

  String _toStringWithIndent(String indent) {
    final buffer = StringBuffer('$indent📁 $name');
    if (courses != null) {
      for (final course in courses!) {
        buffer.write(course._toStringWithIndent('$indent  '));
      }
    }
    if (children != null) {
      for (final child in children!) {
        buffer.write(child._toStringWithIndent('$indent  '));
      }
    }
    return buffer.toString();
  }
}

// The actual exams recorded
class TranscriptCourse {
  final String courseName;
  final int ects;
  final double grade;
  final String id;
  final String examDate;

  TranscriptCourse({
    required this.courseName,
    required this.ects,
    required this.grade,
    required this.id,
    required this.examDate
  });

  factory TranscriptCourse.fromJson(Map<String, dynamic> json) {
    return TranscriptCourse(
      id : json['id'] as String,
      courseName: json['name'] as String,
      ects: (json['ects'] as num).toInt(),
      grade: (json['grade'] as num).toDouble(),
        examDate : json['examDate'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name': courseName,
      'ects': ects,
      'grade': grade,
      'examDate' : examDate
    };
  }

  String _toStringWithIndent(String indent) {
    return '$indent📚 $courseName ($ects ECTS, Grade: $grade)\n';
  }

  @override
  String toString() => _toStringWithIndent('');
}