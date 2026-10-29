// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_purchased_chapter_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPurchasedChapterModelAdapter
    extends TypeAdapter<UserPurchasedChapterModel> {
  @override
  final int typeId = 4;

  @override
  UserPurchasedChapterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPurchasedChapterModel(
      lectures: (fields[0] as Map?)?.cast<String, UserPurchasedLectureModel>(),
      status: fields[1] as String?,
      purchaseDateTime: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPurchasedChapterModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.lectures)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.purchaseDateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPurchasedChapterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPurchasedLectureModelAdapter
    extends TypeAdapter<UserPurchasedLectureModel> {
  @override
  final int typeId = 5;

  @override
  UserPurchasedLectureModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPurchasedLectureModel(
      videos: (fields[0] as Map?)?.cast<String, UserPurchasedModel>(),
      status: fields[1] as String?,
      purchaseDateTime: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPurchasedLectureModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.videos)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.purchaseDateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPurchasedLectureModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
