enum SessionStatus {
  /// Has a working access token (or one that can be silently refreshed).
  authenticated,

  /// No tokens at all — never logged in, or logged out on purpose.
  /// The app should keep working; only routes that require login get gated.
  guest,

  /// Had a session that is no longer valid (refresh failed or was
  /// impossible with tokens present). Different from [guest] because the
  /// UI should say "please log in again," not just "please log in."
  expired,
}
