import 'package:circuito_descobertas/shared/estande.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QR gerado pelo painel é lido de volta pelo app', () {
    expect(estandeIdFromQr(qrPayload('aB3_x-9')), 'aB3_x-9');
  });

  test('QR de outra origem ou com id malformado é inválido', () {
    expect(estandeIdFromQr('https://exemplo.com'), isNull);
    expect(estandeIdFromQr('circuito:'), isNull);
    expect(estandeIdFromQr('circuito:a/b'), isNull);
  });

  test('chave de check-in combina visitante e estande', () {
    expect(checkinId('uid1', 'E01'), 'uid1_E01');
  });
}
