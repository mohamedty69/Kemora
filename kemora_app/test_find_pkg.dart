import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('.dart_tool/package_config.json');
  final config = jsonDecode(await file.readAsString());
  final packages = config['packages'];
  final pkg = packages.firstWhere((p) => p['name'] == 'google_sign_in', orElse: () => null);
  if (pkg != null) {
    var uri = Uri.parse(pkg['rootUri']);
    var path = uri.toFilePath();
    print('Path: $path');
    var libPath = path + '/lib/google_sign_in.dart';
    if (File(libPath).existsSync()) {
       print(await File(libPath).readAsString());
    } else {
       print('lib/google_sign_in.dart not found at $libPath');
    }
  } else {
    print('Package not found');
  }
}
