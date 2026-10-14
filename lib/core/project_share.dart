import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Base de los enlaces compartibles de un proyecto.
///
/// Es un marcador de posición: cuando exista una web pública de Nexus, este
/// dominio/enrutador debe apuntar a la página del proyecto.
const String projectLinkBase = 'https://nexus-app.uninorte.edu.co/proyecto';

/// Construye el enlace público de un proyecto.
String projectShareLink(String projectId) => '$projectLinkBase/$projectId';

/// Construye el texto que se comparte para un proyecto.
String buildProjectShareMessage({
  required String projectId,
  required String title,
  String description = '',
}) {
  final message = StringBuffer()
    ..writeln('¡Mira este proyecto en Nexus! 🚀')
    ..writeln()
    ..writeln('"$title"');
  if (description.trim().isNotEmpty) {
    message
      ..writeln()
      ..writeln(description.trim());
  }
  message
    ..writeln()
    ..writeln(projectShareLink(projectId));
  return message.toString();
}

/// Abre el diálogo nativo de compartir con los datos de un proyecto.
Future<void> shareProject(
  BuildContext context, {
  required String projectId,
  required String title,
  String description = '',
}) async {
  final text = buildProjectShareMessage(
    projectId: projectId,
    title: title,
    description: description,
  );

  // En tablets el share sheet necesita una posición de origen.
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: 'Proyecto en Nexus: $title',
      sharePositionOrigin:
          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    ),
  );
}
