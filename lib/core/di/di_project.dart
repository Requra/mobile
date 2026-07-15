import 'package:get_it/get_it.dart';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/features/add_project/data/datasource/add_project_remote_data_source.dart';
import 'package:requra/features/add_project/data/repositories/add_project_repository_impl.dart';
import 'package:requra/features/add_project/domain/repositories/add_project_repository.dart';
import 'package:requra/features/add_project/domain/usecases/create_project_usecase.dart';
import 'package:requra/features/add_project/presentation/cubit/add_project_cubit.dart';
import 'package:requra/features/project_view/data/datasource/project_remote_data_source.dart';
import 'package:requra/features/project_view/data/repositories/project_repository_impl.dart';
import 'package:requra/features/project_view/domain/repositories/project_repository.dart';
import 'package:requra/features/project_view/domain/usecases/project_usecases.dart';
import 'package:requra/features/project_view/presentation/cubit/project_cubit.dart';
import 'package:requra/features/auth/data/services/auth_service.dart';
import 'package:requra/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:requra/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:requra/features/profile/domain/repositories/profile_repository.dart';
import 'package:requra/features/profile/domain/usecases/profile_usecases.dart';
import 'package:requra/features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

void initProjectDI() {
  // Core
  if (!sl.isRegistered<ApiClient>()) {
    //one instance during the app when user request it
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  if (!sl.isRegistered<AuthService>()) {
    sl.registerLazySingleton<AuthService>(() => const AuthService());
  }

  // Cubit
  sl.registerFactory(() => ProjectCubit(
    //factory because everytime you open the screen you need new instance of cubit
        getProjectsUseCase: sl(),
        deleteProjectUseCase: sl(),
        editProjectUseCase: sl(),
      ));
      
  sl.registerFactory(() => AddProjectCubit(
        createProjectUseCase: sl(),
      ));

  sl.registerFactory(() => ProfileCubit(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        uploadAvatarUseCase: sl(),
        deleteAccountUseCase: sl(),
        changePasswordUseCase: sl(),
        logoutUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => EditProjectUseCase(sl()));
  
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProjectRepository>(
    //register interfaces not impl (will call it)
      () => ProjectRepositoryImpl(remoteDataSource: sl()));
      
  sl.registerLazySingleton<AddProjectRepository>(
      () => AddProjectRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  sl.registerLazySingleton<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(apiClient: sl()));
      
  sl.registerLazySingleton<AddProjectRemoteDataSource>(
      () => AddProjectRemoteDataSourceImpl(apiClient: sl()));

  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(authService: sl()));
}
