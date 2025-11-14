import 'package:flutter/material.dart';
import '../../../core/models/models.dart' as models;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/content_box.dart';
import 'participant_avatar.dart';

class TemplateHistoryItem extends StatelessWidget {
  final models.Template template;
  final List<models.Participant> participants;
  final double totalBudget;
  final bool isCurrent;
  final VoidCallback onAdopt;
  final VoidCallback onDelete;

  const TemplateHistoryItem({
    Key? key,
    required this.template,
    required this.participants,
    this.totalBudget = 0.0,
    this.isCurrent = false,
    required this.onAdopt,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContentBox(
      minimizedHeight: 60,
      initiallyMinimized: true,
      controls: [
        ContentBoxControl(
          action: ContentBoxAction.minimize,
          onPressed: () {},
        ),
        ContentBoxControl(
          action: ContentBoxAction.delete,
          onPressed: onDelete,
        ),
      ],
      previewWidgets: [
        Flexible(
          child: Text(
            template.templateName,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingXs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.success,
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
            child: Text(
              'Current',
              style: AppTheme.caption.copyWith(color: Colors.white),
            ),
          ),
      ],
      headerWidgets: [
        _buildInfoRow(
          'Date Created',
          _formatDate(template.dateCreated),
        ),
        _buildInfoRow(
          'Total Budget',
          '\$${totalBudget.toStringAsFixed(2)}',
        ),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current template badge
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.success, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    'Currently Active Template',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Participants section
          Text(
            'Participants:',
            style: AppTheme.label,
          ),
          const SizedBox(height: AppTheme.spacingXs),

          if (participants.isEmpty)
            Text(
              'No participants',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: AppTheme.spacingXs,
              runSpacing: AppTheme.spacingXs,
              children: participants.map((participant) {
                return ParticipantAvatar(
                  participant: participant,
                  size: 32,
                );
              }).toList(),
            ),

          const SizedBox(height: AppTheme.spacingMd),

          // Adopt button (only if not current)
          if (!isCurrent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAdopt,
                child: const Text('Adopt Template'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}