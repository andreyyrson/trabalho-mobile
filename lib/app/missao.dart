// Surprise mission driven by Remote Config, updated in real time on the
// installed APK (no rebuild/reinstall).
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class Missao {
  const Missao({required this.ativa, required this.estandeIds});
  final bool ativa;
  final Set<String> estandeIds;
}

// Local default: mission off, as the assignment requires.
final missao = ValueNotifier(const Missao(ativa: false, estandeIds: {}));

Future<void> iniciarMissao() async {
  final rc = FirebaseRemoteConfig.instance;
  await rc.setDefaults(const {'missao_ativa': false, 'missao_estandes': ''});
  await rc.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(minutes: 1),
  ));

  void ler() => missao.value = Missao(
        ativa: rc.getBool('missao_ativa'),
        // Console value: stand ids separated by commas, e.g. "E01,E03".
        estandeIds: rc
            .getString('missao_estandes')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toSet(),
      );

  rc.onConfigUpdated.listen((_) async {
    await rc.activate();
    ler();
  });

  try {
    await rc.fetchAndActivate();
  } catch (e) {
    debugPrint('Remote Config indisponível, usando padrão local: $e');
  }
  ler();
}
