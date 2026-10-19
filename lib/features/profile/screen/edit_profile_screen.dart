import 'package:flutter/widgets.dart';

import '../../auth/screens/profile_screen.dart';

/// Editing an existing profile from Settings reuses [ProfileScreen]'s form
/// (avatar, full name, contact, address) — see that class for why the two
/// are shared instead of duplicated.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(isEditing: true);
  }
}
