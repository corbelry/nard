import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../app/setup_draft.dart';
import 'account.dart';
import 'api_client.dart';
import 'online_game_controller.dart';

/// The online queue request edited on 2.2 (online mode); kept in memory.
class OnlineDraft extends Notifier<QueueJoinPayload> {
  @override
  QueueJoinPayload build() => QueueJoinPayload(
    variant: ref.read(setupDraftProvider).variant,
    matchLength: 1,
    mode: QueueMode.casual,
  );

  void set(QueueJoinPayload value) => state = value;
}

final onlineDraftProvider = NotifierProvider<OnlineDraft, QueueJoinPayload>(
  OnlineDraft.new,
);

/// Runs the auth flow (17.1) when signed out; true once signed in.
Future<bool> ensureSignedIn(BuildContext context, WidgetRef ref) async {
  Account? account;
  try {
    // Waits for the stored session to load at start-up.
    account = await ref.read(accountProvider.future);
  } on Object {
    account = ref.read(accountProvider).value;
  }
  if (account != null) return true;
  if (!context.mounted) return false;
  final ok = await context.push<bool>('/signin');
  return ok == true && ref.read(accountProvider).value != null;
}

/// Joins the queue with [request] and opens the searching screen (2.4).
Future<void> startSearch(
  BuildContext context,
  WidgetRef ref,
  QueueJoinPayload request,
) async {
  if (!await ensureSignedIn(context, ref) || !context.mounted) return;
  ref.read(onlineDraftProvider.notifier).set(request);
  unawaited(ref.read(onlineGameProvider.notifier).search(request));
  unawaited(context.push('/online/search'));
}
