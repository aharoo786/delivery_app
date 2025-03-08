extension StringFormatter on String {
  String toFormattedString() {
    return split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
