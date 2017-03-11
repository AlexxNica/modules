// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:apps.modules.email.services/email_service.fidl.dart' as es;
import 'package:email_api/email_api.dart';
import 'package:lib.fidl.dart/bindings.dart' as bindings;
import 'package:meta/meta.dart';
import 'package:models/email.dart';
import 'package:models/user.dart';

void _log(String msg) {
  print('[email_service] $msg');
}

/// Implementation for email_service.
class EmailServiceImpl extends es.EmailService {
  final es.EmailServiceBinding _binding = new es.EmailServiceBinding();
  final Completer<EmailAPI> _api = new Completer<EmailAPI>();

  /// Binds this implementation to the incoming [bindings.InterfaceRequest].
  ///
  /// This should only be called once. In other words, a new [EmailServiceImpl]
  /// object needs to be created per interface request.
  void bind(bindings.InterfaceRequest<es.EmailService> request) {
    _binding.bind(this, request);
  }

  /// Close the binding
  void close() => _binding.close();

  /// Initialize the API with the given data.
  void initialize({
    @required String id,
    @required String secret,
    @required String token,
    @required DateTime expiry,
    @required String refreshToken,
    @required List<String> scopes,
  }) {
    _api.complete(new EmailAPI(
      id: id,
      secret: secret,
      token: token,
      expiry: expiry,
      refreshToken: refreshToken,
      scopes: scopes,
    ));
  }

  @override
  Future<Null> me(
    void callback(es.User user),
  ) async {
    _log('* me() called');

    EmailAPI api = await _api.future;
    User me = await api.me();

    String payload = JSON.encode(me);
    es.User result = new es.User.init(
      me.id,
      payload,
    );

    _log('* me() calling back');
    callback(result);
  }

  @override
  Future<Null> labels(
    bool all,
    void callback(List<es.Label> labels),
  ) async {
    _log('* labels() called');
    EmailAPI api = await _api.future;
    List<Label> labels = await api.labels();

    List<es.Label> results = labels.map((Label label) {
      String payload = JSON.encode(label);
      return new es.Label.init(
        label.id,
        payload,
      );
    }).toList();

    _log('* labels() calling back');
    callback(results);
  }

  @override
  Future<Null> threads(
    String labelId,
    int max,
    void callback(List<es.Thread> threads),
  ) async {
    _log('* threads() called');

    EmailAPI api = await _api.future;
    List<Thread> threads = await api.threads(
      labelId: labelId,
      max: max,
    );

    List<es.Thread> results = threads.map((Thread thread) {
      String payload = JSON.encode(thread);
      return new es.Thread.init(
        thread.id,
        payload,
      );
    }).toList();

    _log('* threads() calling back');
    callback(results);
  }
}
