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

- Flutter 3.47.0 y Dart 3.13.0, sobre NixOS mediante el `flake.nix`.
- `flutter_test` para widgets y controladores que necesitan el binding de
  Flutter.
- `test` 1.31.1 para pruebas unitarias puras.
- `integration_test` del SDK de Flutter para el flujo
  UI–controlador–repositorio.
- No se usa `mocktail`: los contratos son pequeños y los fakes locales hacen
  explícita la respuesta y los efectos secundarios.
- No se usa `flutter_driver`; `integration_test` cubre los flujos.

## Organización

```text
test/
  unit/core/       # DateLabels
  widget/          # formularios, validación y navegación
  features/        # controladores y fuentes por funcionalidad
  core/            # enlaces para compartir proyectos
integration_test/  # flujo de creación con repositorio aislado
.github/workflows/
  flutter-tests.yml       # análisis + unitarias/widget en cada push
  integration-tests.yml   # integración en emulador (manual)
```

## Ejecución local

Desde la raíz del proyecto:

```bash
nix develop --command flutter pub get
nix develop --command flutter analyze
nix develop --command flutter test
nix develop --command flutter test test/unit/
nix develop --command flutter test test/widget/
nix develop --command flutter test integration_test/app_test.dart -d <dispositivo>
```

La prueba de integración requiere un dispositivo o emulador compatible
(Android o iOS). Para un teléfono Android conectado por USB:

```bash
adb devices
nix develop --command flutter test integration_test/app_test.dart -d <serial>
```

La prueba usa el tamaño real de la pantalla del dispositivo: no fija
`setSurfaceSize`, desplaza el formulario hasta el botón y lo pulsa con una
llave estable (`create_submit`).

## CI

`.github/workflows/flutter-tests.yml` se ejecuta en cada `push` y
`pull_request` a `main` o `develop`:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test` (unitarias + widgets)

Un fallo de análisis o de pruebas hace fallar el job.

`.github/workflows/integration-tests.yml` ejecuta la prueba de integración en
un emulador Android de GitHub Actions. Se lanza manualmente
(`workflow_dispatch`) porque un emulador headless es lento y más frágil que el
job principal; para ejecutarlo en cada push, añada el evento `push` a su
sección `on`.

## NixOS y el SDK de solo lectura

El SDK de Flutter vive en `/nix/store`, que es de solo lectura. Gradle 9
rechaza configurar el plugin `:integration_test` si el directorio del proyecto
no es escribible. `android/settings.gradle.kts` detecta ese caso, copia el
plugin a `android/.gradle/readonly-plugins/` y reasigna su `projectDir`; en un
SDK escribible (CI, macOS, Windows) no hace nada.

Por la misma razón no se versionan `.android-sdk/` ni `platform-tools/`
(copias locales del SDK); están en `.gitignore`.

## Datos y aislamiento

Los tests crean sesiones, proyectos y tareas en memoria mediante fakes. Las
fuentes Roble no se invocan desde la suite automatizada. La prueba que valida
la construcción del SDK de Roble tampoco realiza una operación remota.

## Cómo añadir pruebas

Priorice reglas de negocio y estados de error. Use `test`, `group` y `expect`
para unidades puras; `testWidgets` y `WidgetTester` para renderizado e
interacciones; y `IntegrationTestWidgetsFlutterBinding` solo para recorridos
que combinen varias capas.

Los widgets que se prueban exponen llaves estables y las pruebas los buscan con
`find.byKey` en lugar de por tipo o posición:

- `login_email`, `login_password`, `login_submit`
- `create_title`, `create_description`, `create_vision`
- `create_role_input`, `create_role_add`, `create_submit`

Mantenga una dependencia falsa por prueba, limpie controladores GetX
(`Get.reset()`) y evite `pumpAndSettle` en animaciones continuas.

## Estado actual

- `flutter analyze`: correcto, sin issues.
- 54 pruebas unitarias + 6 de widgets: 60/60 correctas.
- Integración: 1/1 correcta en un teléfono Android real (verificado con
  `flutter test integration_test/app_test.dart -d <serial>`).
- CI principal: verde.
