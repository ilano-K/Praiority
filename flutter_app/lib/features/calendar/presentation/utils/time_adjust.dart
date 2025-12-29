// File: lib/features/calendar/presentation/utils/time_adjust.dart
// Purpose: Small shared helpers to ensure a candidate DateTime does not
// precede a reference DateTime. Used by UI sheets to keep deadline/end
// times consistent with chosen start times/dates without duplicating logic.

/// Returns `candidate` unchanged if it's >= `reference`.
/// If `candidate` is before `reference`, returns `reference.add(bumpIfBefore)`.
DateTime ensureNotBefore(DateTime candidate, DateTime reference, {Duration bumpIfBefore = const Duration(seconds: 0)}) {
  if (candidate.isBefore(reference)) {
    return reference.add(bumpIfBefore);
  }
  return candidate;
}
