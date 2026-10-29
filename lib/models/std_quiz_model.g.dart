// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'std_quiz_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StdQuizModelAdapter extends TypeAdapter<StdQuizModel> {
  @override
  final int typeId = 3;

  @override
  StdQuizModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StdQuizModel(
      id: fields[0] as String,
      title: fields[1] as String,
      dateTime: fields[2] as DateTime,
      questionNums: fields[3] as int,
      triesNum: fields[7] as int,
      fullMark: fields[6] as int,
      degree: fields[4] as double,
      userAnsIdx:
          fields[5] == null ? {} : (fields[5] as Map).cast<String, dynamic>(),
      submitTime: fields[8] as DateTime?,
      status: fields[9] as String?,
      purchaseDateTime: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StdQuizModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.questionNums)
      ..writeByte(4)
      ..write(obj.degree)
      ..writeByte(5)
      ..write(obj.userAnsIdx)
      ..writeByte(6)
      ..write(obj.fullMark)
      ..writeByte(7)
      ..write(obj.triesNum)
      ..writeByte(8)
      ..write(obj.submitTime)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.purchaseDateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StdQuizModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
