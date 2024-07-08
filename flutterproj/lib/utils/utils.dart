bool isUrl(String url) {
  try {
    Uri.parse(url);
    return true;
  } on FormatException {
    return false;
  }
}
