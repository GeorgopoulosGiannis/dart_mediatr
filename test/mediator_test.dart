import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediatr/mediatr.dart';

import 'package:mocktail/mocktail.dart';

class TestEvent1 extends IDomainEvent {
  @override
  String get name => 'TestEvent1';
}

class TestEvent2 extends IDomainEvent {
  @override
  String get name => 'TestEvent2';
}

class MockPipeline extends Mock implements Pipeline {}

class ConnectivityHandler extends IEventHandler<TestEvent1> {
  final VoidCallback onCall;

  ConnectivityHandler(this.onCall);
  @override
  Future<void> call(TestEvent1 event) async {
    onCall();
  }
}

class DemoRequest extends IRequest<bool> {
  final Duration duration;
  final String name = 'demoRequest';

  DemoRequest(this.duration);
}

class DemoRequestHandler extends IRequestHandler<bool, DemoRequest> {
  @override
  Future<bool> call(DemoRequest request) async {
    await Future.delayed(request.duration);

    return request.name == 'demoRequest';
  }
}

class RecordChangedEventHandler extends IEventHandler<TestEvent2> {
  final VoidCallback onCall;

  RecordChangedEventHandler(this.onCall);
  @override
  Future<void> call(TestEvent2 event) async {
    onCall();
  }
}

void main() {
  late MockPipeline mockPipeline;
  late Mediator mediator;

  const duration = Duration(
    milliseconds: 400,
  );
  setUp(
    () {
      registerFallbackValue(DemoRequest(duration));
      mockPipeline = MockPipeline();
      when(() => mockPipeline.passThrough(
          DemoRequest(duration), DemoRequestHandler())).thenAnswer(
        (_) async => true,
      );

      mediator = Mediator(
        mockPipeline,
      );
    },
  );

  group(
    'Group Publish subscribe',
    () {
      group(
        'Subscribe with func',
        () {
          test(
            'Should not call irrelevant handlers',
            () async {
              /// arrange
              bool called = false;
              mediator.subscribeWithFunc<TestEvent2>(
                (event) {
                  called = true;
                },
              );

              /// act
              await mediator.publish<TestEvent1>(
                TestEvent1(),
              );

              /// assert
              expect(called, false);
            },
          );
          test(
            'Should  call all relevant handlers',
            () async {
              /// arrange
              bool called1 = false;
              bool called2 = false;
              bool called3 = false;

              mediator
                ..subscribeWithFunc<TestEvent1>(
                  (event) {
                    called1 = true;
                  },
                )
                ..subscribeWithFunc<TestEvent1>(
                  (event) {
                    called2 = true;
                  },
                )
                ..subscribeWithFunc<TestEvent1>(
                  (event) {
                    called3 = true;
                  },
                );

              /// act
              await mediator.publish<TestEvent1>(
                TestEvent1(),
              );

              /// assert
              expect(called1, true);
              expect(called2, true);
              expect(called3, true);
            },
          );
        },
      );

      group(
        'Subscribe with class',
        () {
          late ConnectivityHandler connectivityHandler;
          late RecordChangedEventHandler recordChangedEventHandler;

          test(
            'Should not call irrellevant handlers',
            () async {
              /// arrange
              bool called = false;

              mediator.subscribe<TestEvent2>(
                RecordChangedEventHandler(
                  () {
                    called = true;
                  },
                ),
              );

              /// act
              await mediator.publish<TestEvent1>(
                TestEvent1(),
              );

              /// assert
              expect(called, false);
            },
          );
          test(
            'Should  call all relevant handlers',
            () async {
              /// arrange
              bool called1 = false;
              bool called2 = false;

              mediator
                ..subscribe<TestEvent1>(
                  ConnectivityHandler(
                    () {
                      called1 = true;
                    },
                  ),
                )
                ..subscribe<TestEvent1>(
                  ConnectivityHandler(
                    () {
                      called2 = true;
                    },
                  ),
                );

              /// act
              await mediator.publish<TestEvent1>(
                TestEvent1(),
              );

              /// assert
              expect(called1, true);
              expect(called2, true);
            },
          );
        },
      );

      group(
        'Calls both func and class handlers',
        () {
          late ConnectivityHandler connectivityHandler;

          test(
            'Should call both class and func handlers for event',
            () async {
              /// arrange
              bool handlerCalled = false;
              final handler = ConnectivityHandler(() {
                handlerCalled = true;
              });
              mediator.subscribe<TestEvent1>(handler);
              bool funcCalled = false;
              mediator.subscribeWithFunc<TestEvent1>(
                (event) {
                  funcCalled = true;
                },
              );

              /// act
              await mediator.publish<TestEvent1>(
                TestEvent1(),
              );

              ///assert
              expect(handlerCalled, true);
              expect(funcCalled, true);
            },
          );
        },
      );

      group(
        'Unsubsribe',
        () {
          late ConnectivityHandler connectivityHandler;
          test(
            'Should remove event handler',
            () async {
              ///arrange
              int callCount = 0;
              final handler = ConnectivityHandler(
                () {
                  callCount++;
                },
              );
              mediator.subscribe<TestEvent1>(handler);
              await mediator.publish<TestEvent1>(TestEvent1());
              expect(callCount, 1);

              ///act
              mediator.unsubscribe(handler);
              await mediator.publish<TestEvent1>(TestEvent1());

              ///assert
              expect(callCount, 1);
            },
          );

          test(
            'Should remove func handler',
            () async {
              int callCount = 0;
              void func(event) {
                callCount++;
              }

              final unsubscribe = mediator.subscribeWithFunc<TestEvent1>(func);
              await mediator.publish<TestEvent1>(TestEvent1());
              expect(callCount, 1);

              ///act
              unsubscribe();
              await mediator.publish<TestEvent1>(TestEvent1());

              ///assert
              expect(callCount, 1);
            },
          );
        },
      );
    },
  );

  group(
    'Send',
    () {
      test(
        'Should pass through all of pipeline behaviours',
        () async {
          final handler = DemoRequestHandler();
          mediator.registerHandler<bool, DemoRequest, DemoRequestHandler>(
            () => handler,
          );
          final request = DemoRequest(duration);
          when(() => mockPipeline.passThrough(request, handler))
              .thenAnswer((_) async => true);
          await mediator.send<bool, DemoRequest>(request);

          verify(() => mockPipeline.passThrough(request, handler)).called(1);
        },
      );
      test(
        'Should return right with result if request is handled',
        () async {
          final handler = DemoRequestHandler();
          mediator.registerHandler<bool, DemoRequest, DemoRequestHandler>(
            () => handler,
          );
          final request = DemoRequest(duration);
          when(() => mockPipeline.passThrough(request, handler))
              .thenAnswer((_) async => true);
          final resultOrFailure =
              await mediator.send<bool, DemoRequest>(request);
          expect(resultOrFailure.isRight, true);
          final result = resultOrFailure.fold((l) => l, (r) => r);
          expect(result, true);
        },
      );

      test(
        'Should return left with RequestFailure on exception',
        () async {
          final handler = DemoRequestHandler();

          mediator.registerHandler<bool, DemoRequest, DemoRequestHandler>(
            () => handler,
          );
          final request = DemoRequest(duration);
          when(() => mockPipeline.passThrough(request, handler))
              .thenThrow(Exception('error'));

          final resultOrFailure =
              await mediator.send<bool, DemoRequest>(request);

          expect(resultOrFailure.isLeft, true);
          final result = resultOrFailure.fold(
            (l) => l,
            (r) => r,
          );
          expect(result, isA<RequestFailure>());
        },
      );
    },
  );
}

class AddRequest extends IRequest<int> {
  final int i;

  AddRequest(this.i);
}

class AddRequestHandler extends IRequestHandler<int, AddRequest> {
  @override
  Future<int> call(AddRequest request) async {
    return request.i + 1;
  }
}
