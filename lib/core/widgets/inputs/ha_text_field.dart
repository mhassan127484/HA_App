import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HATextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const HATextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────
class HASearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const HASearchField({
    super.key,
    this.controller,
    this.hint = 'Search products...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: (controller?.text.isNotEmpty ?? false)
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
      ),
    );
  }
}
