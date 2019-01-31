# stateful_view_model_widget

Model–View–ViewModel (MVVM) is a software architectural pattern.
[Read the full article on wikipedia](https://en.wikipedia.org/wiki/Model–view–viewmodel)


## Installation ❤ 

First, add stateful_view_model_widget as a [dependency in your pubspec.yaml file.](https://flutter.io/docs/development/packages-and-plugins/using-packages)

## Example 👀

We uploaded a small example project: [stateful_vm_example](https://github.com/tikkrapp/stateful_mvvm_example)

## Usage


The ViewModel:

```
import 'package:stateful_view_model/stateful_view_model.dart';

class LoginState implements Cloneable<LoginState> {

  String email;
  String password;

  bool loginButtonEnabled;
  bool isLoading;

  LoginState(
      {@required this.email,
      @required this.password,
      @required this.loginButtonEnabled,
      @required this.isLoading});

  factory LoginState.initial() => LoginState(
      email: "",    
      password: "",
      loginButtonEnabled: false,
      isLoading: false);

  @override
  LoginState copy() => LoginState(
      email: email,
      emailIsValid: emailIsValid,
      password: password,
      passwordIsValid: passwordIsValid,
      loginButtonEnabled: loginButtonEnabled,
      isLoading: isLoading);
}

abstract class LoginViewModel extends StateViewModel<LoginState> {
  LoginViewModel(LoginState initialState) : super(initialState);

  void setMail(String emailInput);

  void setPassword(String passwordInput);

  void login();
}



class LoginViewModelImpl extends LoginViewModel {
  final UserService _userService;
  final VoidCallback _onloginSuccessful;
 
  LoginViewModelImpl(this._userService, this._onloginSuccessful,
      [LoginState state])
      : super(state ?? LoginState.initial());

  @override
  void setMail(String emailInput) {
    LoginState state = getState();
    _updateInput(emailInput, state.password);
  }

  @override
  void setPassword(String passwordInput) {
    LoginState state = getState();
    _updateInput(state.email, passwordInput);
  }

  void _updateInput(String email, String password) {
    

    setState((state) {
      state.email = email;
      state.password = password;
      
      state.loginButtonEnabled = email.isNotEmpty && password.isNotEmpty;
      return state;
    });
  }

  @override
  void login() {
  
    _startLoading();
    
    _userService.login(state.email, state.password).listen((success){
        _stopLoading();
        _onloginSuccessful();
    });
  }

  /// -----
  /// Helper
  /// -----

  void _startLoading(Object event) {
    setState((state) {
      state.isLoading = true;
      return state;
    });
  }

  void _stopLoading(Object event) {
    setState((state) {
      state.isLoading = false;
      return state;
    });
  }
}



```

The View:

```
import 'package:stateful_view_model_widget/stateful_view_model_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPageView extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState
    extends StateViewModelPage<LoginPageView, LoginState, LoginViewModel>
    implements LoginRegisterRouter {
  @override
  LoginViewModel createViewModel() =>
      LoginViewModelImpl(UserServiceImpl(), (){ 
        //TODO Route to another page
      });

  @override
  Widget buildState(LoginState state) {
    return ListView(
      children: [
        TextField(
            text: state.email,
            prefixIcon: Icons.email,
            onChanged: (email) => viewModel.setMail(email),
            textInputType: TextInputType.emailAddress,
            textFieldType: TextFieldType.DEFAULT,
            labelText: I18n.instance.email),
        TextField(
            text: state.password,
            prefixIcon: Icons.vpn_key,
            onChanged: (password) => viewModel.setPassword(password),
            textFieldType: TextFieldType.PASSWORD,
            labelText: I18n.instance.password),
        BorderButton(
          isLoading: state.isLoading,
          backgroundColor: toUiColor(LightThemeColors().secondaryColor),
          text: i18n.login.toUpperCase(),
          iconData: Icons.keyboard_arrow_right,
          isEnabled: state.loginButtonEnabled,
          onTab: () => viewModel.login(),
          fill: true,
          iconOnLeftSide: false,
        )
      ],
    );
  }
}

```


