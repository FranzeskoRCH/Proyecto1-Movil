import '../../domain/repositories/i_create_repository.dart';
import '../datasources/i_create_source.dart';

class CreateRepository implements ICreateRepository {
  final ICreateSource source;

  CreateRepository(this.source);

  @override
  Future<String> createProject({
    required String title,
    required String description,
    required String vision,
    required List<String> categories,
    required List<String> roles,
    required int vacancies,
    String? imageUrl,
  }) {
    return source.createProject(
      title: title,
      description: description,
      vision: vision,
      categories: categories,
      roles: roles,
      vacancies: vacancies,
      imageUrl: imageUrl,
    );
  }
}
