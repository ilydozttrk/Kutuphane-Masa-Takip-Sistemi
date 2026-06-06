class IssueReportModel {
  final int id;
  final int userId;
  final String userFullName;
  final int studyTableId;
  final String studyTableCode;
  final String description;
  final int status;
  final DateTime? createdAt;

  IssueReportModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.studyTableId,
    required this.studyTableCode,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory IssueReportModel.fromJson(Map<String, dynamic> json) {
    return IssueReportModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      userFullName: json['userFullName']?.toString() ?? '',
      studyTableId: json['studyTableId'] ?? 0,
      studyTableCode: json['studyTableCode']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 1:
        return 'Açık';
      case 2:
        return 'İnceleniyor';
      case 3:
        return 'Çözüldü';
      case 4:
        return 'Reddedildi';
      default:
        return 'Bilinmiyor';
    }
  }

  bool get isOpen => status == 1;
  bool get isInProgress => status == 2;
  bool get isResolved => status == 3;
  bool get isRejected => status == 4;
}