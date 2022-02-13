
bool isLocalUrl(String url) {
  return url.startsWith('/') ||
      url.startsWith('file://') ||
      url.substring(1).startsWith(':\\');
}


