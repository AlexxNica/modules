// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class StatefulWidget {}

class StatelessWidget {}

class State<T> {}

class Others {
  _Widget02 widget02;
  _Widget04 widget04;
}

/// This is a public [StatefulWidget].
class Widget01 extends StatefulWidget {}

/// This is a private [StatefulWidget].
class _Widget02 extends StatefulWidget {}

/// This is a public [StatelessWidget].
class Widget03 extends StatelessWidget {}

/// This is a private [StatelessWidget].
class _Widget04 extends StatelessWidget {}

/// This is the [State] class for [Widget01].
class Widget01State extends State<Widget01> {}

class NoCommentWidget extends StatelessWidget {}