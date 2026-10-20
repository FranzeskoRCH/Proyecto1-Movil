# Estrategia de pruebas

## Alcance

La suite cubre la lógica de dominio, controladores GetX, fuentes locales y
los recorridos de interfaz más importantes de Nexus. Las pruebas no usan
credenciales, red ni datos de producción.

## Arquitectura detectada

La aplicación está organizada por funcionalidades (`auth`, `create`,
`explore`, `home`, `profile`, `project` y `workspace`). Cada funcionalidad
separa modelos/repositorios en `domain`, implementaciones y fuentes en `data`,
y controladores/pantallas en `ui`. GetX proporciona la inyección de
dependencias, estado reactivo y navegación. Roble es la fuente remota; las
pruebas usan repositorios falsos o fuentes locales.

## Herramientas

- Flutter 3.47.0 y Dart 3.13.0.
- `flutter_test` para widgets y controladores que necesitan el binding de
  Flutter.
- `test` 1.31.1 para pruebas unitarias puras.
- `integration_test` del SDK de Flutter para el flujo UI–controlador–repositorio.
- No se usa `mocktail`: los contratos son pequeños y los fakes locales hacen
  explícita la respuesta y los efectos secundarios.
- No se usa `flutter_driver`; el proyecto no lo utilizaba y
  `integration_test` cubre los nuevos flujos.

## Organización

```text
test/
  unit/core/       # DateLabels y enlaces de proyecto
  widget/          # formularios y validación visual
  features/        # pruebas existentes de controladores y fuentes
integration_test/  # flujo de creación con repositorio aislado
.github/workflows/flutter-tests.yml
```

## Ejecución local

Desde la raíz del proyecto:

```bash
flutter pub get
flutter analyze
flutter test
flutter test test/unit/
flutter test test/widget/
flutter test integration_test/app_test.dart -d <dispositivo>
```

La prueba de integración requiere un dispositivo o emulador compatible. La
ejecución web no es compatible con `integration_test`; Windows necesita el
toolchain de Visual Studio. En el entorno auditado, Windows no tenía ese
toolchain y Chrome informó que las pruebas de integración web aún no están
soportadas, por lo que la integración queda implementada pero pendiente de un
dispositivo compatible.

## CI

`.github/workflows/flutter-tests.yml` ejecuta en cada `push` y `pull_request`
a `main` o `develop`:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`

La integración no se fuerza en un runner headless sin dispositivo. Para
habilitarla, añada un job con un emulador Android/iOS o un runner Windows con
Visual Studio y ejecute el comando anterior con su identificador de
dispositivo. Un fallo de análisis o de pruebas hace fallar el job principal.

## Datos y aislamiento

Los tests crean sesiones, proyectos y tareas en memoria mediante fakes. Las
fuentes Roble no se invocan desde la suite automatizada. Las pruebas existentes
que validan la construcción del SDK de Roble tampoco realizan una operación
remota.

## Cómo añadir pruebas

Priorice reglas de negocio y estados de error. Use `test`, `group` y `expect`
para unidades puras; `testWidgets` y `WidgetTester` para renderizado e
interacciones; y `IntegrationTestWidgetsFlutterBinding` solo para recorridos
que combinen varias capas. Mantenga una dependencia falsa por prueba, limpie
controladores GetX y evite `pumpAndSettle` en animaciones continuas.

## Resultado de la auditoría actual

- `flutter pub get`: correcto.
- `flutter analyze`: correcto, sin issues.
- Pruebas unitarias y de widgets nuevas: 7/7 correctas (3 unitarias y 4 de
  widgets; la suite focalizada incluye además los tests existentes ubicados en
  esas carpetas).
- La integración fue cargada, pero no pudo ejecutarse: Windows carece del
  toolchain de Visual Studio y Chrome no soporta `integration_test`.
- Suite completa: 59/59 pruebas correctas.
