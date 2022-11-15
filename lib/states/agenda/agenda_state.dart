part of 'agenda_bloc.dart';

@immutable
abstract class AgendaState {}

class AgendaInitial extends AgendaState {}
class AgendaReady extends AgendaState {}
class AgendaCacheReady extends AgendaState {}
class AgendaLoading extends AgendaState {}
class AgendaError extends AgendaState {}
class AgendaDateUpdated extends AgendaState {}
