import 'package:flutter/material.dart';

enum CatalogCategoryStatus { active, soon }

class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.status,
    this.count,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final CatalogCategoryStatus status;
  final int? count;
}

const catalogCategories = [
  CatalogCategory(
    id: 'telefon',
    label: 'Telefon',
    description: 'Akıllı telefon · teknik puan · kıyas',
    icon: Icons.smartphone_rounded,
    status: CatalogCategoryStatus.active,
  ),
  CatalogCategory(
    id: 'tablet',
    label: 'Tablet',
    description: 'iPad, Galaxy Tab ve diğer tabletler',
    icon: Icons.tablet_rounded,
    status: CatalogCategoryStatus.soon,
  ),
  CatalogCategory(
    id: 'bilgisayar',
    label: 'Bilgisayar',
    description: 'Dizüstü, masaüstü, mini PC',
    icon: Icons.laptop_mac_rounded,
    status: CatalogCategoryStatus.soon,
  ),
  CatalogCategory(
    id: 'akilli-saat',
    label: 'Akıllı saat',
    description: 'Apple Watch, Galaxy Watch',
    icon: Icons.watch_rounded,
    status: CatalogCategoryStatus.soon,
  ),
  CatalogCategory(
    id: 'kulaklik',
    label: 'Kulaklık',
    description: 'Kablosuz ve kablolu',
    icon: Icons.headphones_rounded,
    status: CatalogCategoryStatus.soon,
  ),
  CatalogCategory(
    id: 'tv',
    label: 'Televizyon',
    description: 'Smart TV',
    icon: Icons.tv_rounded,
    status: CatalogCategoryStatus.soon,
  ),
];

CatalogCategory catalogCategoryById(String id) {
  return catalogCategories.firstWhere((c) => c.id == id, orElse: () => catalogCategories.first);
}
