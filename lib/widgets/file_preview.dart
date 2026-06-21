import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/review_item.dart';
import '../services/thumbnail_cache.dart';
import '../theme/app_theme.dart';

class FilePreview extends StatelessWidget {
  final ReviewItem item;
  final bool enableFullScreen;

  const FilePreview({
    super.key,
    required this.item,
    this.enableFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreview(context);
    if (!enableFullScreen) return preview;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.openPreview,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          onTap: () => _openFullScreenPreview(context),
          child: preview,
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (item.source != ReviewItemSource.mediaLibrary) {
      return _buildDocumentPreview(context);
    }

    switch (item.type) {
      case FileItemType.photo:
        return _CachedThumbnail(
          itemId: item.id,
          fallbackIcon: Icons.broken_image_outlined,
        );
      case FileItemType.video:
        return _CachedVideoThumbnail(itemId: item.id);
      case FileItemType.download:
        return _buildDownloadPreview(context);
    }
  }

  void _openFullScreenPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullScreenFilePreview(item: item),
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    switch (item.type) {
      case FileItemType.photo:
        return buildPlaceholder(context, Icons.photo_outlined);
      case FileItemType.video:
        return buildPlaceholder(context, Icons.videocam_outlined);
      case FileItemType.download:
        return _buildDownloadPreview(context);
    }
  }

  Widget _buildDownloadPreview(BuildContext context) {
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
    return buildPlaceholder(context, icon);
  }

  static Widget buildPlaceholder(BuildContext context, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Center(
        child: Icon(icon, size: 64, color: context.appColors.textTertiary),
      ),
    );
  }
}

class _FullScreenFilePreview extends StatelessWidget {
  final ReviewItem item;

  const _FullScreenFilePreview({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: _FullScreenPreviewBody(item: item),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenPreviewBody extends StatelessWidget {
  final ReviewItem item;

  const _FullScreenPreviewBody({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.source == ReviewItemSource.mediaLibrary &&
        item.type == FileItemType.photo &&
        item.path != null) {
      return Image.file(
        File(item.path!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _CachedFullScreenPreview(item: item),
      );
    }

    return _CachedFullScreenPreview(item: item);
  }
}

class _CachedFullScreenPreview extends StatelessWidget {
  final ReviewItem item;

  const _CachedFullScreenPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final bytes = context.watch<ThumbnailCache>().get(item.id);
    if (bytes == null) {
      return FilePreview.buildPlaceholder(context, _fallbackIcon);
    }

    final image = Image.memory(bytes, fit: BoxFit.contain);
    if (item.type != FileItemType.video) return image;

    return Stack(
      alignment: Alignment.center,
      children: [image, const _PlayOverlay(size: 72, iconSize: 48)],
    );
  }

  IconData get _fallbackIcon {
    switch (item.type) {
      case FileItemType.photo:
        return Icons.photo_outlined;
      case FileItemType.video:
        return Icons.videocam_outlined;
      case FileItemType.download:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _CachedThumbnail extends StatelessWidget {
  final String itemId;
  final IconData fallbackIcon;

  const _CachedThumbnail({required this.itemId, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = context.watch<ThumbnailCache>().get(itemId);

    if (bytes == null) {
      return FilePreview.buildPlaceholder(context, fallbackIcon);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Image.memory(
        bytes,
        fit: BoxFit.contain,
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
    final Uint8List? bytes = context.watch<ThumbnailCache>().get(itemId);

    if (bytes == null) {
      return FilePreview.buildPlaceholder(context, Icons.videocam_outlined);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.contain),
          const Center(child: _PlayOverlay(size: 56, iconSize: 36)),
        ],
      ),
    );
  }
}

class _PlayOverlay extends StatelessWidget {
  final double size;
  final double iconSize;

  const _PlayOverlay({required this.size, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }
}
