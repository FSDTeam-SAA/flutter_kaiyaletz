import 'package:flutter/material.dart';
import 'package:flutter_kaiyaletz/core/utils/gap.dart';

/// Full-screen, pinch-to-zoom product image viewer.
///
/// Opened by tapping a photo in [CatalogDetailsScreen]'s image carousel.
/// Black background, swipeable between [images] starting at [initialIndex],
/// with a close button and a "n / total" counter overlaid on top.
class ImageViewScreen extends StatefulWidget {
  const ImageViewScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  late final _controller = PageController(initialPage: widget.initialIndex);
  late int _page = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(child: Image.network(images[i], fit: .contain)),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: InkResponse(
                onTap: () => Navigator.maybePop(context),
                radius: 24,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, color: Colors.white, size: 26),
                ),
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      '${_page + 1} / ${images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Gap(h: 10),
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        for (var i = 0; i < images.length; i++) ...[
                          if (i > 0) const Gap(w: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: i == _page ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _page ? Colors.white : Colors.white38,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
