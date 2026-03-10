import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/review_item.dart';
import '../services/thumbnail_cache.dart';
import '../theme/app_theme.dart';

class FilePreview extends StatelessWidget {
  final ReviewItem item;

  const FilePreview({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case FileItemType.photo:
        return _CachedThumbnail(
          itemId: item.id,
          fallbackIcon: Icons.broken_image_outlined,
        );
      case FileItemType.video:
        return _CachedVideoThumbnail(itemId: item.id);
      case FileItemType.download:
        return _buildDownloadPreview();
    }
  }

  Widget _buildDownloadPreview() {
    final ext = item.name.split('.').last.toLowerCase();
    final IconData icon;
    switch (ext) {
      case 'pdf':
        icon = Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        icon = Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        icon = Icons.table_chart_outlined;
      case 'zip':
      case 'rar':
      case '7z':
        icon = Icons.folder_zip_outlined;
      case 'mp3':
      case 'wav':
      case 'aac':
        icon = Icons.audio_file_outlined;
      case 'apk':
        icon = Icons.android_outlined;
      default:
        icon = Icons.insert_drive_file_outlined;
    }
    return buildPlaceholder(icon);
  }

  static Widget buildPlaceholder(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 64,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}

class _CachedThumbnail extends StatelessWidget {
  final String itemId;
  final IconData fallbackIcon;

  const _CachedThumbnail({
    required this.itemId,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = context.read<ThumbnailCache>().get(itemId);

    if (bytes == null) {
      return FilePreview.buildPlaceholder(fallbackIcon);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class _CachedVideoThumbnail extends StatelessWidget {
  final String itemId;

  const _CachedVideoThumbnail({required this.itemId});

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = context.read<ThumbnailCache>().get(itemId);

    if (bytes == null) {
      return FilePreview.buildPlaceholder(Icons.videocam_outlined);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            bytes,
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
