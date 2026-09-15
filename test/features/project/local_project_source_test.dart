import 'package:flutter_test/flutter_test.dart';
import 'package:movil_proyecto/features/project/data/datasources/local/local_project_source.dart';
import 'package:movil_proyecto/features/project/domain/models/application_status.dart';

void main() {
  late LocalProjectSource source;

  setUp(() => source = LocalProjectSource());

  test('getAppliedProjects devuelve las postulaciones con su estado', () async {
    final projects = await source.getAppliedProjects();

    expect(projects, isNotEmpty);
    expect(
      projects.map((project) => project.status),
      contains(ApplicationStatus.accepted),
    );
  });

  test('getCreatedProjects devuelve los proyectos propios', () async {
    final projects = await source.getCreatedProjects();

    expect(projects, isNotEmpty);
    expect(projects.first.pendingApplicants, isNotEmpty);
    expect(projects.first.teamMembers, isNotEmpty);
  });

  test('acceptApplicant mueve al postulante al equipo', () async {
    final project = (await source.getCreatedProjects()).first;
    final pending = project.pendingApplicants.first;

    await source.acceptApplicant(project.id, pending.id);

    final updated = await source.getCreatedProjectById(project.id);
    expect(updated.teamMembers.any((member) => member.id == pending.id), isTrue);
    expect(
      updated.pendingApplicants.any((applicant) => applicant.id == pending.id),
      isFalse,
    );
  });

  test('rejectApplicant saca al postulante de pendientes', () async {
    final project = (await source.getCreatedProjects()).first;
    final pending = project.pendingApplicants.first;

    await source.rejectApplicant(project.id, pending.id);

    final updated = await source.getCreatedProjectById(project.id);
    expect(
      updated.pendingApplicants.any((applicant) => applicant.id == pending.id),
      isFalse,
    );
  });

  test('removeMember saca al integrante del equipo', () async {
    final project = (await source.getCreatedProjects()).first;
    final removed = project.teamMembers.first;

    await source.removeMember(project.id, removed.id);

    final updated = await source.getCreatedProjectById(project.id);
    expect(
      updated.teamMembers.any((member) => member.id == removed.id),
      isFalse,
    );
  });
}
