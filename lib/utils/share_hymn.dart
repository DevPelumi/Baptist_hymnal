import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../models/hymn_data.dart';

/// Shares [hymn]'s words. [context] anchors the share popover on iPad.
void shareHymn(BuildContext context, HymnData hymn) {
  final box = context.findRenderObject() as RenderBox?;
  SharePlus.instance.share(
    ShareParams(
      text:
          '${hymn.title}\n'
          '${hymn.contents.join("\n")}\n\n'
          '📱 Baptist Hymnal App\n'
          'Download from Play Store',
      subject: 'Share Hymn',
      sharePositionOrigin: box == null || !box.hasSize
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
