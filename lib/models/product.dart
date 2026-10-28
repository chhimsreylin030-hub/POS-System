// US-004, US-005, US-009, US-010, US-011, US-016, US-017

enum ProductStatus { active, inactive, lowStock, outOfStock }

class CategoryItem {
  final String id;
  final String name;
  final String khmerName;
  final String icon;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.khmerName,
    required this.icon,
  });
}

class ProductItem {
  final String id;
  final String name;
  final String khmerName;
  final String categoryId;
  final String barcode;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String imageUrl;
  final ProductStatus status;

  ProductItem({
    required this.id,
    required this.name,
    required this.khmerName,
    required this.categoryId,
    required this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.lowStockThreshold = 10,
    required this.imageUrl,
    this.status = ProductStatus.active,
  });

  bool get isLowStock => stockQuantity <= lowStockThreshold && stockQuantity > 0;
  bool get isOutOfStock => stockQuantity <= 0;

  ProductStatus get computedStatus {
    if (status == ProductStatus.inactive) return ProductStatus.inactive;
    if (isOutOfStock) return ProductStatus.outOfStock;
    if (isLowStock) return ProductStatus.lowStock;
    return ProductStatus.active;
  }

  ProductItem copyWith({
    String? id,
    String? name,
    String? khmerName,
    String? categoryId,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    String? imageUrl,
    ProductStatus? status,
  }) {
    return ProductItem(
      id: id ?? this.id,
      name: name ?? this.name,
      khmerName: khmerName ?? this.khmerName,
      categoryId: categoryId ?? this.categoryId,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }
}
