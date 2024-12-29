// Copyright (c) 2016, Rik Bellens. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:clock/clock.dart';
import 'package:firebase_dart/src/database/impl/data_observer.dart';

import 'operations/tree.dart';

abstract class Event {
  late EventTarget _target;

  final String type;

  Event(this.type);

  EventTarget get target => _target;
}

typedef EventListener = void Function(Event event);

class EventTarget {
  final Map<String, Set<EventListener>> _eventRegistrations = {};

  DateTime? _emptyListenersSince = clock.now();

  DateTime? get emptyListenersSince => _emptyListenersSince;

  bool get hasEventRegistrations =>
      _eventRegistrations.values.any((v) => v.isNotEmpty);

  Iterable<String> get eventTypesWithRegistrations =>
      _eventRegistrations.keys.where((k) => _eventRegistrations[k]!.isNotEmpty);

  IncompleteData _oldValue = IncompleteData.empty();

  void notifyDataChanged(IncompleteData newValue) {
    if (!newValue.isComplete && _oldValue.isComplete) return;
    if (hasEventRegistrations) {
      eventTypesWithRegistrations
          .expand((t) =>
              const TreeEventGenerator().generateEvents(t, _oldValue, newValue))
          .forEach(dispatchEvent);
    }
    _oldValue = newValue;
  }

  void dispatchEvent(Event event) {
    event._target = this;
    if (!_eventRegistrations.containsKey(event.type)) return;
    _eventRegistrations[event.type]!.toList().forEach((l) => l(event));
  }

  void addEventListener(String type, EventListener listener) {
    _eventRegistrations
        .putIfAbsent(type, () => <void Function(Event)>{})
        .add(listener);
    _emptyListenersSince = null;

    var events = const TreeEventGenerator()
        .generateEvents(type, IncompleteData.empty(), _oldValue);
    events.where((e) => e.type == type).forEach((e) => listener(e));
  }

  void removeEventListener(String type, EventListener? listener) {
    if (listener == null) {
      _eventRegistrations.remove(type);
    } else {
      _eventRegistrations
          .putIfAbsent(type, () => <void Function(Event)>{})
          .remove(listener);
    }
    if (!hasEventRegistrations) {
      _emptyListenersSince = clock.now();
    }
  }
}
