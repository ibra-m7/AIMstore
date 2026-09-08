import 'package:equatable/equatable.dart';

/// ملخص منتج الهدية المرتبط بمنتج أساسي.
class ProductGiftSummary extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final bool isAvailable;

  const ProductGiftSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isAvailable = true,
  });

  String get displayImage => imageUrl.trim();

  @override
  List<Object?> get props => [id, name, imageUrl, isAvailable];
}
