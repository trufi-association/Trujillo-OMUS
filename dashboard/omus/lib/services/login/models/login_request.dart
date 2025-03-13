import 'package:omus/widgets/components/textfield/form_request_field.dart';

class LoginRequest extends FormRequest {
  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromScratch() => LoginRequest(
        email: FormItemContainer(
          fieldKey: "username",
          // fieldKey: "",
          // value: "SuperAdmin",
          value: "",
          required: true,
        ),
        password: FormItemContainer(
          fieldKey: "password",
          // value: "P@ssw0rd",
          value: "",
          required: true,
        ),
      );

  final FormItemContainer<String> email;
  final FormItemContainer<String> password;

  Map<String, dynamic> toJson() => {
        email.fieldKey: email.value,
        password.fieldKey: password.value,
      };
}
