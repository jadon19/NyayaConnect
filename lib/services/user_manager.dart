class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;

  UserManager._internal();

  String? userCustomId;
  String? lawyerId;
  String? judgeCustomId;
  String? userName;
  String get role {
    if (judgeCustomId != null) return "judge";
    if (lawyerId != null) return "lawyer";
    return "client";
  }
  bool get isJudge => role == "judge";
  bool get isLawyer => role == "lawyer";
  bool get isClient => role == "client";
}

