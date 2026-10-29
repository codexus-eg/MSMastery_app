// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      ar_fname: fields[3] as String?,
      ar_sname: fields[4] as String?,
      ar_thname: fields[5] as String?,
      code: fields[6] as String?,
      fname: fields[0] as String?,
      grade: fields[10] as String?,
      phoneNum: fields[7] as String?,
      sname: fields[1] as String?,
      thname: fields[2] as String?,
      img: fields[8] as String?,
      balance: fields[9] as int?,
      password: fields[11] as String?,
      purchasedVideos: fields[12] == null
          ? {}
          : (fields[12] as Map?)?.cast<String, UserPurchasedChapterModel>(),
      parentPhoneNum: fields[19] as String?,
      purchasedPdfs: fields[13] == null
          ? {}
          : (fields[13] as Map?)?.map((dynamic k, dynamic v) => MapEntry(
              k as String,
              (v as Map).map((dynamic k, dynamic v) =>
                  MapEntry(k as String, (v as List).cast<String>())))),
      stdQuizes: fields[14] == null
          ? {}
          : (fields[14] as Map?)?.cast<String, StdQuizModel>(),
      groupId: fields[16] as String?,
      groupName: fields[15] as String?,
      enabled: fields[17] as bool?,
      isActive: fields[20] as bool?,
      pushToken: fields[18] as String?,
      gender: fields[23] as String?,
      walletBalanceStatus: fields[24] as String?,
      lastwalletBalanceTransaction: fields[25] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.fname)
      ..writeByte(1)
      ..write(obj.sname)
      ..writeByte(2)
      ..write(obj.thname)
      ..writeByte(3)
      ..write(obj.ar_fname)
      ..writeByte(4)
      ..write(obj.ar_sname)
      ..writeByte(5)
      ..write(obj.ar_thname)
      ..writeByte(6)
      ..write(obj.code)
      ..writeByte(7)
      ..write(obj.phoneNum)
      ..writeByte(8)
      ..write(obj.img)
      ..writeByte(9)
      ..write(obj.balance)
      ..writeByte(10)
      ..write(obj.grade)
      ..writeByte(11)
      ..write(obj.password)
      ..writeByte(12)
      ..write(obj.purchasedVideos)
      ..writeByte(13)
      ..write(obj.purchasedPdfs)
      ..writeByte(14)
      ..write(obj.stdQuizes)
      ..writeByte(15)
      ..write(obj.groupName)
      ..writeByte(16)
      ..write(obj.groupId)
      ..writeByte(17)
      ..write(obj.enabled)
      ..writeByte(18)
      ..write(obj.pushToken)
      ..writeByte(19)
      ..write(obj.parentPhoneNum)
      ..writeByte(20)
      ..write(obj.isActive)
      ..writeByte(23)
      ..write(obj.gender)
      ..writeByte(24)
      ..write(obj.walletBalanceStatus)
      ..writeByte(25)
      ..write(obj.lastwalletBalanceTransaction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
