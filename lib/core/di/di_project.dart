import 'package:get_it/get_it.dart';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/features/project_view/data/datasource/project_remote_data_source.dart';
import 'package:requra/features/project_view/data/repositories/project_repository_impl.dart';
import 'package:requra/features/project_view/domain/repositories/project_repository.dart';
import 'package:requra/features/project_view/domain/usecases/project_usecases.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';

final sl = GetIt.instance;

void initProjectDI() {
  // Core
  if (!sl.isRegistered<ApiClient>()) {
    //one instance during the app when user request it
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // Cubit
  sl.registerFactory(() => ProjectCubit(
    //factory because everytime you open the screen you need new instance of cubit
        getProjectsUseCase: sl(),
        deleteProjectUseCase: sl(),
        editProjectUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => EditProjectUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProjectRepository>(
    //register interfaces not impl (will call it)
      () => ProjectRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  sl.registerLazySingleton<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(apiClient: sl()));
}
