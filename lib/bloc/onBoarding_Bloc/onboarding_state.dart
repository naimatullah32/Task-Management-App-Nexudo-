// import 'package:equatable/equatable.dart';


part of 'onboarding_bloc.dart';


abstract class OnboardingState extends Equatable {
  final int currentPage;
  final int totalPages;

  const OnboardingState({
    required this.currentPage,
    required this.totalPages,
  });

  bool get isFirstPage => currentPage == 0;
  bool get isLastPage => currentPage == totalPages - 1;

  @override
  List<Object> get props => [currentPage, totalPages];
}

/// Normal browsing state
class OnboardingInProgress extends OnboardingState {
  const OnboardingInProgress({
    required super.currentPage,
    required super.totalPages,
  });

  OnboardingInProgress copyWith({int? currentPage}) => OnboardingInProgress(
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages,
  );
}

/// User has completed onboarding — navigate away
class OnboardingFinished extends OnboardingState {
  const OnboardingFinished({required super.totalPages})
      : super(currentPage: totalPages - 1);
}