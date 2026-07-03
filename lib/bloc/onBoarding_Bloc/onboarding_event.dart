part of 'onboarding_bloc.dart';

// import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

/// User swiped or tapped Next — move to the next page
class OnboardingNextPage extends OnboardingEvent {
  const OnboardingNextPage();
}

/// User tapped a specific dot indicator
class OnboardingJumpToPage extends OnboardingEvent {
  final int index;
  const OnboardingJumpToPage(this.index);

  @override
  List<Object> get props => [index];
}

/// PageView notified us the page changed (swipe gesture)
class OnboardingPageChanged extends OnboardingEvent {
  final int index;
  const OnboardingPageChanged(this.index);

  @override
  List<Object> get props => [index];
}

/// User tapped Skip — jump to last page
class OnboardingSkip extends OnboardingEvent {
  const OnboardingSkip();
}

/// User tapped "Get Started" on the last page
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}