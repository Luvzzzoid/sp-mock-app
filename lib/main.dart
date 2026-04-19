import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/mock_data.dart';
import 'src/mock_theme.dart';
part 'src/inbox_pages.dart';
part 'src/create_pages.dart';
part 'src/discussion_widgets.dart';
part 'src/detail_shell.dart';
part 'src/event_detail_pages.dart';
part 'src/feed_widgets.dart';
part 'src/foundation_pages.dart';
part 'src/app_shell.dart';
part 'src/onboarding_page.dart';
part 'src/personal_timeline.dart';
part 'src/profile_page.dart';
part 'src/shell_widgets.dart';
part 'src/shared_widgets.dart';
part 'src/ui_helpers.dart';
part 'src/project_workflow_pages.dart';
part 'src/search_page.dart';
part 'src/social_scope_pages.dart';
part 'src/settings_page.dart';

bool get _desktopWindowControlsEnabled =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

final ValueNotifier<bool> leftRailVisibleListenable = ValueNotifier<bool>(true);
final ValueNotifier<bool> rightRailVisibleListenable = ValueNotifier<bool>(
  true,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}
