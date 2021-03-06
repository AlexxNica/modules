// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.maxwell.lib.context.dart/maxwell_context.dart'
    as maxwell_context;
import 'package:apps.maxwell.services.context/publisher_link.fidl.dart';
import 'package:apps.modular.services.module/module.fidl.dart';
import 'package:apps.modular.services.module/module_context.fidl.dart';
import 'package:apps.modular.services.story/link.fidl.dart';
import 'package:flutter/material.dart';
import 'package:lib.fidl.dart/bindings.dart';
import 'package:models/music.dart';
import 'package:widgets/music.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();

final ContextPublisherLinkProxy _albumIdPub = new ContextPublisherLinkProxy();
final ContextPublisherLinkProxy _artistNamePub =
    new ContextPublisherLinkProxy();

final GlobalKey<HomeScreenState> _kHomeKey = new GlobalKey<HomeScreenState>();

final String _kMusicDocRoot = 'youtube-doc';
final String _kMusicAlbumIdKey = 'music-album-id';

// The album id
// TODO(dayang): this is hardcoded for now, ideally whoever launches this story
// should set the album id
String _albumId = '0nDpqGDg3ZsFWKCSPQE4M4';

ModuleImpl _module;

void _log(String msg) {
  print('[music_story] $msg');
}

/// An implementation of the [LinkWatcher] interface.
class LinkWatcherImpl extends LinkWatcher {
  final LinkWatcherBinding _binding = new LinkWatcherBinding();

  /// Gets the [InterfaceHandle] for this [LinkWatcher] implementation.
  ///
  /// The returned handle should only be used once.
  InterfaceHandle<LinkWatcher> getHandle() => _binding.wrap(this);

  /// Correctly close the Link Binding
  void close() => _binding.close();

  @override
  void notify(String json) {
    _log('LinkWatcherImpl::notify call');

    final dynamic doc = JSON.decode(json);
    if (doc is! Map ||
        doc[_kMusicDocRoot] is! Map ||
        doc[_kMusicDocRoot][_kMusicAlbumIdKey] is! String) {
      _log('No music album id key found in json.');
      return;
    }

    _albumId = doc[_kMusicDocRoot][_kMusicAlbumIdKey];
    // TODO(rosswang): Integrate at a lower level.
    _albumIdPub.update(_albumId);

    _log('_albumId: $_albumId');
    _kHomeKey.currentState?.updateUI();
  }
}

/// An implementation of the [Module] interface.
class ModuleImpl extends Module {
  final ModuleBinding _binding = new ModuleBinding();

  /// [ModuleContext] service provided by the framework.
  final ModuleContextProxy moduleContext = new ModuleContextProxy();

  /// [Link] service provided by the framework.
  final LinkProxy link = new LinkProxy();

  /// Bind an [InterfaceRequest] for a [Module] interface to this object.
  void bind(InterfaceRequest<Module> request) {
    _binding.bind(this, request);
  }

  final LinkWatcherImpl _linkWatcher = new LinkWatcherImpl();

  @override
  void initialize(
    InterfaceHandle<ModuleContext> moduleContextHandle,
    InterfaceHandle<Link> linkHandle,
    InterfaceHandle<ServiceProvider> incomingServicesHandle,
    InterfaceRequest<ServiceProvider> outgoingServices,
  ) {
    _log('ModuleImpl::initialize call');

    moduleContext.ctrl.bind(moduleContextHandle);

    maxwell_context.publish(
        'music album id',
        'https://developer.spotify.com/web-api/user-guide/#spotify-uris-and-ids',
        null,
        _albumIdPub.ctrl.request());
    maxwell_context.publish(
        'music artist name', 'string', null, _artistNamePub.ctrl.request());

    _albumIdPub.update(_albumId);

    // Bind the link handle and write the video id.
    link.ctrl.bind(linkHandle);
    link.watchAll(_linkWatcher.getHandle());
  }

  @override
  void stop(void callback()) {
    _log('ModuleImpl::stop call');
    _linkWatcher.close();
    moduleContext.ctrl.close();
    link.ctrl.close();
    _albumIdPub.update(null);
    _albumIdPub.ctrl.close();
    _artistNamePub.update(null);
    _artistNamePub.ctrl.close();
    maxwell_context.closeGlobals();
    callback();
  }
}

/// Main screen for this module.
class HomeScreen extends StatefulWidget {
  /// Creates a new instance of [HomeScreen].
  HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => new HomeScreenState();
}

/// State class for the main screen widget.
class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Container(
        alignment: FractionalOffset.center,
        constraints: const BoxConstraints.expand(),
        child: _albumId != null
            ? new AlbumPage(
                albumId: _albumId,
                onChanged: (Album album) =>
                    _artistNamePub.update(album?.artists?.first?.name))
            : new CircularProgressIndicator(),
      ),
    );
  }

  /// Convenient method for other entities to call setState to cause UI updates.
  void updateUI() {
    setState(() {});
  }
}

/// Main entry point to the email folder list module.
void main() {
  _log('Module started with context: $_context');

  maxwell_context.connectPublisher(_context);

  /// Add [ModuleImpl] to this application's outgoing ServiceProvider.
  _context.outgoingServices.addServiceForName(
    (InterfaceRequest<Module> request) {
      _log('Received binding request for Module');
      if (_module != null) {
        _log('Module interface can only be provided once. Rejecting request.');
        request.channel.close();
        return;
      }
      _module = new ModuleImpl()..bind(request);
    },
    Module.serviceName,
  );

  runApp(new MaterialApp(
    title: 'Music Story',
    home: new HomeScreen(key: _kHomeKey),
    theme: new ThemeData(primarySwatch: Colors.blue),
    debugShowCheckedModeBanner: false,
  ));
}
