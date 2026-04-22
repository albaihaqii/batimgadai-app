class TermCategory {
  final String label;
  final List<TermItem> items;

  const TermCategory(this.label, this.items);
}

class TermItem {
  final String icon;
  final String title;
  final String subtitle;
  final List<TermPara> paragraphs;

  const TermItem(this.icon, this.title, this.subtitle, this.paragraphs);
}

class TermPara {
  final String text;
  final bool numbered;

  const TermPara(this.text, this.numbered);
}
