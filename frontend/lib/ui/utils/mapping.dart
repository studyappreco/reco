
String? getFullProgramName(String programLiteral) {
  switch (programLiteral) {
    case "ISM_M":
        return "Information Systems Management (M. Sc.)";
    case "CS_M":
      return "Computer Science (M. Sc.)";
    case "CS_B":
      return "Computer Science (B. Sc.)";
    default:
      return null;
  }
}