// Validates a scanned QR and records the visit once per visitor and stand.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shared/estande.dart';

enum CheckinResultado { sucesso, qrInvalido, estandeInativo, jaRegistrado }

/// [estande] is the stand name when it could be read.
typedef Checkin = ({CheckinResultado resultado, String? estande});

Future<Checkin> registrarCheckin(String rawQr) async {
  final estandeId = estandeIdFromQr(rawQr);
  if (estandeId == null) return (resultado: CheckinResultado.qrInvalido, estande: null);

  final DocumentSnapshot<Map<String, dynamic>> doc;
  try {
    doc = await estandesRef.doc(estandeId).get();
  } on FirebaseException catch (e) {
    // The rules hide inactive stands from visitors, so a denied read
    // means the stand exists but is inactive.
    if (e.code == 'permission-denied') {
      return (resultado: CheckinResultado.estandeInativo, estande: null);
    }
    rethrow;
  }
  if (!doc.exists) return (resultado: CheckinResultado.qrInvalido, estande: null);
  final estande = Estande.fromDoc(doc);
  if (!estande.ativo) return (resultado: CheckinResultado.estandeInativo, estande: estande.nome);

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final ref = checkinsRef.doc(checkinId(uid, estandeId));
  final criado = await FirebaseFirestore.instance.runTransaction((tx) async {
    if ((await tx.get(ref)).exists) return false;
    tx.set(ref, {
      'visitanteId': uid,
      'estandeId': estandeId,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    return true;
  });
  if (!criado) return (resultado: CheckinResultado.jaRegistrado, estande: estande.nome);

  await FirebaseAnalytics.instance.logEvent(
    name: 'checkin_concluido',
    parameters: {'estande_id': estandeId},
  );
  return (resultado: CheckinResultado.sucesso, estande: estande.nome);
}
