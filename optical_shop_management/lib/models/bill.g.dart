// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 1;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String,
      customerPhone: fields[3] as String,
      items: (fields[4] as List).cast<LineItem>(),
      subtotal: fields[5] as double,
      specialDiscount: fields[6] as double,
      discountType: fields[7] as String,
      additionalDiscount: fields[8] as double,
      additionalDiscountType: fields[9] as String,
      totalAmount: fields[10] as double,
      paymentMethod: fields[11] as String,
      billingDate: fields[12] as DateTime,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.customerPhone)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.subtotal)
      ..writeByte(6)
      ..write(obj.specialDiscount)
      ..writeByte(7)
      ..write(obj.discountType)
      ..writeByte(8)
      ..write(obj.additionalDiscount)
      ..writeByte(9)
      ..write(obj.additionalDiscountType)
      ..writeByte(10)
      ..write(obj.totalAmount)
      ..writeByte(11)
      ..write(obj.paymentMethod)
      ..writeByte(12)
      ..write(obj.billingDate)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
