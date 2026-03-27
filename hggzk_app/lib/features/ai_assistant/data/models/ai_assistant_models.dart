class AiAssistantHistoryMessage {
  final String role;
  final String content;

  const AiAssistantHistoryMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class AiAssistantToolExecution {
  final String name;
  final bool success;
  final String summary;

  const AiAssistantToolExecution({
    required this.name,
    required this.success,
    required this.summary,
  });

  factory AiAssistantToolExecution.fromJson(Map<String, dynamic> json) {
    return AiAssistantToolExecution(
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      success:
          (json['success'] as bool?) ?? (json['Success'] as bool?) ?? false,
      summary: (json['summary'] ?? json['Summary'] ?? '').toString(),
    );
  }
}

class AiAssistantChatResponse {
  final String reply;
  final String model;
  final List<AiAssistantToolExecution> toolExecutions;
  final List<AiAssistantResultCard> cards;

  const AiAssistantChatResponse({
    required this.reply,
    required this.model,
    required this.toolExecutions,
    required this.cards,
  });

  factory AiAssistantChatResponse.fromJson(Map<String, dynamic> json) {
    final rawTools = json['toolExecutions'] ??
        json['tool_executions'] ??
        json['ToolExecutions'];
    final tools = rawTools is List
        ? rawTools
            .whereType<Map>()
            .map((e) => AiAssistantToolExecution.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ))
            .toList()
        : <AiAssistantToolExecution>[];

    final rawCards = json['cards'] ?? json['Cards'];
    final cards = rawCards is List
        ? rawCards
            .whereType<Map>()
            .map((e) => AiAssistantResultCard.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ))
            .toList()
        : <AiAssistantResultCard>[];

    return AiAssistantChatResponse(
      reply: (json['reply'] ?? json['Reply'] ?? '').toString(),
      model: (json['model'] ?? json['Model'] ?? '').toString(),
      toolExecutions: tools,
      cards: cards,
    );
  }
}

class AiAssistantResultCard {
  final String type;
  final String propertyId;
  final String? unitId;
  final String title;
  final String subtitle;
  final String city;
  final String? imageUrl;
  final double? price;
  final String? currency;
  final String? badge;
  final Map<String, dynamic>? metadata;

  const AiAssistantResultCard({
    required this.type,
    required this.propertyId,
    required this.unitId,
    required this.title,
    required this.subtitle,
    required this.city,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.badge,
    required this.metadata,
  });

  factory AiAssistantResultCard.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '');

    return AiAssistantResultCard(
      type: (json['type'] ?? json['Type'] ?? 'property').toString(),
      propertyId: (json['propertyId'] ??
              json['property_id'] ??
              json['PropertyId'] ??
              '')
          .toString(),
      unitId: (json['unitId'] ?? json['unit_id'] ?? json['UnitId'])?.toString(),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['Subtitle'] ?? '').toString(),
      city: (json['city'] ?? json['City'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? json['ImageUrl'])
          ?.toString(),
      price: parsedPrice,
      currency: (json['currency'] ?? json['Currency'])?.toString(),
      badge: (json['badge'] ?? json['Badge'])?.toString(),
      metadata: (json['metadata'] ?? json['Metadata']) is Map
          ? Map<String, dynamic>.from(
              ((json['metadata'] ?? json['Metadata']) as Map).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : null,
    );
  }
}
