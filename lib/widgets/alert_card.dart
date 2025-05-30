import 'package:flutter/material.dart';

enum AlertType { info, warning, error, success }

class AlertCard extends StatelessWidget {
  final String message;
  final AlertType type;
  final VoidCallback? onTap;

  const AlertCard({
    Key? key,
    required this.message,
    required this.type,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (type) {
      case AlertType.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case AlertType.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case AlertType.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}