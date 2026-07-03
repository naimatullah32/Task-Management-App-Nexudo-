import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// import 'onboarding_event.dart';


part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final int totalPages;

  OnboardingBloc({required this.totalPages})
      : super(OnboardingInProgress(currentPage: 0, totalPages: totalPages)) {
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingJumpToPage>(_onJumpToPage);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingSkip>(_onSkip);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onNextPage(OnboardingNextPage event, Emitter<OnboardingState> emit) {
    final current = state.currentPage;
    if (current < totalPages - 1) {
      emit((state as OnboardingInProgress)
          .copyWith(currentPage: current + 1));
    } else {
      emit(OnboardingFinished(totalPages: totalPages));
    }
  }

  void _onJumpToPage(
      OnboardingJumpToPage event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      emit((state as OnboardingInProgress)
          .copyWith(currentPage: event.index));
    }
  }

  void _onPageChanged(
      OnboardingPageChanged event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      emit((state as OnboardingInProgress)
          .copyWith(currentPage: event.index));
    }
  }

  void _onSkip(OnboardingSkip event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      emit((state as OnboardingInProgress)
          .copyWith(currentPage: totalPages - 1));
    }
  }

  void _onCompleted(OnboardingCompleted event, Emitter<OnboardingState> emit) {
    emit(OnboardingFinished(totalPages: totalPages));
  }
}