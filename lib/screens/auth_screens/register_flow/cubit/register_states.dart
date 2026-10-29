import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterStepChanged extends RegisterState {
  final RegisterStep step;
  const RegisterStepChanged(this.step);
}

class RegisterFieldChanged extends RegisterState {
  const RegisterFieldChanged();
}

class RegisterSendOtpLoading extends RegisterState {
  const RegisterSendOtpLoading();
}

class RegisterSendOtpSuccess extends RegisterState {
  const RegisterSendOtpSuccess();
}

class RegisterSendOtpFail extends RegisterState {
  final String error;
  const RegisterSendOtpFail(this.error);
}

class RegisterVerifyOtpLoading extends RegisterState {
  const RegisterVerifyOtpLoading();
}

class RegisterVerifyOtpSuccess extends RegisterState {
  const RegisterVerifyOtpSuccess();
}

class RegisterVerifyOtpFail extends RegisterState {
  final String error;
  const RegisterVerifyOtpFail(this.error);
}

class RegisterSubmitLoading extends RegisterState {
  const RegisterSubmitLoading();
}

class RegisterSubmitSuccess extends RegisterState {
  const RegisterSubmitSuccess();
}

class RegisterSubmitFail extends RegisterState {
  final String error;
  const RegisterSubmitFail(this.error);
}
