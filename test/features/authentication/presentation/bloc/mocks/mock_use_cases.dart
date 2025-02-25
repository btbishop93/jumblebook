import 'package:mocktail/mocktail.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_in_with_apple.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_in_anonymously.dart';
import 'package:jumblebook/features/authentication/domain/usecases/sign_out.dart';
import 'package:jumblebook/features/authentication/domain/usecases/reset_password.dart';

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignInWithApple extends Mock implements SignInWithApple {}

class MockSignInAnonymously extends Mock implements SignInAnonymously {}

class MockSignOut extends Mock implements SignOut {}

class MockResetPassword extends Mock implements ResetPassword {}
