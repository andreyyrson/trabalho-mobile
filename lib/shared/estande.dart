// Shared by the visitor app and the admin panel: stand model, Firestore
// collections and the QR payload format.
import 'package:cloud_firestore/cloud_firestore.dart';

class Estande {
  const Estande({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.localizacao,
    required this.ativo,
  });

  final String id;
  final String nome;
  final String descricao;
  final String localizacao;
  final bool ativo;

  factory Estande.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Estande(
      id: doc.id,
      nome: d['nome'] as String? ?? '',
      descricao: d['descricao'] as String? ?? '',
      localizacao: d['localizacao'] as String? ?? '',
      ativo: d['ativo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'descricao': descricao,
        'localizacao': localizacao,
        'ativo': ativo,
      };
}

final estandesRef = FirebaseFirestore.instance.collection('estandes');
final checkinsRef = FirebaseFirestore.instance.collection('checkins');

// Prefix tells our QR codes apart from any other QR the visitor might scan.
const _qrPrefix = 'circuito:';
final _idValido = RegExp(r'^[A-Za-z0-9_-]{1,100}$');

String qrPayload(String estandeId) => '$_qrPrefix$estandeId';

/// Stand id encoded in [raw], or null when the QR is not one of ours.
String? estandeIdFromQr(String raw) {
  if (!raw.startsWith(_qrPrefix)) return null;
  final id = raw.substring(_qrPrefix.length);
  return _idValido.hasMatch(id) ? id : null;
}

/// One check-in per visitor per stand: the doc id itself prevents duplicates.
String checkinId(String visitanteId, String estandeId) =>
    '${visitanteId}_$estandeId';
