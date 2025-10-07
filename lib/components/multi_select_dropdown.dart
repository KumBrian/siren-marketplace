import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';

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

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Full-screen invisible barrier for outside taps
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),
          // Dropdown
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  // max height
                  child: StatefulBuilder(
                    builder: (context, setInnerState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // shrink column to content
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 8,
                            ),
                            child: Text(
                              "Filter ${widget.label}",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Flexible(
                            // <-- makes ListView scrollable when needed
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
                                      } else if (checked == false &&
                                          isSelected) {
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
