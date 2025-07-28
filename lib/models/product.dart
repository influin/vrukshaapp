class Product {
  final String id;
  final String name;
  final List<String> images;
  final Category category;
  final String description;
  final List<Variation> variations;

  Product({
    required this.id,
    required this.name,
    required this.images,
    required this.category,
    required this.description,
    required this.variations,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      category: Category.fromJson(json['category']),
      description: json['description'],
      variations: (json['variation'] as List)
          .map((v) => Variation.fromJson(v))
          .toList(),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class Variation {
  final String weight;
  final double price;
  final int pcs;
  final String id;

  Variation({
    required this.weight,
    required this.price,
    required this.pcs,
    required this.id,
  });

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      weight: json['weight'],
      price: json['price'].toDouble(),
      pcs: json['pcs'],
      id: json['_id'],
    );
  }
}