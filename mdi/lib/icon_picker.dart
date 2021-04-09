part of 'mdi.dart';

final RegExp split = RegExp(r'\W');

class IconPickerDialog extends StatelessWidget {
  final Map<String, IconData> icons;
  final Color iconColor;
  final List<String>? Function(String)? termsForName;

  const IconPickerDialog({
    Key? key,
    required this.icons,
    this.iconColor = Colors.blueGrey,
    this.termsForName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick an Icon'),
      content: ChangeNotifierProvider(
        create: (context) => _FilteredIcons(
          icons: icons,
          termsForName: generateTermsForName,
        ),
        builder: (context, _) => Container(
          constraints: const BoxConstraints(
            minWidth: 420,
            maxWidth: 600,
            maxHeight: 480,
          ),
          child: Column(
            children: [
              _IconSearchBar(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _IconGrid(
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> generateTermsForName(String name) {
    return termsForName?.call(name) ?? name.split(split);
  }
}

class _IconSearchBar extends StatefulWidget {
  @override
  _IconSearchBarState createState() => _IconSearchBarState();
}

class _IconSearchBarState extends State<_IconSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        onChanged: (value) {
          context.read<_FilteredIcons>().filter(value);
          // Trigger clear button to rebuild
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: AnimatedSwitcher(
            child: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                    },
                  )
                : const SizedBox(
                    width: 10,
                  ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
      );
}

class _IconGrid extends StatefulWidget {
  final Color color;
  final double iconSize;
  final double iconSpacing;

  const _IconGrid({
    Key? key,
    this.color = Colors.blueGrey,
    this.iconSize = 48,
    this.iconSpacing = 6,
  }) : super(key: key);
  @override
  _IconGridState createState() => _IconGridState();
}

class _IconGridState extends State<_IconGrid> {
  @override
  Widget build(BuildContext context) {
    final items = context.watch<_FilteredIcons>();
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio: 1.0,
        mainAxisSpacing: widget.iconSpacing,
        crossAxisSpacing: widget.iconSpacing,
        maxCrossAxisExtent: widget.iconSize,
      ),
      itemBuilder: (context, index) {
        var item = items.filteredList[index];

        return GestureDetector(
            onTap: () => Navigator.pop(context, item.name),
            child: Tooltip(
              message: item.name,
              child: Icon(
                item.iconData,
                size: widget.iconSize,
                color: widget.color,
              ),
            ));
      },
      itemCount: items.filteredList.length,
    );
  }
}

class _FilteredIcons with ChangeNotifier {
  late final List<_IconGridData> _fullList;
  late List<_IconGridData> _filteredList;
  List<_IconGridData> get filteredList => _filteredList;

  _FilteredIcons({
    required Map<String, IconData> icons,
    required List<String> Function(String) termsForName,
  }) {
    _fullList = icons.entries
        .map((e) => _IconGridData(e.key, termsForName(e.key), e.value))
        .toList(growable: false);
    _filteredList = _fullList;
  }

  void filter(String query) {
    final trimmedQuery = query.trim();
    final parts = trimmedQuery.split(split);
    _filteredList = _fullList
        .where((item) => parts
            .every((part) => item.terms.any((term) => term.startsWith(part))))
        .toList(growable: false);
    notifyListeners();
  }
}

class _IconGridData {
  final String name;
  final List<String> terms;
  final IconData iconData;

  _IconGridData(this.name, this.terms, this.iconData);
}
