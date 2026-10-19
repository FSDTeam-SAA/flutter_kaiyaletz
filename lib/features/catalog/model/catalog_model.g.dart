// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogModel _$CatalogModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CatalogModel', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          '_id',
          'sku',
          'name',
          'category',
          'finish',
          'price',
          'isActive',
          'width',
          'height',
          'depth',
        ],
        disallowNullValues: const [
          '_id',
          'sku',
          'name',
          'category',
          'finish',
          'price',
          'isActive',
          'width',
          'height',
          'depth',
        ],
      );
      final val = CatalogModel(
        id: $checkedConvert('_id', (v) => v as String),
        sku: $checkedConvert('sku', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        category: $checkedConvert(
          'category',
          (v) => ProductCategoryX.fromValue(v as String),
        ),
        finish: $checkedConvert('finish', (v) => v as String),
        price: $checkedConvert('price', (v) => (v as num).toDouble()),
        isActive: $checkedConvert('isActive', (v) => v as bool),
        width: $checkedConvert('width', (v) => (v as num).toDouble()),
        height: $checkedConvert('height', (v) => (v as num).toDouble()),
        depth: $checkedConvert('depth', (v) => (v as num).toDouble()),
        description: $checkedConvert('description', (v) => v as String?),
        images: $checkedConvert(
          'images',
          (v) => v == null ? const [] : _imagesFromJson(v),
        ),
      );
      return val;
    }, fieldKeyMap: const {'id': '_id'});

Map<String, dynamic> _$CatalogModelToJson(CatalogModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'category': _categoryToJson(instance.category),
      'finish': instance.finish,
      'price': instance.price,
      'isActive': instance.isActive,
      'width': instance.width,
      'height': instance.height,
      'depth': instance.depth,
      'description': instance.description,
      'images': instance.images,
    };
