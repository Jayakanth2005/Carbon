import 'package:hive/hive.dart';
part 'note_model.g.dart';

@HiveType(typeId: 2)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  String projectId;

  Note({required this.id, required this.content, required this.projectId});
}
