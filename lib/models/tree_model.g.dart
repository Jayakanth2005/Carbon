// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TreeAdapter extends TypeAdapter<Tree> {
  @override
  final int typeId = 0;

  @override
  Tree read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tree(
      id: fields[0] as String,
      species: fields[1] as String,
      height: fields[2] as double,
      dbh: fields[3] as double,
      isAlive: fields[4] as bool,
      plot: fields[5] as String,
      photoPath: fields[6] as String,
      comments: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Tree obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.species)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.dbh)
      ..writeByte(4)
      ..write(obj.isAlive)
      ..writeByte(5)
      ..write(obj.plot)
      ..writeByte(6)
      ..write(obj.photoPath)
      ..writeByte(7)
      ..write(obj.comments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
