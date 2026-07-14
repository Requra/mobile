import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String email;
  final String jobTitle;
  final String avatarUrl;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.jobTitle,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, email, jobTitle, avatarUrl];
}
