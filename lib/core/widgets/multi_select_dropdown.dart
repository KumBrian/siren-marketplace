import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> options;
  final List<T> selectedValues;
  final String Function(T) optionLabel;
  final ValueChanged<List<T>> onChanged;
  final bool Function(T a, T b)? equals;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.optionLabel,
    required this.onChanged,
    this.equals,
  });

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  late List<T> _selected;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  bool _equals(T a, T b) => widget.equals?.call(a, b) ?? a == b;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.selectedValues, widget.selectedValues)) {
      _selected = List<T>.from(widget.selectedValues);
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;
    const dropdownMaxHeight = 400.0;
    const spacing = 4.0;
    const itemHeightEstimate = 48.0; // average height of each checkbox row

    // Calculate estimated dropdown height dynamically
    final estimatedHeight =
        (widget.options.length * itemHeightEstimate) +
        40; // 40 for padding/header
    final dropdownHeight = estimatedHeight > dropdownMaxHeight
        ? dropdownMaxHeight
        : estimatedHeight;

    // Check if there’s enough space below, otherwise show above
    final spaceBelow = screenHeight - (offset.dy + size.height);
    final showAbove = spaceBelow < dropdownHeight + spacing;

    // Compute vertical position
    final dropdownTop = showAbove
        ? offset.dy - dropdownHeight - spacing
        : offset.dy + size.height + spacing;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap outside to close
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),

          // Dropdown body
          Positioned(
            left: offset.dx,
            top: dropdownTop.clamp(0.0, screenHeight - dropdownHeight - 8),
            width: size.width,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: dropdownMaxHeight,
                  minHeight: 60,
                ),
                child: StatefulBuilder(
                  builder: (context, setInnerState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8,
                          ),
                          child: Text(
                            "Filter ${widget.label}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Flexible(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: widget.options.length,
                            itemBuilder: (context, index) {
                              final option = widget.options[index];
                              final isSelected = _selected.any(
                                (e) => _equals(e, option),
                              );

                              return CheckboxListTile(
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                title: Text(widget.optionLabel(option)),
                                value: isSelected,
                                onChanged: (checked) {
                                  setInnerState(() {
                                    if (checked == true && !isSelected) {
                                      _selected = [..._selected, option];
                                    } else if (checked == false && isSelected) {
                                      _selected = _selected
                                          .where((e) => !_equals(e, option))
                                          .toList();
                                    }
                                  });
                                  widget.onChanged(_selected);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: _selected.isEmpty ? 8 : 0,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Row(
            children: [
              // Selected items or placeholder
              _selected.isEmpty
                  ? Expanded(
                      child: Text(
                        "Select ${widget.label}",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _selected.map((val) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                label: Text(
                                  widget.optionLabel(val),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selected = _selected
                                        .where((e) => !_equals(e, val))
                                        .toList();
                                  });
                                  widget.onChanged(_selected);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

              Icon(
                _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.textBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
