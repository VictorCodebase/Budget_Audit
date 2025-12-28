// lib/features/home/widgets/document_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/client_models.dart';
import '../../../core/theme/app_theme.dart';
import '../home_viewmodel.dart';

class DocumentCard extends StatelessWidget {
  final UploadedDocument document;

  const DocumentCard({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();
    final owner = viewModel.participants.firstWhere(
      (p) => p.participantId == document.ownerParticipantId,
      orElse: () => throw Exception('Participant not found'),
    );

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border, width: 1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          // PDF Icon
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: context.colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: context.colors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),

          // Document Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        document.institution.displayName,
                        style: AppTheme.caption.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      '• Owner: ${owner.nickname ?? owner.firstName}',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: () => _confirmDelete(context, viewModel),
            icon: Icon(
              Icons.delete_outline,
              color: context.colors.error,
              size: 20,
            ),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HomeViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Document'),
        content: Text('Remove ${document.fileName} from the upload queue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      viewModel.removeDocument(document.id);
    }
  }
}
