import 'package:flutter/material.dart';

/// Campo de búsqueda reutilizable con botón para limpiar contenido.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.hintText = 'Buscar...',
    this.labelText,
    this.decoration,
    this.showClearButton = true,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final InputDecoration? decoration;
  final bool showClearButton;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController? _internalController;
  bool get _ownsController => widget.controller == null;

  TextEditingController get _effectiveController {
    if (widget.controller != null) return widget.controller!;
    _internalController ??= TextEditingController();
    return _internalController!;
  }

  @override
  void dispose() {
    if (_ownsController) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        final baseDecoration = (widget.decoration ??
                InputDecoration(
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                ))
            .copyWith(
          hintText: widget.decoration?.hintText ?? widget.hintText,
          labelText: widget.decoration?.labelText ?? widget.labelText,
          prefixIcon:
              widget.decoration?.prefixIcon ?? const Icon(Icons.search),
        );
        return TextField(
          controller: _effectiveController,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          textInputAction: TextInputAction.search,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: baseDecoration.copyWith(
            suffixIcon: widget.showClearButton && hasText
                ? IconButton(
                    onPressed: _handleClear,
                    tooltip: 'Limpiar búsqueda',
                    icon: const Icon(Icons.clear),
                  )
                : widget.decoration?.suffixIcon,
          ),
        );
      },
    );
  }
}
