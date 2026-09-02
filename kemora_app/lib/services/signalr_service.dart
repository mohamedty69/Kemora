import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../core/di/injection_container.dart';
import '../core/auth/token_storage.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();

  factory SignalRService() {
    return _instance;
  }

  SignalRService._internal();

  HubConnection? _hubConnection;
  Function(String title, String message)? onNotificationReceived;

  Future<void> init() async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }

    final baseUrl = resolveApiBaseUrl();
    final hubUrl = '$baseUrl/hubs/notification';

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, options: HttpConnectionOptions(
          accessTokenFactory: () async {
            return TokenStorage.instance.token ?? '';
          },
        ))
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on('ReceiveNotification', _handleNotification);

    try {
      await _hubConnection?.start();
      if (kDebugMode) {
        print('SignalR connected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SignalR connection failed: $e');
      }
    }
  }

  void _handleNotification(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final payload = arguments[0] as Map<String, dynamic>?;
      if (payload != null) {
        final title = payload['title'] as String? ?? 'Notification';
        final message = payload['message'] as String? ?? '';
        
        if (onNotificationReceived != null) {
          onNotificationReceived!(title, message);
        }
      }
    }
  }

  Future<void> disconnect() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }
}
