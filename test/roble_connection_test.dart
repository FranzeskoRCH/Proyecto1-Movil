import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/core/roble_constants.dart';
import 'package:roble/roble.dart';

void main() {
  test('SDK oficial roble se instancia correctamente con fromContract', () {
    final roble = RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: RobleConstants.baseUrl,
        contractId: RobleConstants.contractId,
      ),
    );

    expect(roble, isNotNull);
    expect(roble.isLoggedIn, isFalse);
  });
}
