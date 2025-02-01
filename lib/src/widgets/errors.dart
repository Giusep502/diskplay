// Based on Scrobbler App, Copyright (c) 2020 Filipe Tavares

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final GlobalKey<ScaffoldMessengerState> scrobblerScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void displayAndLogError(Logger logger, Object e, StackTrace stackTrace,
    [String? message]) {
  final errorMessage = e is UIException
      ? e.message
      : message ??
          (e is SocketException && e.address != null
              ? 'Could not connect to ${e.address!.host} (${e.message})'
              : e.toString());

  if (e is UIException) {
    if (e.exception != null) {
      logger.warning(errorMessage, e.exception, stackTrace);
    }
  } else {
    logger.severe(errorMessage, e, stackTrace);
  }

  displayError(errorMessage);
}

void displayError(String errorMessage) {
  final scaffoldMsg = scrobblerScaffoldMessengerKey.currentState;
  scaffoldMsg?.removeCurrentSnackBar();
  scaffoldMsg?.showSnackBar(SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,
  ));
}

void displaySuccess(String message) {
  scrobblerScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Colors.green,
  ));
}

class UIException implements Exception {
  UIException(this.message, [this.exception]);

  final String message;
  final Object? exception;
}
