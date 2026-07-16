import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.pan,
    this.kycStatus = KycStatus.pending,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      pan: json['pan'] as String?,
      kycStatus: KycStatus.fromString(json['kyc_status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? pan;
  final KycStatus kycStatus;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'pan': pan,
        'kyc_status': kycStatus.value,
        'created_at': createdAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, email, phone, pan, kycStatus, createdAt];
}

enum KycStatus {
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  const KycStatus(this.value);
  final String value;

  static KycStatus fromString(String? value) {
    return KycStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => KycStatus.pending,
    );
  }

  String get label => switch (this) {
        KycStatus.pending => 'Pending',
        KycStatus.verified => 'Verified',
        KycStatus.rejected => 'Rejected',
      };
}
