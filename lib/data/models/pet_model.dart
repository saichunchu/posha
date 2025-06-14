import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 0)
class Pet extends HiveObject {
  static const _uuid = Uuid();
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final bool isAdopted;

  @HiveField(6)
  final bool isFavorited;

  Pet({
    required this.id,
    required this.name,
    required this.age,
    required this.price,
    required this.imageUrl,
    this.isAdopted = false,
    this.isFavorited = false,
  });

  Pet copyWith({
    String? id,
    String? name,
    int? age,
    double? price,
    String? imageUrl,
    bool? isAdopted,
    bool? isFavorited,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAdopted: isAdopted ?? this.isAdopted,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id']?.toString().isNotEmpty == true
          ? json['id'].toString()
          : _uuid.v4(),
      name: json['name'] ?? 'Unknown',
      age: json['age'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isAdopted: json['isAdopted'] ?? false,
      isFavorited: json['isFavorited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'price': price,
      'imageUrl': imageUrl,
      'isAdopted': isAdopted,
      'isFavorited': isFavorited,
    };
  }
}
