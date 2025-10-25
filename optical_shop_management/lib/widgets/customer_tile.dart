import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../theme/app_theme.dart';

/// CustomerTile widget displays customer information in a list tile format
/// Features circular avatar with initials, name, phone, last visit, and total visits badge
/// Supports tap and delete handlers
/// Avatar color is based on name hash for consistency
class CustomerTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CustomerTile({
    super.key,
    required this.customer,
    this.onTap,
    this.onDelete,
  });

  /// Generate a color based on the customer's name hash
  Color _getAvatarColor() {
    final hash = customer.name.hashCode;
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      const Color(0xFF8b5cf6), // Purple
      const Color(0xFFec4899), // Pink
      const Color(0xFF06b6d4), // Cyan
    ];
    return colors[hash.abs() % colors.length];
  }

  /// Get initials from customer name
  String _getInitials() {
    final parts = customer.name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  /// Format the last visit date as relative time
  String _formatLastVisit() {
    final now = DateTime.now();
    final difference = now.difference(customer.lastVisit);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(customer.lastVisit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          child: Row(
            children: [
              // Avatar with initials
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor,
                child: Text(
                  _getInitials(),
                  style: const TextStyle(
                    fontFamily: AppTheme.headingFont,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              // Customer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontFamily: AppTheme.headingFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      customer.phoneNumber,
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 14,
                        color: AppTheme.textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Last visit: ${_formatLastVisit()}',
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 12,
                        color: AppTheme.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Total visits badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${customer.totalVisits}',
                      style: const TextStyle(
                        fontFamily: AppTheme.headingFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppTheme.successColor,
                    ),
                  ],
                ),
              ),
              // Delete button (if handler provided)
              if (onDelete != null) ...[
                const SizedBox(width: AppTheme.spacing8),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.errorColor,
                  onPressed: onDelete,
                  tooltip: 'Delete customer',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
