import 'package:hive/hive.dart';
part 'complaint_model.g.dart';

@HiveType(typeId: 1)
class Complaint extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String projectId;

  @HiveField(4)
  String status;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    this.status = 'Pending',
  });
}
