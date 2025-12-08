class NasaImageModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String? fullImageUrl;
  final DateTime? dateCreated;
  final String? center;

  const NasaImageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    this.fullImageUrl,
    this.dateCreated,
    this.center,
  });

  factory NasaImageModel.fromJson(Map<String, dynamic> item) {
    final data = item['data'] != null && (item['data'] as List).isNotEmpty
        ? item['data'][0]
        : {};

    final links = item['links'] != null ? (item['links'] as List) : [];

    String thumb = '';
    for (var link in links) {
      if (link['rel'] == 'preview') {
        thumb = link['href'];
        break;
      }
    }
    // If no preview found, try to find any image
    if (thumb.isEmpty && links.isNotEmpty) {
      thumb = links[0]['href'];
    }

    // For full image, we might need to fetch the collection json from href,
    // but for the search endpoint, 'links' usually contains the preview.
    // Sometimes the original is not directly in 'links' of the search result,
    // but for this MVP we can use the thumbnail or try to construct a higher res url
    // if the API provides it.
    // Actually, the NASA Image API search result 'links' usually only has the preview.
    // To get the full image, one usually has to query the 'href' in the collection.
    // HOWEVER, for simplicity in this MVP, we will use the thumbnail as the image,
    // or check if there's a higher res link available.
    // Often simply replacing 'thumb' with 'orig' in the filename works, but that's hacky.
    // Let's just use the thumbnail for now, or if we want to be robust, we treat it as the main image.
    // Wait, the prompt says "fullImageUrl".
    // Let's see if we can get it.
    // The search result items usually have an "href" field at the top level of the item
    // which points to a JSON file containing all sizes.
    // Fetching that for every item in the list is too many requests.
    // We will store the collection href if needed, but for the "fullImageUrl" in the model,
    // we might just use the thumbnail for the list, and maybe fetch the full one on detail?
    // Or just map the preview as the full image for now if that's all we have synchronously.
    // Let's look at the structure again.
    // item['href'] -> "https://images-assets.nasa.gov/image/NASA_ID/collection.json"
    // We can store this collectionUrl.

    return NasaImageModel(
      id: data['nasa_id'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      thumbnailUrl: thumb,
      // We'll store the collection JSON URL as fullImageUrl for now,
      // or we can leave it null and fetch it in the detail screen.
      // Let's pass the collection href if available.
      fullImageUrl: item['href'],
      dateCreated: data['date_created'] != null
          ? DateTime.tryParse(data['date_created'])
          : null,
      center: data['center'],
    );
  }
}
