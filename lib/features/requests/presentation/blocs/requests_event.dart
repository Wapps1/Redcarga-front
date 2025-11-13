import 'package:equatable/equatable.dart';

abstract class RequestsEvent extends Equatable {
  const RequestsEvent();

  @override
  List<Object?> get props => [];
}

class RequestsLoadTemplates extends RequestsEvent {
  const RequestsLoadTemplates();
}

class RequestsSelectTemplate extends RequestsEvent {
  final String? templateId;

  const RequestsSelectTemplate(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

class RequestsContinue extends RequestsEvent {
  const RequestsContinue();
}
