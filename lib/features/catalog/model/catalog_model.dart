import 'package:json_annotation/json_annotation.dart';

part 'catalog_model.g.dart';

enum ProductCategory { base, wall, tall, island }

extension ProductCategoryX on ProductCategory {
  /// Exact string the backend expects/returns (case-sensitive).
  String get value => switch (this) {
    .base => 'Base',
    .wall => 'Wall',
    .tall => 'Tall',
    .island => 'Island',
  };

  String get label => value;

  static ProductCategory fromValue(String value) => switch (value) {
    'Base' => .base,
    'Wall' => .wall,
    'Tall' => .tall,
    'Island' => .island,
    _ => throw ArgumentError('Unknown product category: $value'),
  };
}

String _categoryToJson(ProductCategory category) => category.value;

/// Accepts images as plain URL strings or as objects with a `url` key.
List<String> _imagesFromJson(Object? json) => [
  for (final item in (json as List? ?? const []))
    if (item is String)
      item
    else if (item is Map && item['url'] is String)
      item['url'] as String,
];

/// A single catalog item (cabinet SKU).
/// Unknown keys (`ownerId`, `createdAt`, `__v`, ...) are ignored on purpose.
@JsonSerializable(checked: true)
class CatalogModel {
  @JsonKey(name: '_id', required: true, disallowNullValue: true)
  final String id;

  @JsonKey(required: true, disallowNullValue: true)
  final String sku;

  @JsonKey(required: true, disallowNullValue: true)
  final String name;

  @JsonKey(
    required: true,
    disallowNullValue: true,
    fromJson: ProductCategoryX.fromValue,
    toJson: _categoryToJson,
  )
  final ProductCategory category;

  @JsonKey(required: true, disallowNullValue: true)
  final String finish;

  @JsonKey(required: true, disallowNullValue: true)
  final double price;

  @JsonKey(required: true, disallowNullValue: true)
  final bool isActive;

  @JsonKey(required: true, disallowNullValue: true)
  final double width;

  @JsonKey(required: true, disallowNullValue: true)
  final double height;

  @JsonKey(required: true, disallowNullValue: true)
  final double depth;
  final String? description;

  @JsonKey(fromJson: _imagesFromJson)
  final List<String> images;

  /// Width×height×depth, e.g. `36×34.5×24`. The backend sends no unit.
  String get dimensions => '${_fmt(width)}×${_fmt(height)}×${_fmt(depth)}';

  static String _fmt(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

  /// First image, if any; used as the product card thumbnail.
  String? get imageUrl => images.isEmpty ? null : images.first;

  const CatalogModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.finish,
    required this.price,
    required this.isActive,
    required this.width,
    required this.height,
    required this.depth,
    this.description,
    this.images = const [],
  });

  factory CatalogModel.fromJson(Map<String, dynamic> json) =>
      _$CatalogModelFromJson(json);

  Map<String, dynamic> toJson() => _$CatalogModelToJson(this);
}
