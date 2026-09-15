import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';

import '../../features/shop/data/models/home_feed.dart';

typedef HomeRealtimeCallback = void Function(String reason);

/// Listens for lightweight "home updated" signals over Pusher public channel.
/// The app then refetches `/home` — the socket never carries the full feed.
class HomeRealtimeService {
  HomeRealtimeService._();
  static final HomeRealtimeService instance = HomeRealtimeService._();

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connectionSub;
  StreamSubscription<ChannelReadEvent>? _eventSub;
  RealtimeConfig? _config;
  HomeRealtimeCallback? _onUpdated;
  Timer? _debounce;
  bool _connecting = false;

  Future<void> start({
    required RealtimeConfig config,
    required HomeRealtimeCallback onUpdated,
  }) async {
    _onUpdated = onUpdated;

    if (!config.isReady) {
      await stop();
      return;
    }

    if (_config != null &&
        _config!.key == config.key &&
        _config!.cluster == config.cluster &&
        _config!.channel == config.channel &&
        _config!.event == config.event &&
        _client != null) {
      return;
    }

    await stop();
    _config = config;
    _connecting = true;

    try {
      final options = PusherChannelsOptions.fromCluster(
        scheme: 'wss',
        cluster: config.cluster,
        key: config.key,
        port: 443,
      );

      final client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) async {
          if (kDebugMode) {
            debugPrint('HomeRealtime connection error: $exception');
          }
          try {
            refresh();
          } catch (_) {}
        },
      );

      final channel = client.publicChannel(config.channel);
      _connectionSub = client.onConnectionEstablished.listen((_) {
        channel.subscribeIfNotUnsubscribed();
      });

      _eventSub = channel.bind(config.event).listen((event) {
        final reason = _reasonFrom(event.data);
        _schedule(reason);
      });

      _client = client;
      unawaited(client.connect());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomeRealtime start failed: $e');
      }
      await stop();
    } finally {
      _connecting = false;
    }
  }

  void _schedule(String reason) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _onUpdated?.call(reason);
    });
  }

  String _reasonFrom(dynamic data) {
    if (data is Map) {
      final reason = data['reason']?.toString().trim();
      if (reason != null && reason.isNotEmpty) return reason;
    }
    if (data is String && data.contains('reason')) {
      final match = RegExp(r'"reason"\s*:\s*"([^"]+)"').firstMatch(data);
      if (match != null) return match.group(1)!;
    }
    return 'updated';
  }

  Future<void> stop() async {
    _debounce?.cancel();
    _debounce = null;
    await _eventSub?.cancel();
    _eventSub = null;
    await _connectionSub?.cancel();
    _connectionSub = null;
    try {
      _client?.dispose();
    } catch (_) {}
    _client = null;
    _config = null;
    _connecting = false;
  }

  bool get isActive => _client != null && !_connecting;
}
