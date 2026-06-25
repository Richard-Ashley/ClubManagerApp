import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../venues/domain/venue_models.dart';

class NewBookingState {
  const NewBookingState({
    this.step = 1,
    this.venue,
    this.date,
    this.slot,
  });

  final int step; // 1 = venue, 2 = date, 3 = slot
  final Venue? venue;
  final DateTime? date;
  final VenueSlot? slot;

  NewBookingState copyWith({
    int? step,
    Venue? venue,
    DateTime? date,
    VenueSlot? slot,
    bool clearSlot = false,
    bool clearDate = false,
  }) {
    return NewBookingState(
      step: step ?? this.step,
      venue: venue ?? this.venue,
      date: clearDate ? null : (date ?? this.date),
      slot: clearSlot ? null : (slot ?? this.slot),
    );
  }
}

final newBookingProvider = StateNotifierProvider.autoDispose<NewBookingNotifier, NewBookingState>((ref) {
  return NewBookingNotifier();
});

class NewBookingNotifier extends StateNotifier<NewBookingState> {
  NewBookingNotifier() : super(const NewBookingState());

  void pickVenue(Venue venue) {
    state = state.copyWith(step: 2, venue: venue, clearDate: true, clearSlot: true);
  }

  void pickDate(DateTime date) {
    state = state.copyWith(date: date, clearSlot: true);
  }

  void pickSlot(VenueSlot slot) {
    state = state.copyWith(step: 3, slot: slot);
  }

  void goToStep(int step) {
    state = state.copyWith(step: step);
  }

  void back() {
    if (state.step > 1) state = state.copyWith(step: state.step - 1);
  }
}
