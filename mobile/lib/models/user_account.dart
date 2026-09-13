class UserAccount {
  const UserAccount({
    required this.email,
    required this.name,
    this.phone = '',
  });

  final String email;
  final String name;
  final String phone;

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'phone': phone,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        email: json['email'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
      );

  UserAccount copyWith({String? name, String? phone}) => UserAccount(
        email: email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
      );
}
