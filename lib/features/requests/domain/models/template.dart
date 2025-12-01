/// Modelo de plantilla de solicitud
class Template {
  final String id;
  final String name;
  final String origin;
  final String destination;
  final int totalArticles;
  final double totalWeight;
  final List<TemplateItem> items;

  const Template({
    required this.id,
    required this.name,
    required this.origin,
    required this.destination,
    required this.totalArticles,
    required this.totalWeight,
    required this.items,
  });
}

/// Item de una plantilla
class TemplateItem {
  final String name;
  final int quantity;
  final bool isFragile;

  const TemplateItem({
    required this.name,
    required this.quantity,
    required this.isFragile,
  });
}
