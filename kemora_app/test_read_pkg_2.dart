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
    var libPath = path + '/lib/google_sign_in.dart';
    if (File(libPath).existsSync()) {
       final lines = await File(libPath).readAsLines();
       for(int i=250; i<320; i++) {
         if (i < lines.length) print(lines[i]);
       }
    }
  }
}
