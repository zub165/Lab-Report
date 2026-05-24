import 'dart:convert';

/// External image URLs stored in test order `clinical_notes` (SaeedLab web parity).
class OrderImageLink {
  final String url;
  final String label;

  const OrderImageLink({required this.url, this.label = ''});
}

class ParsedClinicalNotes {
  final String otherText;
  final List<OrderImageLink> imageLinks;

  const ParsedClinicalNotes({
    this.otherText = '',
    this.imageLinks = const [],
  });
}

ParsedClinicalNotes parseClinicalNotesForImages(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) {
    return const ParsedClinicalNotes();
  }
  try {
    final obj = jsonDecode(text);
    if (obj is Map && obj['image_links'] is List) {
      final links = <OrderImageLink>[];
      for (final item in obj['image_links'] as List) {
        if (item is Map) {
          final url = item['url']?.toString().trim() ?? '';
          if (url.isNotEmpty) {
            links.add(OrderImageLink(
              url: url,
              label: item['label']?.toString().trim() ?? '',
            ));
          }
        }
      }
      return ParsedClinicalNotes(
        otherText: obj['other_text']?.toString() ?? '',
        imageLinks: links,
      );
    }
  } catch (_) {}
  return ParsedClinicalNotes(otherText: text, imageLinks: const []);
}

String buildClinicalNotesWithImageLinks(
  String? existingClinicalNotes,
  List<OrderImageLink> imageLinks,
) {
  final parsed = parseClinicalNotesForImages(existingClinicalNotes);
  final clean = imageLinks
      .map((l) => OrderImageLink(
            url: l.url.trim(),
            label: l.label.trim(),
          ))
      .where((l) => l.url.isNotEmpty)
      .toList();
  return jsonEncode({
    'other_text': parsed.otherText,
    'image_links': clean
        .map((l) => {
              'url': l.url,
              if (l.label.isNotEmpty) 'label': l.label,
            })
        .toList(),
  });
}

bool isLikelyImageUrl(String url) {
  final u = url.toLowerCase();
  return u.startsWith('http://') ||
      u.startsWith('https://') ||
      u.startsWith('data:image/');
}
