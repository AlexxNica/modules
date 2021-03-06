// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:config/config.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'embedded_child_builders.dart';

Future<Null> main() async {
  Config config = await Config.read('/system/data/modules/config.json');
  addEmbeddedChildBuilders(config);
  runApp(new App(config: config));
}
