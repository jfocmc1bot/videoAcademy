// lib/screens/widgets/video_tile_widget.dart

import 'package:flutter/material.dart';
import '../../models/video_model.dart';
import '../../i18n/custom_localizations_delegate.dart';

// Widget buildVideoTile({
//   required BuildContext context,
//   required Video video,
//   required VoidCallback onFavoriteToggle,
//   required VoidCallback onPlay,
//   String defaultLanguage = 'pt',
// }) {
//   String getLocalizedText(Map<String, String> textMap) {
//     return textMap[defaultLanguage] ?? textMap.values.firstOrNull ?? '';
//   }

//   return Card(
//     elevation: 4.0,
//     margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//     child: InkWell(
//       onTap: onPlay,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
//             child: Image.network(
//               getLocalizedText(video.thumbnailUrl),
//               width: double.infinity,
//               height: 180,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => Container(
//                 width: double.infinity,
//                 height: 180,
//                 color: Colors.grey[300],
//                 child: Icon(Icons.error, color: Colors.red, size: 50),
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   getLocalizedText(video.title),
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   getLocalizedText(video.description),
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       getLocalizedText(video.category),
//                       style: TextStyle(fontSize: 14, color: Colors.blue),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             video.isFavorite
//                                 ? Icons.favorite
//                                 : Icons.favorite_border,
//                             color: video.isFavorite ? Colors.red : null,
//                             size: 28,
//                           ),
//                           onPressed: onFavoriteToggle,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.play_arrow,
//                               color: Colors.blue, size: 28),
//                           onPressed: onPlay,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget buildVideoTile({
  required BuildContext context,
  required Video video,
  required VoidCallback onFavoriteToggle,
  required VoidCallback onPlay,
  String defaultLanguage = 'pt',
}) {
  String getLocalizedText(Map<String, String> textMap) {
    return textMap[defaultLanguage] ?? textMap.values.firstOrNull ?? '';
  }

  return Card(
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: InkWell(
      onTap: onPlay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                getLocalizedText(video.thumbnailUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red, size: 30),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getLocalizedText(video.title),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  getLocalizedText(video.description),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getLocalizedText(video.category),
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            video.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: video.isFavorite ? Colors.red : null,
                          ),
                          onPressed: onFavoriteToggle,
                        ),
                        IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.blue),
                          onPressed: onPlay,
                        ),
                      ],
                    ),
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
