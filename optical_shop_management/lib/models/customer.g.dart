// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 0;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      age: fields[3] as int,
      prescriptionLeft: fields[4] as String?,
      prescriptionRight: fields[5] as String?,
      address: fields[6] as String?,
      firstVisit: fields[7] as DateTime,
      lastVisit: fields[8] as DateTime,
      totalVisits: fields[9] as int,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.prescriptionLeft)
      ..writeByte(5)
      ..write(obj.prescriptionRight)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.firstVisit)
      ..writeByte(8)
      ..write(obj.lastVisit)
      ..writeByte(9)
      ..write(obj.totalVisits)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
