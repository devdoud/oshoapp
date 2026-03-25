import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId = '',
    required this.isFeatured,
  });

  /// Empty Helper Function
  static CategoryModel empty() =>
      CategoryModel(id: '', name: '', image: '', isFeatured: false);

  /// Convert model to Json structure so that you can store data in Firebase/NodeJS
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Image': image,
      'ParentId': parentId,
      'IsFeatured': isFeatured,
    };
  }

  /// Map Json oriented document snapshot from Firebase to Model
  factory CategoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return CategoryModel(
        id: document.id,
        name: data['Name'] ?? '',
        image: data['Image'] ?? '',
        parentId: data['ParentId'] ?? '',
        isFeatured: data['IsFeatured'] ?? false,
      );
    } else {
      return CategoryModel.empty();
    }
  }

  /// Map Json document from NodeJS/API to Model
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Handle multilingual name format: {fr: "...", en: "..."}
    String parseName(dynamic nameData) {
      if (nameData is String) {
        return nameData;
      } else if (nameData is Map) {
        // Try to get current locale, fallback to French, then English, then first available
        try {
          final locale = Get.locale?.languageCode ?? 'fr';
          return nameData[locale] ??
              nameData['fr'] ??
              nameData['en'] ??
              nameData.values.first ??
              '';
        } catch (e) {
          // Fallback if Get is not initialized
          return nameData['fr'] ??
              nameData['en'] ??
              nameData.values.first ??
              '';
        }
      }
      return '';
    }

    return CategoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: parseName(json['name']),
      image: (() {
        var img = json['image'];
        if (img is String && img.trim().startsWith('{')) {
          try {
            var parsed = jsonDecode(img);
            if (parsed is Map && parsed['url'] != null) {
              return parsed['url'].toString();
            }
          } catch (_) {}
        }
        if (img is Map) {
          return img['url']?.toString() ?? '';
        }
        return img ?? '';
      })(),
      parentId: json['parent_id'] ??
          json['parentId'] ??
          '', // Support snake_case ET camelCase
      isFeatured: json['is_featured'] ??
          json['isFeatured'] ??
          json['isActive'] ??
          false, // Support snake_case ET camelCase
    );
  }
}
