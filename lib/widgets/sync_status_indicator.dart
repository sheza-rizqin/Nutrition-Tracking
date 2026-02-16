import 'package:flutter/material.dart';
import '../database/sync_service.dart';

/// A simple status indicator that shows if the app is synced with the server.
/// Place this in your AppBar or home screen to give users visibility.
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SyncService.instance,
      builder: (context, _) {
        final sync = SyncService.instance;
        final color = sync.isOnline ? Colors.green : Colors.orange;
        final icon = sync.isOnline
            ? (sync.isSyncing ? Icons.cloud_upload : Icons.cloud_done)
            : Icons.cloud_off;
        final label = sync.isOnline
            ? (sync.isSyncing ? 'Syncing...' : 'Synced')
            : 'Offline';

        return Tooltip(
          message: 'Last sync: ${sync.lastSyncTime}',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
