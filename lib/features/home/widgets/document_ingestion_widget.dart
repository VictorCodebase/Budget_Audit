// lib/features/home/widgets/document_ingestion_widget.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/client_models.dart';
import '../../../core/theme/app_theme.dart';
import '../home_viewmodel.dart';
import 'document_card.dart';

class DocumentIngestionWidget extends StatefulWidget {
  const DocumentIngestionWidget({Key? key}) : super(key: key);

  @override
  State<DocumentIngestionWidget> createState() =>
      _DocumentIngestionWidgetState();
}

class _DocumentIngestionWidgetState extends State<DocumentIngestionWidget> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedOwnerId;
  FinancialInstitution? _selectedInstitution;
  bool _isPickingFile = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: context.colors.border, width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your bank statement for analysis. Information about each transaction will be automatically read and auto filled',
              style: AppTheme.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Active Template Warning/Info
            _buildActiveTemplateInfo(viewModel),
            const SizedBox(height: AppTheme.spacingMd),

            // Browse Document
            _buildBrowseDocument(),
            const SizedBox(height: AppTheme.spacingMd),

            // Password (optional)
            _buildPasswordField(),
            const SizedBox(height: AppTheme.spacingMd),

            // Document Owner
            _buildDocumentOwner(viewModel),
            const SizedBox(height: AppTheme.spacingMd),

            // Financial Institution
            _buildInstitutionSelector(),
            const SizedBox(height: AppTheme.spacingLg),

            // Action Buttons
            _buildActionButtons(viewModel),

            // Uploaded Documents List
            if (viewModel.hasDocuments) ...[
              const SizedBox(height: AppTheme.spacingLg),
              const Divider(),
              const SizedBox(height: AppTheme.spacingMd),
              _buildUploadedDocumentsList(viewModel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseDocument() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Browse Document (Only PDF)',
              style: AppTheme.label,
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTheme.label.copyWith(color: context.colors.error),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        InkWell(
          onTap: _isPickingFile ? null : _pickFile,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(
                color: _selectedFilePath != null
                    ? context.colors.primary
                    : context.colors.border,
                width: _selectedFilePath != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Center(
              child: Center(
                child: _isPickingFile
                    ? const CircularProgressIndicator()
                    : _selectedFilePath != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: context.colors.primary,
                                size: 32,
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                _selectedFileName!,
                                style: AppTheme.bodySmall.copyWith(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: context.colors.textSecondary,
                                size: 32,
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              Text(
                                'Click to browse',
                                style: AppTheme.bodySmall.copyWith(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Document Password (if applicable)',
              style: AppTheme.label,
            ),
            const SizedBox(width: AppTheme.spacing2xs),
            Icon(
              Icons.info_outline,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: '• • • •',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: context.colors.textTertiary,
            ),
            helperText:
                'Allows the software to read the document if it is password protected',
            helperStyle: AppTheme.caption,
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildDocumentOwner(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Select the document owner',
              style: AppTheme.label,
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTheme.label.copyWith(color: context.colors.error),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'Contents of the document shall be associated with this participant',
          style: AppTheme.caption,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        DropdownButtonFormField<int>(
          value: _selectedOwnerId,
          decoration: InputDecoration(
            hintText: 'Owner',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a document owner';
            }
            return null;
          },
          items: viewModel.participants.map((participant) {
            return DropdownMenuItem(
              value: participant.participantId,
              child: Text(
                participant.nickname ?? participant.firstName,
                style: AppTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedOwnerId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInstitutionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Select the document's financial institution",
              style: AppTheme.label,
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTheme.label.copyWith(color: context.colors.error),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          "Can't find your bank here? Early adopters can request their institution here",
          style: AppTheme.caption,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Wrap(
          spacing: AppTheme.spacingMd,
          runSpacing: AppTheme.spacingMd,
          children: FinancialInstitution.values.map((institution) {
            final isSelected = _selectedInstitution == institution;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedInstitution = institution;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withOpacity(0.1)
                      : context.colors.surface,
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  institution.displayName,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(HomeViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading ? null : _verifyAndAddDocument,
            icon: Icon(
              viewModel.isLoading
                  ? Icons.hourglass_empty
                  : Icons.verified_outlined,
              size: 20,
            ),
            label: Text(
              viewModel.isLoading
                  ? 'Verifying...'
                  : 'Verify Document and Add more',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.secondary,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.hasDocuments &&
                    !viewModel.isLoading &&
                    viewModel.hasActiveTemplate
                ? viewModel.runAudit
                : null,
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Run Audit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedDocumentsList(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Documents (${viewModel.uploadedDocuments.length})',
          style: AppTheme.h4,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        ...viewModel.uploadedDocuments.map((doc) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
            child: DocumentCard(document: doc),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _isPickingFile = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  Future<void> _verifyAndAddDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a PDF document'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    if (_selectedInstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a financial institution'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    final viewModel = context.read<HomeViewModel>();
    final success = await viewModel.addDocument(
      fileName: _selectedFileName!,
      filePath: _selectedFilePath!,
      password:
          _passwordController.text.isEmpty ? null : _passwordController.text,
      ownerParticipantId: _selectedOwnerId!,
      institution: _selectedInstitution!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document verified and added: $_selectedFileName'),
          backgroundColor: context.colors.success,
        ),
      );

      // Reset form
      setState(() {
        _selectedFilePath = null;
        _selectedFileName = null;
        _passwordController.clear();
        _selectedInstitution = null;
      });
    }
  }

  Widget _buildActiveTemplateInfo(HomeViewModel viewModel) {
    if (!viewModel.hasActiveTemplate) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: Colors.amber),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Budget Template',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please create a new budget or select one from history to run audit.',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: context.colors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: context.colors.secondary),
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: context.colors.secondary),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Budget',
                  style: AppTheme.bodySmall.copyWith(
                    color: context.colors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.currentTemplate?.templateName ?? 'Unknown Template',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
