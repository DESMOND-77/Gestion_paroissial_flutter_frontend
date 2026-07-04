import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/auth_model.dart';
import '../../../data/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  const AuthPasswordResetRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthUserProfileRefreshed extends AuthEvent {
  const AuthUserProfileRefreshed();
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

class AuthProfileUpdated extends AuthEvent {
  final Map<String, dynamic> data;
  const AuthProfileUpdated({required this.data});
  @override
  List<Object?> get props => [data];
}

class AuthProfilePictureUpdated extends AuthEvent {
  final String filePath;
  const AuthProfilePictureUpdated({required this.filePath});
  @override
  List<Object?> get props => [filePath];
}

class AuthBaseUrlUpdated extends AuthEvent {
  final String baseUrl;
  const AuthBaseUrlUpdated({required this.baseUrl});
  @override
  List<Object?> get props => [baseUrl];
}

class AuthPasswordChanged extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  const AuthPasswordChanged({required this.oldPassword, required this.newPassword});
  @override
  List<Object?> get props => [oldPassword, newPassword];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoginSuccess extends AuthState {
  final AuthUser user;
  const AuthLoginSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthRegistered extends AuthState {
  final AuthUser user;
  const AuthRegistered({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthProfileUpdateSuccess extends AuthState {
  final AuthUser user;
  const AuthProfileUpdateSuccess({required this.user});
  @override
  List<Object?> get props => [user];
}

class AuthPasswordChangeSuccess extends AuthState {
  const AuthPasswordChangeSuccess();
}

class AuthBaseUrlUpdateSuccess extends AuthState {
  final String baseUrl;
  const AuthBaseUrlUpdateSuccess({required this.baseUrl});
  @override
  List<Object?> get props => [baseUrl];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthUserProfileRefreshed>(_onAuthUserProfileRefreshed);
    on<AuthProfileUpdated>(_onAuthProfileUpdated);
    on<AuthProfilePictureUpdated>(_onAuthProfilePictureUpdated);
    on<AuthPasswordChanged>(_onAuthPasswordChanged);
    on<AuthBaseUrlUpdated>(_onAuthBaseUrlUpdated);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final user = await _authRepository.getCachedUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          final freshUser = await _authRepository.getCurrentUser();
          emit(AuthAuthenticated(user: freshUser));
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.login(event.email, event.password);
      emit(AuthAuthenticated(user: response.user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.register({
        'email': event.email,
        'password': event.password,
        'first_name': event.firstName,
        'last_name': event.lastName,
      });
      emit(AuthRegistered(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.requestPasswordReset(event.email);
      emit(const AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthUserProfileRefreshed(
    AuthUserProfileRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.getUserProfile();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.updateUserProfile(event.data);
      emit(AuthProfileUpdateSuccess(user: user));
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthProfilePictureUpdated(
    AuthProfilePictureUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user =
          await _authRepository.updateProfilePicture(event.filePath);
      emit(AuthProfileUpdateSuccess(user: user));
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthPasswordChanged(
    AuthPasswordChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.changePassword(event.oldPassword, event.newPassword);
      emit(const AuthPasswordChangeSuccess());
      // Keep user authenticated
      final user = await _authRepository.getCachedUser();
      if (user != null) emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthBaseUrlUpdated(
    AuthBaseUrlUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.setBaseUrl(event.baseUrl);
      emit(AuthBaseUrlUpdateSuccess(baseUrl: event.baseUrl));
      // Keep user authenticated
      final user = await _authRepository.getCachedUser();
      if (user != null) emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
