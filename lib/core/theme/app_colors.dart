import 'package:flutter/material.dart';

/// Colors for the Cabinet Design & Estimating Platform (mobile app).
///
/// Screen names match the frame names on the "🎨 UI Design" page in Figma.
/// Usage was taken from the actual layers in the file.
///
/// Mobile screens:
///   Auth      → Login Screen, Forgot Password, OTP, Create Account, Profile Setup
///   Main      → Home, All Jobs, Catalog, Catalog Details, Catalog Add
///   Job flow  → Create Job, Job Details, Room Capture, Measurements,
///               Continue to Room Captured, Ai Layout, Estimate, Proposal
///   Settings  → Settings, Edit Profile, General Settings, Change Password,
///               Notification settings, Delete Account, Contact us
class AppColors {
  AppColors._();

  // ===========================================================================
  // BRAND
  // ===========================================================================

  /// #C29266. Main brand color, the most used color in the app.
  /// Fill:   Primary buttons on every screen that has one (Sign In, Verify,
  ///         Create Account, Save Profile, Create Job, Continue to…,
  ///         Generate Proposal, Download PDF, Add to Project), the
  ///         StepProgressBar "done" segments (Job Details → Proposal),
  ///         the active filter chip (All Jobs, Catalog screens),
  ///         the Home "Create New Job" arrow button, and the FAB
  ///         (Home, All Jobs, Catalog, Catalog Details, Catalog Add).
  /// Text:   Prices (Catalog, Catalog Details, Catalog Add, Proposal),
  ///         links ("Sign Up", "Sign In", "Forgot Password", "Resend",
  ///         "View all"), the active bottom-nav label (Settings, Catalog
  ///         screens), and Proposal section labels ("Prepared For",
  ///         "Quotation Summary", "Terms"). OTP digits.
  /// Border: See [borderFocus].
  static const primary = Color(0xFFC29266); // brown-500

  /// #AF835C. Not drawn on any screen. Hover state for [primary]
  /// (from the Style Guide). Use for web hover / desktop.
  static const primaryHover = Color(0xFFAF835C);

  /// #9B7552. Not drawn on any screen. Pressed state for [primary]
  /// (from the Style Guide). Use for button splash/pressed color.
  static const primaryPressed = Color(0xFF9B7552);

  /// #926E4D. Not drawn on any screen. Style Guide "Brown/Dark".
  static const primaryDark = Color(0xFF926E4D);

  /// #443324. Not drawn on any screen. Style Guide "Brown/Darker".
  static const primaryDarker = Color(0xFF443324);

  // ---------------------------------------------------------------------------
  // Brown scale (Style Guide swatches)
  // Only 50, 100 and 500 appear on real screens; the rest are for future use.
  // ---------------------------------------------------------------------------

  /// #F9F4F0. Same value as [surfaceCream]; see there for screens.
  static const brown50 = Color(0xFFF9F4F0);

  /// #ECDDD0. Same value as [border] and [surfaceTag]; see there for screens.
  static const brown100 = Color(0xFFECDDD0);

  /// Not used on screens.
  static const brown200 = Color(0xFFE3CDB9);

  /// Not used on screens.
  static const brown300 = Color(0xFFD6B698);

  /// Not used on screens.
  static const brown400 = Color(0xFFCEA885);

  /// #C29266. Same value as [primary].
  static const brown500 = Color(0xFFC29266);

  /// Not used on screens.
  static const brown600 = Color(0xFFB1855D);

  /// Not used on screens.
  static const brown700 = Color(0xFF8A6848);

  /// Not used on screens.
  static const brown800 = Color(0xFF6B5038);

  /// Not used on screens.
  static const brown900 = Color(0xFF513D2B);

  // ===========================================================================
  // BACKGROUNDS & SURFACES
  // ===========================================================================

  /// #FDFCFA. Default screen background (Scaffold) on 19 screens:
  /// All Jobs, Catalog, Catalog Details, Catalog Add, Create Job, Job Details,
  /// Room Capture, Measurements, Continue to Room Captured, Ai Layout,
  /// Estimate, Proposal, Settings, Edit Profile, General Settings,
  /// Change Password, Notification settings, Delete Account, Contact us.
  static const background = Color(0xFFFDFCFA);

  /// #F2EEE3. Warm screen background on Home, Create Account, Profile Setup.
  /// Also used at 85% opacity for the Home bottom nav (glass effect).
  static const backgroundWarm = Color(0xFFF2EEE3);

  /// #FFFFFF.
  /// Screen background: Login Screen, Forgot Password, OTP.
  /// Cards: Home "Recent Jobs" card, Settings / General Settings /
  ///        Notification settings list groups, Profile Setup, Contact us.
  /// Text:  See [onPrimary].
  static const surface = Color(0xFFFFFFFF);

  /// #F9F4F0. Cream surface, used on 24 screens.
  /// Bottom action bar behind "Continue to…" buttons (all Job-flow screens),
  /// bottom navigation bar (Home, Catalog screens, Settings),
  /// measurement boxes (Catalog Details), product card background
  /// (Catalog screens), and container backgrounds on Settings screens.
  static const surfaceCream = Color(0xFFF9F4F0);

  /// #ECDDD0. Tag / chip fill.
  /// Category tags "Base / Wall / Tall / Island" (Catalog, Catalog Details,
  /// Catalog Add), inactive filter chips (All Jobs, Catalog screens),
  /// Home round notification button, Proposal header container.
  static const surfaceTag = Color(0xFFECDDD0);

  /// #D9D9D9. Empty (not yet done) step segments.
  /// StepProgressBar: Job Details, Room Capture, Measurements,
  /// Continue to Room Captured, Ai Layout, Estimate.
  /// MiniStepProgress in job cards: Home, All Jobs.
  static const progressEmpty = Color(0xFFD9D9D9);

  /// #000000 @ 25% opacity. Backdrop behind the web auth card and behind
  /// modal dialogs/bottom sheets (AppDialogs.confirm's `barrierColor`).
  /// Use [overlayLight] instead for drawers/side-panel scrims.
  static const overlay = Color(0x40000000);

  /// #000000 @ 15% opacity. Lighter scrim for drawers/side panels
  /// (web Import Product, Product Details).
  static const overlayLight = Color(0x26000000);

  // ===========================================================================
  // TEXT
  // ===========================================================================

  /// #000000. Main dark text, used on 21 screens.
  /// Auth titles ("Forgot Password", "OTP", "Create Account", "Profile Setup"),
  /// input labels ("Email", "Password", "Width(M)", "Installation Charge"),
  /// Home "Create New Job", measurement values, Estimate prices & totals.
  static const textPrimary = Color(0xFF000000);

  /// #1E1E1E. App-bar titles (AppBackHeader) and some labels, 14 screens.
  /// Create Job, Job Details, Room Capture, Measurements,
  /// Continue to Room Captured, Ai Layout ("Design"), Estimate, Proposal,
  /// Change Password, Notification settings, Contact us, Delete Account,
  /// plus labels on Login Screen & Forgot Password.
  static const textDark = Color(0xFF1E1E1E);

  /// #1A2332. Titles inside cards and lists.
  /// Customer names in job cards (Home, All Jobs), product names
  /// (Catalog, Catalog Details, Catalog Add), "Recent Jobs" / "Overview"
  /// (Home), product rows (Estimate).
  static const textNavy = Color(0xFF1A2332);

  /// #3B2E2A. Home only: user name "Roberts Adam" and the active
  /// label in the Home bottom-nav variant.
  static const textWarmDark = Color(0xFF3B2E2A);

  /// #736862. Home only: "GOOD EVENING" greeting and inactive labels
  /// in the Home bottom-nav variant.
  static const textWarmMuted = Color(0xFF736862);

  /// #545454. Secondary text.
  /// Home card description ("Start a new project…"), filter chip text
  /// (All Jobs, Catalog screens), measurement labels "Width / Height / Depth"
  /// (Catalog Details), Estimate row sub-text, Continue to Room Captured.
  static const textSecondary = Color(0xFF545454);

  /// #7A7972. Meta / caption text (the most used grey for small text).
  /// Addresses, dates, "Step 5: AI Layout" (Home, All Jobs), SKU and
  /// dimensions (Catalog, Catalog Details, Catalog Add), Estimate table
  /// header & unit price, Proposal terms paragraph.
  static const textMeta = Color(0xFF7A7972);

  /// #7D7D7D. Muted text.
  /// Category tag text (Catalog screens), inactive bottom-nav labels
  /// (Settings, Catalog screens), SKU line (Catalog Add), OTP helper text,
  /// Proposal customer contact line.
  static const textMuted = Color(0xFF7D7D7D);

  /// #979797. Input placeholder / hint text on 10 screens.
  /// Forgot Password, Create Account, Profile Setup, Create Job, Job Details,
  /// Room Capture (option descriptions), Measurements,
  /// Continue to Room Captured, Estimate, and Login Screen (password eye icon).
  static const textPlaceholder = Color(0xFF979797);

  /// #B0B0B0. Placeholder text on Login Screen and Contact us only.
  /// ⚠️ Those two screens use an old Roboto input. Other screens use
  /// [textPlaceholder]. Prefer [textPlaceholder] and keep this for disabled.
  static const textDisabled = Color(0xFFB0B0B0);

  /// #FFFFFF. Text/icons on brown backgrounds, 17 screens.
  /// Primary button labels (all Auth + Job-flow screens), active filter chip
  /// "All" (All Jobs, Catalog screens), active step tab "AI Layout Engine"
  /// (Continue to Room Captured), Proposal header date.
  static const onPrimary = Color(0xFFFFFFFF);

  // ===========================================================================
  // BORDERS
  // ===========================================================================

  /// #ECDDD0. Default border & divider, used on 19 screens.
  /// All input field borders (Forgot Password, OTP boxes, Create Account,
  /// Profile Setup, Create Job, Job Details, Measurements, Estimate…),
  /// list dividers in job cards (Home, All Jobs), top border of the
  /// bottom nav / bottom action bar (Job-flow screens, Catalog, Settings),
  /// product card & measurement box borders (Catalog screens).
  static const border = Color(0xFFECDDD0);

  /// #C29266. Focused / active outline.
  /// Input borders on Login Screen & Contact us, selected product card and
  /// chip outlines (Catalog, Catalog Details, Catalog Add, All Jobs),
  /// Home, Settings.
  static const borderFocus = Color(0xFFC29266);

  /// #DDD9D0. Card border.
  /// Home "Recent Jobs" card, Estimate product table container.
  static const borderCard = Color(0xFFDDD9D0);

  // ===========================================================================
  // STATUS (StatusChip: background = color.withOpacity(0.20), text = color)
  // ===========================================================================

  /// #3B82B8. "New" job status chip (Home, All Jobs, Catalog Add).
  /// Also the "AI" badge on Room Capture.
  static const statusNew = Color(0xFF3B82B8);

  /// #D4A017. "In Progress" job status chip (Home, All Jobs, Catalog Add).
  static const statusInProgress = Color(0xFFD4A017);

  /// #7C3AED. "Proposal Sent" job status chip (Home, All Jobs).
  static const statusProposalSent = Color(0xFF7C3AED);

  /// #10B769. "Completed" job status chip (Home, All Jobs, Catalog Add).
  static const statusCompleted = Color(0xFF10B769);

  // ===========================================================================
  // SEMANTIC
  // ===========================================================================

  /// #EF4444. Used only in the ADMIN WEB panel (notification badge,
  /// delete button background, "Logout" text).
  /// ⚠️ The mobile app uses #FF4B26 instead: "Delete Account" button & text
  /// (Delete Account, General Settings) and the Log out button border
  /// (Settings). Decide on one red with the designer; if the mobile
  /// design stays as-is, switch this value to 0xFFFF4B26.
  static const error = Color(0xFFEF4444);

  /// #10B769. Success green.
  /// "Completed" status (Home, All Jobs), "Added" label (Catalog Add),
  /// check icons (Catalog Add, Continue to Room Captured).
  static const success = Color(0xFF10B769);

  // ===========================================================================
  // COMPONENT COLORS (added for the reusable widgets)
  // ===========================================================================

  /// #FF4B26. Mobile destructive red: "Delete Account" button & text
  /// (Delete Account, General Settings) and the Log out button (Settings).
  /// Used by AppDangerButton and text-field error borders.
  static const danger = Color(0xFFFF4B26);

  /// #F6F6F6. Border of the white cards on Settings, General Settings,
  /// Notification settings (SettingsGroup, SettingsProfileCard).
  static const borderLight = Color(0xFFF6F6F6);

  /// #F0F0F0. Divider between SettingsTile rows.
  static const dividerLight = Color(0xFFF0F0F0);

  /// #E6E6E6. SummaryCard background (Estimate: Sub Total / Tax / Total).
  static const surfaceGrey = Color(0xFFE6E6E6);

  /// #D7D7D7. Divider above "Total" in SummaryCard and between
  /// Estimate table rows.
  static const dividerGrey = Color(0xFFD7D7D7);

  /// #F3F3F3. Image placeholder / layout preview background
  /// (Measurements, Ai Layout, ProductCard without image).
  static const surfaceImage = Color(0xFFF3F3F3);

  /// #333333. SummaryRow labels ("Sub Total", "Tax(10%)", "Total").
  static const textLabel = Color(0xFF333333);

  /// #111111. SettingsTile labels ("Edit Profile", "General Settings"…).
  static const textTile = Color(0xFF111111);

  /// #292D32. Settings profile card name ("Smith Josh").
  static const textProfileName = Color(0xFF292D32);

  /// #696969. Chevron arrows on SettingsTile and profile email.
  static const iconMuted = Color(0xFF696969);

  /// #F6F6F6. Unselected product row fill (Select Product screen,
  /// ProductSelectTile).
  static const surfaceOption = Color(0xFFF6F6F6);

  /// #F0DCC4. Selected product row fill (Select Product screen,
  /// ProductSelectTile).
  static const surfaceOptionSelected = Color(0xFFF0DCC4);
}
