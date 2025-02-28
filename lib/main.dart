import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:web/web.dart' as web;

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  // controller for the url TextField:
  final _textController = TextEditingController();
  // key for the FloatingActionButton:
  final _fabKey = GlobalKey();

  // keeper for html <img> element:
  web.HTMLImageElement? _imgElement;

  bool _isFullScreenActive = false;

  // widget state:
  bool _isContextMenuOpened = false;

  @override
  Widget build(BuildContext context) {
    // opacity of the menu content darkening layer:
    final blackOpacity = _isContextMenuOpened ? 0.7 : 0.0;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          color: Color.fromRGBO(1, 1, 1, blackOpacity),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GestureDetector(
                        onDoubleTap: () {
                          _toggleFullScreen();
                        },
                        child: HtmlElementView.fromTagName(
                          tagName: 'img',
                          onElementCreated: (Object img) {
                            _imgElement = img as web.HTMLImageElement;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Image URL'),
                        controller: _textController,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _imgElement?.src = _textController.text;
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          SizedBox.expand(
            child: IgnorePointer(
              child: Container(
                color: Color.fromRGBO(1, 1, 1, blackOpacity),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          _showContextMenu();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleFullScreen() {
    if (_isFullScreenActive) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _enterFullScreen() {
    web.document.documentElement?.requestFullscreen();
    _isFullScreenActive = true;
  }

  void _exitFullScreen() {
    web.document.exitFullscreen();
    _isFullScreenActive = false;
  }

  Future<void> _showContextMenu() async {
    final entries = <ContextMenuEntry>[
      MenuItem(
        label: 'Enter fullscreen',
        value: 'enter',
        onSelected: () {
          // implement copy
        },
      ),
      MenuItem(
        label: 'Exit fullscreen',
        value: 'exit',
        onSelected: () {
          // implement paste
        },
      ),
    ];
    final offset = _fabKey.globalPaintBounds?.topRight;
    final menu = ContextMenu(
      entries: entries,
      position: offset,
      padding: const EdgeInsets.all(8.0),
    );
    setState(() {
      _isContextMenuOpened = true;
    });
    final selectedValue = await menu.show(context);
    switch (selectedValue) {
      case 'enter':
        _enterFullScreen();
        break;
      case 'exit':
        _exitFullScreen();
    }
    setState(() {
      _isContextMenuOpened = false;
    });
  }
}

// determines the paint bounds of the widget.
// used for positioning of the context menu on the screen.
extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}