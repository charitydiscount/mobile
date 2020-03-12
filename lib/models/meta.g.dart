// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwoPerformantMeta _$TwoPerformantMetaFromJson(Map<String, dynamic> json) {
  return TwoPerformantMeta(
    uniqueCode: json['uniqueCode'] as String,
    percentage: (json['percentage'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$TwoPerformantMetaToJson(TwoPerformantMeta instance) =>
    <String, dynamic>{
      'uniqueCode': instance.uniqueCode,
      'percentage': instance.percentage,
    };
