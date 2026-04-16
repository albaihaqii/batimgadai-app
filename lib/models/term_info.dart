class TermCategory {
  final String categoryName;
  final List<TermItem> items;

  TermCategory({required this.categoryName, required this.items});
}

class TermItem {
  final String title;
  final String subtitle;
  final String detailContent;

  TermItem({
    required this.title,
    required this.subtitle,
    required this.detailContent,
  });
}
