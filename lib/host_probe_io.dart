import 'dart:io';

Future<bool> isReachable(String baseUrl) async {
  try {
    final uri = Uri.parse(baseUrl);
    if (uri.host.isEmpty) return false;
    final port = uri.hasPort ? uri.port : (uri.scheme == "https" ? 443 : 80);
    final socket = await Socket.connect(
      uri.host,
      port,
      timeout: const Duration(milliseconds: 1200),
    );
    await socket.close();
    return true;
  } catch (_) {
    return false;
  }
}
