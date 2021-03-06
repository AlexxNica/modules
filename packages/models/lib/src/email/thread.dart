// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:quiver/core.dart' as quiver;
import 'package:widgets_meta/widgets_meta.dart';

import '../fixtures/fixtures.dart';
import 'message.dart';

const ListEquality<Message> _messageListEquality =
    const ListEquality<Message>(const DefaultEquality<Message>());

/// Represents a single Gmail Thread
/// https://developers.google.com/gmail/api/v1/reference/users/threads#resource
@Generator(ModelFixtures, 'thread')
class Thread {
  /// The unique ID of the thread
  final String id;

  /// A short part of the message text
  final String snippet;

  /// The ID of the last history record that modified this thread
  final String historyId;

  /// The list of messages in the thread
  final List<Message> messages;

  /// Constructor
  Thread({
    this.id,
    this.snippet,
    this.historyId,
    // HACK(@dayang): Removed the immutability of the actual message list for
    // now. Messages themselves are still immutable
    this.messages,
  });

  /// Create a [Thread] from JSON.
  factory Thread.fromJson(Map<String, dynamic> json) {
    return new Thread(
      id: json['id'],
      snippet: json['snippet'],
      historyId: json['historyId'],
      messages: json['messages'].map((Map<String, dynamic> m) {
        return new Message.fromJson(m);
      }).toList(),
    );
  }

  @override
  String toString() {
    return 'Thread('
        'id: $id"'
        'snippet: $snippet"'
        'historyId: $historyId"'
        'messages: $messages"'
        ')';
  }

  /// Helper function for JSON.encode().
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};

    json['id'] = id;
    json['snippet'] = snippet;
    json['historyId'] = historyId;
    json['messages'] =
        messages.map((Message message) => message.toJson()).toList();

    return json;
  }

  /// Gets the subject of the thread
  /// For now, this will return the subject of the first message of the thread
  /// If there is no subject specified, a default of '(no subject)' will be set
  String getSubject() {
    if (this.messages.isNotEmpty &&
        this.messages[0].subject != null &&
        this.messages[0].subject.isNotEmpty) {
      return this.messages[0].subject;
    } else {
      return '(No Subject)';
    }
  }

  @override
  bool operator ==(Object o) =>
      o is Thread &&
      o.id == id &&
      o.snippet == snippet &&
      o.historyId == historyId &&
      _messageListEquality.equals(o.messages, messages);

  @override
  int get hashCode => quiver.hashObjects(<dynamic>[
        id,
        snippet,
        historyId,
        messages,
      ]);
}
