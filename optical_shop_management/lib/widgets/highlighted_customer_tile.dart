import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../theme/app_theme.dart';

/// HighlightedCustomerTile widget displays customer information with search term highlighting
/// Features circular avatar with initials, name, phone, last visit, and total visits badge
/// Supports tap and delete handlers
/// Highlights matching text in search results
/// Avatar color is based on name hash for consistency
class HighlightedCustomerTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? searchQuery;

  const HighlightedCustomerTile({
    super.key,
    required this.customer,
    this.onTap,
    this.onDelete,
    this.searchQuery,
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

  /// Build text with highlighted search query
  Widget _buildHighlightedText(String text, TextStyle style) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery!.toLowerCase();
    final matches = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(lowerQuery, currentIndex);

      if (matchIndex == -1) {
        // No more matches, add remaining text
        matches.add(TextSpan(
          text: text.substring(currentIndex),
          style: style,
        ));
        break;
      }

      // Add text before match
      if (matchIndex > currentIndex) {
        matches.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: style,
        ));
      }

      // Add highlighted match
      matches.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + searchQuery!.length),
        style: style.copyWith(
          backgroundColor: AppTheme.accentColor.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      ));

      currentIndex = matchIndex + searchQuery!.length;
    }

    return RichText(
      text: TextSpan(children: matches),
    );
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
                    _buildHighlightedText(
                      customer.name,
                      const TextStyle(
                        fontFamily: AppTheme.headingFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    _buildHighlightedText(
                      customer.phoneNumber,
                      TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 14,
                        color: AppTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Last visit: ${_formatLastVisit()}',
                      style: TextStyle(
                        fontFamily: AppTheme.bodyFont,
                        fontSize: 12,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
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
                  color: AppTheme.successColor.withValues(alpha: 0.1),
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
