import 'package:hive/hive.dart';
part 'tree_model.g.dart';

@HiveType(typeId: 0)
class Tree extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String species;

  @HiveField(2)
  double height;

  @HiveField(3)
  double dbh;

  @HiveField(4)
  bool isAlive;

  @HiveField(5)
  String plot;

  @HiveField(6)
  String photoPath;

  @HiveField(7)
  String comments;

  Tree({
    required this.id,
    required this.species,
    required this.height,
    required this.dbh,
    required this.isAlive,
    required this.plot,
    required this.photoPath,
    required this.comments,
  });
}
