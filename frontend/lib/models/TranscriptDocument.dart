import 'package:mongo_dart/mongo_dart.dart';

/*
* This class resembles the generic transcript data structure
* */
class TranscriptDocument {

  final List<TranscriptCategory> categories;

  TranscriptDocument({
    required this.categories,
  });

  factory TranscriptDocument.fromJson(Map<String, dynamic> json) {
    return TranscriptDocument(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => TranscriptCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer('TranscriptDocument\n');
    for (final category in categories) {
      buffer.write(category._toStringWithIndent('  '));
    }
    return buffer.toString();
  }
}

// such as "Compulsary electives", "Free electives" , "Compulsaries"
class TranscriptCategory {
  final String name;
  final List<CategoryDomain>? domains; // optional, for free electives
  final List<TranscriptCourse>? courses; // optional, for free electives or other categories that can hold course data directly

  TranscriptCategory({
    required this.name,
    required this.domains,
    this.courses,
  });

  factory TranscriptCategory.fromJson(Map<String, dynamic> json) {
    return TranscriptCategory(
      name: json['name'] as String,
      domains: (json['domains'] as List<dynamic>?)
              ?.map((e) => CategoryDomain.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      courses: (json['courses'] as List<dynamic>?)
          ?.map((e) => TranscriptCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (domains != null) 'domains': domains!.map((e) => e.toJson()).toList(),
      if (courses != null) 'courses': courses!.map((e) => e.toJson()).toList(),
    };
  }

  String _toStringWithIndent(String indent) {
    final buffer = StringBuffer('${indent}📁 $name\n');
    if (domains != null) {
      for (final domain in domains!) {
        buffer.write(domain._toStringWithIndent('$indent  '));
      }
    }
    if (courses != null) {
      for (final course in courses!) {
        buffer.write(course._toStringWithIndent('$indent  '));
      }
    }
    return buffer.toString();
  }

  @override
  String toString() => _toStringWithIndent('');
}

// "Computer science" , "Communication Systems"
class CategoryDomain {
  final String name;
  final List<CategorySubdomain> subdomains;

  CategoryDomain({
    required this.name,
    required this.subdomains,
  });

  factory CategoryDomain.fromJson(Map<String, dynamic> json) {
    return CategoryDomain(
      name: json['name'] as String,
      subdomains: (json['subdomains'] as List<dynamic>?)
              ?.map((e) => CategorySubdomain.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subdomains': subdomains.map((e) => e.toJson()).toList(),
    };
  }

  String _toStringWithIndent(String indent) {
    final buffer = StringBuffer('$indent📂 $name\n');
    for (final subdomain in subdomains) {
      buffer.write(subdomain._toStringWithIndent('$indent  '));
    }
    return buffer.toString();
  }

  @override
  String toString() => _toStringWithIndent('');
}

// "Distributed systems and networks", "Data and software engineering"
class CategorySubdomain {
  final String name;
  final List<TranscriptCourse> courses;

  CategorySubdomain({
    required this.name,
    required this.courses,
  });

  factory CategorySubdomain.fromJson(Map<String, dynamic> json) {
    return CategorySubdomain(
      name: json['name'] as String,
      courses: (json['courses'] as List<dynamic>?)
              ?.map((e) => TranscriptCourse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'courses': courses.map((e) => e.toJson()).toList(),
    };
  }

  String _toStringWithIndent(String indent) {
    final buffer = StringBuffer('$indent📄 $name\n');
    for (final course in courses) {
      buffer.write(course._toStringWithIndent('$indent  '));
    }
    return buffer.toString();
  }

  @override
  String toString() => _toStringWithIndent('');
}

// The actual exams recorded
class TranscriptCourse {
  final String courseName;
  final int ects;
  final double grade;

  TranscriptCourse({
    required this.courseName,
    required this.ects,
    required this.grade,
  });

  factory TranscriptCourse.fromJson(Map<String, dynamic> json) {
    return TranscriptCourse(
      courseName: json['courseName'] as String,
      ects: json['ects'] as int,
      grade: (json['grade'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseName': courseName,
      'ects': ects,
      'grade': grade,
    };
  }

  String _toStringWithIndent(String indent) {
    return '$indent📚 $courseName (${ects} ECTS, Grade: $grade)\n';
  }

  @override
  String toString() => _toStringWithIndent('');
}