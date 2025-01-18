import 'package:flutter/material.dart';

class UiHelper {
  /// Builds a customizable button
  static Widget buildButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.lightBlue,
    Color textColor = Colors.black,
    double fontSize = 18,
    double verticalPadding = 16,
    double horizontalPadding = 8,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ),
      ),
    );
  }

  /// Builds a customizable text field
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool isMultiline = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: isMultiline ? 3 : 1,
      textInputAction: isMultiline ? TextInputAction.newline : TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignLabelWithHint: isMultiline,
      ),
    );
  }
}
