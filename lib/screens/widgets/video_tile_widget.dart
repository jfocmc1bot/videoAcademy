// lib/screens/widgets/video_tile_widget.dart

import 'package:flutter/material.dart';
import '../../models/video_model.dart';

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
      child: Row(
        children: [
          // Imagem ou ícone
          Container(
            width: 100,
            height: 100,
            child: getLocalizedText(video.thumbnailUrl).isEmpty
                ? Icon(Icons.videocam, size: 50, color: Colors.grey)
                : Image.network(
                    getLocalizedText(video.thumbnailUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.videocam, size: 50, color: Colors.grey),
                  ),
          ),

          // Textos e botões
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getLocalizedText(video.title),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    getLocalizedText(video.description),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Botões de favorito e play
          Column(
            children: [
              IconButton(
                icon: Icon(
                  video.isFavorite ? Icons.favorite : Icons.favorite_border,
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
    ),
  );
}
