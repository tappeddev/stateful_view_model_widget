library stateful_view_model_widget;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stateful_view_model/stateful_view_model.dart';

abstract class StatefulViewModelWidget<W extends StatefulWidget,
    S extends Cloneable<S>, VM extends StatefulViewModel<S>> extends State<W> {
  final List<StreamSubscription> _subscriptionsList =
      List<StreamSubscription>();

  S _state;

  VM _viewModel;

  VM get viewModel {
    if (_viewModel == null)
      throw Exception("ViewModel was not created or is already disposed!");

    return _viewModel;
  }

  VM createViewModel();

  @override
  @mustCallSuper
  void initState() {
    _viewModel = createViewModel();

    if (_viewModel == null) {
      throw Exception("The viewmodel from type \"$VM\" is null");
    }

    // immediately set the initial state to avoid ui glitches
    // cause by the async delivery of states
    setState(() => _state = _viewModel.getState());

    super.initState();

    _subscriptionsList.add(_viewModel.state
        .skip(1) // skip the initial state since we already set that
        .listen((state) => setState(() => _state = state)));

    afterViewModelInit();
  }

  Widget buildState(S state);

  @override
  Widget build(BuildContext context) => buildState(_state);

  /// Called after the initState - Can ensure that the VM is successfully created
  void afterViewModelInit() {}

  /// Called after the successfully disposing of the base class and the VM
  void afterViewModelDispose() {}

  @override
  void dispose() {
    _subscriptionsList.forEach((subscription) => subscription?.cancel());
    _viewModel.dispose();
    _viewModel = null;

    afterViewModelDispose();
    super.dispose();
  }
}
