import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/template.dart';
import 'requests_event.dart';
import 'requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  RequestsBloc() : super(const RequestsState()) {
    on<RequestsLoadTemplates>(_onLoadTemplates);
    on<RequestsSelectTemplate>(_onSelectTemplate);
    on<RequestsContinue>(_onContinue);
  }

  void _onLoadTemplates(
    RequestsLoadTemplates event,
    Emitter<RequestsState> emit,
  ) {
    // Datos de ejemplo basados en la imagen
    final templates = [
      Template(
        id: '1',
        name: 'Plantilla 1',
        origin: 'La Molina, Lima',
        destination: 'La Victoria, Chiclayo',
        totalArticles: 16,
        totalWeight: 492.8,
        items: [
          const TemplateItem(name: 'Televisión', quantity: 8, isFragile: true),
        ],
      ),
      Template(
        id: '2',
        name: 'Plantilla 2',
        origin: 'La Molina, Lima',
        destination: 'La Victoria, Chiclayo',
        totalArticles: 16,
        totalWeight: 492.8,
        items: [
          const TemplateItem(name: 'Televisión', quantity: 8, isFragile: true),
        ],
      ),
      Template(
        id: '3',
        name: 'Plantilla 3',
        origin: 'La Molina, Lima',
        destination: 'La Victoria, Chiclayo',
        totalArticles: 16,
        totalWeight: 492.8,
        items: [
          const TemplateItem(name: 'Televisión', quantity: 8, isFragile: true),
        ],
      ),
    ];

    emit(state.copyWith(templates: templates));
  }

  void _onSelectTemplate(
    RequestsSelectTemplate event,
    Emitter<RequestsState> emit,
  ) {
    emit(state.copyWith(
      selectedTemplateId: event.templateId == state.selectedTemplateId
          ? null // Deseleccionar si se hace clic en la misma plantilla
          : event.templateId,
    ));
  }

  void _onContinue(
    RequestsContinue event,
    Emitter<RequestsState> emit,
  ) {
    // Aquí se puede navegar a la siguiente pantalla
    // con o sin plantilla seleccionada
  }
}
