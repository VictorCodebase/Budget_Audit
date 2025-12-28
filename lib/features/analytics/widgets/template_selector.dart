// lib/features/analytics/widgets/template_selector.dart

import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

class TemplateSelector extends StatelessWidget {
  final Template selectedTemplate;
  final List<Template> availableTemplates;
  final Function(Template) onTemplateSelected;

  const TemplateSelector({
    Key? key,
    required this.selectedTemplate,
    required this.availableTemplates,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (availableTemplates.length <= 1) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.folder_outlined, color: context.colors.primary),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              selectedTemplate.templateName,
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: DropdownButton<Template>(
        value: selectedTemplate,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: context.colors.textSecondary),
        items: availableTemplates.map((template) {
          return DropdownMenuItem<Template>(
            value: template,
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: context.colors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  template.templateName,
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (Template? template) {
          if (template != null) {
            onTemplateSelected(template);
          }
        },
      ),
    );
  }
}
