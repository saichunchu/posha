import 'package:hive/hive.dart';
import 'pet_model.dart';

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 0;

  @override
  Pet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Pet(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      price: fields[3] as double,
      imageUrl: fields[4] as String,
      isAdopted: fields[5] as bool,
      isFavorited: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.isAdopted)
      ..writeByte(6)
      ..write(obj.isFavorited);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
