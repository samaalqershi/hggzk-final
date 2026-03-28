/// Describes one conversational turn included in the history sent to the
/// assistant backend.
/// يمثل دورة محادثة واحدة ضمن السجل الذي يُرسل إلى الخادم الخاص بالمساعد.
class AiAssistantHistoryMessage {
  /// Role of the speaker, such as `user` or `assistant`.
  /// دور المتحدث داخل المحادثة، مثل `user` أو `assistant`.
  final String role;

  /// Plain-text message content that belongs to the given role.
  /// المحتوى النصي للرسالة التابعة لذلك الدور.
  final String content;

  /// Builds one history entry ready to be serialized with the rest of the
  /// conversation context.
  /// ينشئ عنصرًا واحدًا من سجل المحادثة جاهزًا للتسلسل مع بقية السياق.
  const AiAssistantHistoryMessage({
    required this.role,
    required this.content,
  });

  /// Converts the history entry into the compact shape expected by the backend.
  /// يحول عنصر السجل إلى الصيغة المختصرة التي يتوقعها الخادم.
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

/// Describes one backend tool execution that happened while the assistant was
/// preparing its answer.
/// يصف أداة واحدة نفذها الخادم أثناء تجهيز رد المساعد.
class AiAssistantToolExecution {
  /// Name of the tool or internal capability that was invoked.
  /// اسم الأداة أو القدرة الداخلية التي تم استدعاؤها.
  final String name;

  /// Whether that tool execution completed successfully.
  /// ما إذا كانت الأداة قد أتمت عملها بنجاح.
  final bool success;

  /// Short textual summary of what the tool did or found.
  /// ملخص نصي قصير يوضح ما الذي نفذته الأداة أو ما الذي وجدته.
  final String summary;

  /// Builds a normalized description of one tool execution.
  /// ينشئ وصفًا مطبعًا لعملية تنفيذ أداة واحدة.
  const AiAssistantToolExecution({
    required this.name,
    required this.success,
    required this.summary,
  });

  /// Parses a tool-execution payload returned by the assistant backend.
  /// يحلل حمولة تنفيذ الأداة المعادة من خادم المساعد.
  factory AiAssistantToolExecution.fromJson(Map<String, dynamic> json) {
    return AiAssistantToolExecution(
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      success:
          (json['success'] as bool?) ?? (json['Success'] as bool?) ?? false,
      summary: (json['summary'] ?? json['Summary'] ?? '').toString(),
    );
  }
}

/// Wraps the assistant reply together with the model metadata, tool activity,
/// and any result cards that should be rendered by the UI.
/// يغلف رد المساعد مع بيانات النموذج وسجل الأدوات وأي بطاقات نتائج يجب أن
/// تعرضها الواجهة.
class AiAssistantChatResponse {
  /// Main text reply produced by the assistant.
  /// الرد النصي الرئيسي الذي أنتجه المساعد.
  final String reply;

  /// Name or identifier of the model that generated the answer.
  /// اسم أو معرّف النموذج الذي ولّد الإجابة.
  final String model;

  /// Tool executions attached to the response for transparency or debugging.
  /// عمليات الأدوات المرتبطة بالاستجابة لأغراض الشفافية أو التشخيص.
  final List<AiAssistantToolExecution> toolExecutions;

  /// Structured cards that the UI can render as rich result items.
  /// بطاقات مهيكلة تستطيع الواجهة عرضها كعناصر نتائج غنية.
  final List<AiAssistantResultCard> cards;

  /// Builds a fully parsed assistant response ready for presentation.
  /// ينشئ استجابة مساعد محللة بالكامل وجاهزة للعرض.
  const AiAssistantChatResponse({
    required this.reply,
    required this.model,
    required this.toolExecutions,
    required this.cards,
  });

  /// Parses the backend response and normalizes optional tool and card arrays.
  /// يحلل رد الخادم ويطبّع مصفوفات الأدوات والبطاقات الاختيارية.
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

/// Describes one rich result card returned by the assistant, typically pointing
/// to a property, unit, or recommendation.
/// يصف بطاقة نتيجة غنية يعيدها المساعد، وغالبًا ما تشير إلى عقار أو وحدة أو
/// توصية.
class AiAssistantResultCard {
  /// Logical type of the card so the UI knows how to present it.
  /// النوع المنطقي للبطاقة حتى تعرف الواجهة كيف تعرضها.
  final String type;

  /// Property identifier associated with the suggested result.
  /// معرّف العقار المرتبط بالنتيجة المقترحة.
  final String propertyId;

  /// Optional unit identifier when the result points to a specific unit.
  /// معرّف الوحدة الاختياري عندما تشير النتيجة إلى وحدة محددة.
  final String? unitId;

  /// Primary headline shown on the card.
  /// العنوان الرئيسي الظاهر على البطاقة.
  final String title;

  /// Supporting description that gives the result more context.
  /// وصف مساند يمنح النتيجة مزيدًا من السياق.
  final String subtitle;

  /// City label associated with the result.
  /// اسم المدينة المرتبط بالنتيجة.
  final String city;

  /// Optional preview image used by rich result cards.
  /// صورة معاينة اختيارية تستخدمها بطاقات النتائج الغنية.
  final String? imageUrl;

  /// Optional numeric price extracted from the backend payload.
  /// السعر الرقمي الاختياري المستخرج من حمولة الخادم.
  final double? price;

  /// Currency code associated with the displayed price.
  /// رمز العملة المرتبط بالسعر المعروض.
  final String? currency;

  /// Optional badge text used to emphasize one aspect of the result.
  /// نص شارة اختياري يستخدم لإبراز جانب معين من النتيجة.
  final String? badge;

  /// Extra structured metadata that specialized card layouts may consume.
  /// بيانات إضافية مهيكلة قد تستخدمها تخطيطات البطاقات المتخصصة.
  final Map<String, dynamic>? metadata;

  /// Builds a normalized rich result card after the backend payload has been
  /// interpreted.
  /// ينشئ بطاقة نتيجة غنية مطبعة بعد تفسير حمولة الخادم.
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

  /// Parses one backend card payload and normalizes mixed key naming into a
  /// stable UI model.
  /// يحلل حمولة بطاقة واحدة من الخادم ويطبّع اختلاف أسماء المفاتيح إلى نموذج
  /// واجهة ثابت.
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
