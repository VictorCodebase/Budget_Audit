import 'package:budget_audit/core/theme/app_theme.dart';
import 'package:budget_audit/core/utils/color_palette.dart';
import 'package:flutter/material.dart';
import '../../../core/models/models.dart' as models;

class ParticipantAvatar extends StatelessWidget {
  final models.Participant participant;
  final double size;
  final bool showTooltip;

  const ParticipantAvatar({
    Key? key,
    required this.participant,
    this.size = 40,
    this.showTooltip = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final color = _generateColor();

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (showTooltip) {
      return Tooltip(
        message: participant.nickname ?? '${participant.firstName} ${participant.lastName}',
        child: avatar,
      );
    }

    return avatar;
  }

  String _getInitials() {
    if (participant.nickname != null && participant.nickname!.isNotEmpty) {
      return participant.nickname!.substring(0, 1).toUpperCase();
    }

    final first = participant.firstName.isNotEmpty
        ? participant.firstName.substring(0, 1).toUpperCase()
        : '';
    final last = participant.lastName!.isNotEmpty
        ? participant.lastName!.substring(0, 1).toUpperCase()
        : '';

    return '$first$last';
  }

  Color _generateColor() {
    // Generate random color
    return ColorPalette.getRandom();
  }
}