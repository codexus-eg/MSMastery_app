// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_purchase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPurchasedModelAdapter extends TypeAdapter<UserPurchasedModel> {
  @override
  final int typeId = 2;

  @override
  UserPurchasedModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPurchasedModel(
      vidId: fields[0] as String?,
      stdWatches: fields[1] as int?,
      avaWatches: fields[2] as int?,
      dateTime: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPurchasedModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.vidId)
      ..writeByte(1)
      ..write(obj.stdWatches)
      ..writeByte(2)
      ..write(obj.avaWatches)
      ..writeByte(3)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPurchasedModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
