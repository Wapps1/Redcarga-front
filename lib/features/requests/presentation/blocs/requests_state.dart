import 'package:equatable/equatable.dart';
import '../../domain/models/template.dart';

class RequestsState extends Equatable {
  final List<Template> templates;
  final String? selectedTemplateId;
  final bool isLoading;

  const RequestsState({
    this.templates = const [],
    this.selectedTemplateId,
    this.isLoading = false,
  });

  RequestsState copyWith({
    List<Template>? templates,
    String? selectedTemplateId,
    bool? isLoading,
  }) {
    return RequestsState(
      templates: templates ?? this.templates,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Template? get selectedTemplate {
    if (selectedTemplateId == null) return null;
    try {
      return templates.firstWhere(
        (t) => t.id == selectedTemplateId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [templates, selectedTemplateId, isLoading];
}
