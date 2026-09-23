import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/features/project/domain/models/applicant.dart';
import 'package:movil_proyecto/features/project/domain/models/application_status.dart';

void main() {
  test('Applicant status flags work correctly', () {
    final pending = Applicant(
      id: '1',
      name: 'Test',
      avatarUrl: '',
      career: 'Ingeniería',
      requestedRole: 'Dev',
      status: ApplicationStatus.underReview,
    );
    expect(pending.isPending, isTrue);
    expect(pending.isAccepted, isFalse);

    final accepted = Applicant(
      id: '2',
      name: 'Test',
      avatarUrl: '',
      career: 'Ingeniería',
      requestedRole: 'Dev',
      status: ApplicationStatus.accepted,
    );
    expect(accepted.isPending, isFalse);
    expect(accepted.isAccepted, isTrue);
  });
}
