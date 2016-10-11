// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:auth/auth_credentials.dart';
import 'package:auth/login_screen.dart';
import 'package:flutter/material.dart';

import '../screens/index.dart';
import '../src/config.dart';
import 'groups.dart';
import 'item.dart';

StatefulWidget galleryScaffoldedScreen(String title, StatefulWidget content) {
  return new Scaffold(
    appBar: new AppBar(
      title: new Text(title),
    ),
    body: content,
  );
}

/// Holds a list of all [GalleryItem] instances.
final List<GalleryItem> kGalleryCollection = <GalleryItem>[
  new GalleryItem(
    title: 'Email - Inbox',
    subtitle: 'A list view of a Gmail mobile style inbox.',
    group: GalleryGroups.screen,
    href: '/email/inbox',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new EmailInboxScreen()),
  ),
  new GalleryItem(
    title: 'Email - Inbox (Single Line)',
    subtitle: 'A list view of a Gmail web style inbox.',
    group: GalleryGroups.screen,
    href: '/email/inbox_single',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(
            item.title, new EmailInboxScreen(singleLine: true)),
  ),
  new GalleryItem(
    title: 'Email - Thread',
    subtitle: 'A single Gmail style email thread',
    group: GalleryGroups.screen,
    href: '/email/thread',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new EmailThreadScreen()),
  ),
  new GalleryItem(
    title: 'Email - Editor',
    subtitle: 'A Google Inbox style email editor',
    group: GalleryGroups.screen,
    href: '/email/editor',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new EmailEditorScreen()),
  ),
  new GalleryItem(
    title: 'Email - Menu',
    subtitle: 'A Google Gmail style main menu',
    group: GalleryGroups.screen,
    href: '/email/menu',
    builder: (BuildContext context, GalleryItem item) =>
        galleryScaffoldedScreen(item.title, new EmailMenuScreen()),
  ),
  new GalleryItem(
      title: 'Integrated Email Flow',
      subtitle: 'An integrated flow of email experience using real data',
      group: GalleryGroups.flow,
      href: '/flow/email',
      builder: (BuildContext context, GalleryItem item) {
        try {
          String clientId = kConfig.get('client_id');
          String clientSecret = kConfig.get('client_secret');

          return galleryScaffoldedScreen(
              "Login",
              new LoginScreen(
                clientId: clientId,
                clientSecret: clientSecret,
                onLoginSuccess: (AuthCredentials credentials) {
                  // Navigate to the EmailInboxScreen, with the obtained access
                  // token.
                  Navigator.popAndPushNamed(
                    context,
                    '/email/inbox/${credentials.accessToken}',
                  );
                },
              ));
        } catch (e) {
          return new ErrorScreen(e.toString());
        }
      }),
];
