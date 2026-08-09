import 'package:get_it/get_it.dart';
import 'package:requra/core/api/api_client.dart';
import 'package:requra/features/add_project/data/datasource/add_project_remote_data_source.dart';
import 'package:requra/features/add_project/data/repositories/add_project_repository_impl.dart';
import 'package:requra/features/add_project/domain/repositories/add_project_repository.dart';
import 'package:requra/features/add_project/domain/usecases/create_project_usecase.dart';
import 'package:requra/features/add_project/domain/usecases/get_ai_run_progress_usecase.dart';
import 'package:requra/features/add_project/domain/usecases/upload_and_generate_usecase.dart';
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
import 'package:requra/features/result_view/data/datasource/result_view_remote_data_source.dart';
import 'package:requra/features/result_view/data/repositories/result_view_repository_impl.dart';
import 'package:requra/features/result_view/domain/repositories/result_view_repository.dart';
import 'package:requra/features/result_view/domain/usecases/result_view_usecases.dart';
import 'package:requra/features/result_view/presentation/cubit/result_view_cubit.dart';

import 'package:requra/features/meeting/data/datasource/meeting_remote_data_source.dart';
import 'package:requra/features/meeting/data/repositories/meeting_repository_impl.dart';
import 'package:requra/features/meeting/domain/repositories/meeting_repository.dart';
import 'package:requra/features/meeting/domain/usecases/create_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_meeting_details_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_meeting_invitations_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_project_meetings_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/get_project_members_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/invite_guests_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/invite_participants_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/resend_invitation_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/update_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/cancel_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/start_meeting_usecase.dart';
import 'package:requra/features/meeting/domain/usecases/end_meeting_usecase.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_cubit.dart';
import 'package:requra/features/meeting/presentation/cubit/meeting_invite_cubit.dart';

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
        getProjectByIdUseCase: sl(),
      ));
      
  sl.registerFactory(() => AddProjectCubit(
        createProjectUseCase: sl(),
        uploadAndGenerateUseCase: sl(),
        getAiRunProgressUseCase: sl(),
      ));

  sl.registerFactory(() => ProfileCubit(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        uploadAvatarUseCase: sl(),
        deleteAccountUseCase: sl(),
        changePasswordUseCase: sl(),
        logoutUseCase: sl(),
      ));

  sl.registerFactory(() => ResultViewCubit(
        getProjectDetailsUseCase: sl(),
        getProjectDocumentsUseCase: sl(),
        getAiResultsDashboardUseCase: sl(),
        uploadDocumentUseCase: sl(),
      ));

  sl.registerFactory(() => MeetingCubit(
        getProjectMeetingsUseCase: sl(),
        getMeetingDetailsUseCase: sl(),
        createMeetingUseCase: sl(),
        updateMeetingUseCase: sl(),
        cancelMeetingUseCase: sl(),
        startMeetingUseCase: sl(),
        endMeetingUseCase: sl(),
      ));

  sl.registerFactory(() => MeetingInviteCubit(
        getProjectMembersUseCase: sl(),
        getMeetingInvitationsUseCase: sl(),
        inviteParticipantsUseCase: sl(),
        inviteGuestsUseCase: sl(),
        resendInvitationUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => GetProjectsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProjectUseCase(sl()));
  sl.registerLazySingleton(() => EditProjectUseCase(sl()));
  
  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => UploadAndGenerateUseCase(sl()));
  sl.registerLazySingleton(() => GetAiRunProgressUseCase(sl()));

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => GetProjectByIdUseCase(sl()));

  sl.registerLazySingleton(() => GetProjectDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => GetAiResultsDashboardUseCase(sl()));
  sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));

  sl.registerLazySingleton(() => GetProjectMeetingsUseCase(sl()));
  sl.registerLazySingleton(() => GetMeetingDetailsUseCase(sl()));
  sl.registerLazySingleton(() => CreateMeetingUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMeetingUseCase(sl()));
  sl.registerLazySingleton(() => CancelMeetingUseCase(sl()));
  sl.registerLazySingleton(() => StartMeetingUseCase(sl()));
  sl.registerLazySingleton(() => EndMeetingUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectMembersUseCase(sl()));
  sl.registerLazySingleton(() => GetMeetingInvitationsUseCase(sl()));
  sl.registerLazySingleton(() => InviteParticipantsUseCase(sl()));
  sl.registerLazySingleton(() => InviteGuestsUseCase(sl()));
  sl.registerLazySingleton(() => ResendInvitationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProjectRepository>(
    //register interfaces not impl (will call it)
      () => ProjectRepositoryImpl(remoteDataSource: sl()));
      
  sl.registerLazySingleton<AddProjectRepository>(
      () => AddProjectRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<ResultViewRepository>(
      () => ResultViewRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<MeetingRepository>(
      () => MeetingRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  sl.registerLazySingleton<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(apiClient: sl()));
      
  sl.registerLazySingleton<AddProjectRemoteDataSource>(
      () => AddProjectRemoteDataSourceImpl(apiClient: sl()));

  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(authService: sl()));

  sl.registerLazySingleton<ResultViewRemoteDataSource>(
      () => ResultViewRemoteDataSourceImpl(apiClient: sl()));

  sl.registerLazySingleton<MeetingRemoteDataSource>(
      () => MeetingRemoteDataSourceImpl(apiClient: sl()));
}

