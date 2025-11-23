class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final DateTime birthDate;

  final String? nameCaregiver;
  final String? emailCaregiver;

  final String? avatarUrl;
  final DateTime? createdAt;
  final bool reportingConsent;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    this.nameCaregiver,
    this.emailCaregiver,
    this.avatarUrl,
    this.createdAt,
    this.reportingConsent = false,
  });

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    int? fallbackId,
  }) {
    return UserProfile(
      id: _parseId(json['id'], fallbackId),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: DateTime.parse(json['birthDate']),
      nameCaregiver: json['nameCaregiver'],
      emailCaregiver: json['emailCaregiver'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      reportingConsent: json['reportingConsent'] ?? false,
    );
  }

  static int? _parseId(dynamic id, int? fallbackId) {
  
    if (id == null) return fallbackId;
    if (id is int) return id;
    if (id is String) {
      final parsed = int.tryParse(id);
      return parsed ?? fallbackId;
    }

    return fallbackId;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate.toIso8601String(),
      'nameCaregiver': nameCaregiver,
      'emailCaregiver': emailCaregiver,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'reportingConsent': reportingConsent,
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? nameCaregiver,
    String? emailCaregiver,
    String? avatarUrl,
    DateTime? createdAt,
    bool? reportingConsent,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      nameCaregiver: nameCaregiver ?? this.nameCaregiver,
      emailCaregiver: emailCaregiver ?? this.emailCaregiver,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      reportingConsent: reportingConsent ?? this.reportingConsent,
    );
  }
}
