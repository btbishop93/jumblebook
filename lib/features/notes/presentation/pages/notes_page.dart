import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/pages/reset_password_page.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../widgets/notes_list.dart';
import '../widgets/note_view.dart';
import '../../../../core/theme/widgets/theme_switcher.dart';

class NotesPage extends StatefulWidget {
  final User currentUser;

  const NotesPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _canResetPassword = false;
  late final NotesBloc _notesBloc;

  Future<void> _launchBuyMeACoffee() async {
    final Uri url = Uri.parse('https://buymeacoffee.com/brendenbishop');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link. Please try again later.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkResetPasswordAvailability();
    // Get BLoC reference and start listening to notes changes
    _notesBloc = context.read<NotesBloc>();
    _notesBloc.add(StartListeningToNotes(widget.currentUser.id));
  }

  @override
  void dispose() {
    // Stop listening to notes changes using stored BLoC reference
    _notesBloc.add(StopListeningToNotes());
    super.dispose();
  }

  void _checkResetPasswordAvailability() {
    if (!mounted) return;
    setState(() {
      _canResetPassword = !widget.currentUser.isAnonymous;
    });
  }

  void _createNewNote() {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      date: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteView(
          userId: widget.currentUser.id,
          note: newNote,
          isNewNote: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/title.png',
          fit: BoxFit.contain,
          height: 36,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        backgroundColor: theme.scaffoldBackgroundColor,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Text(
                      'Settings',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.iconTheme.color),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.exit_to_app, color: theme.primaryColor),
                    label: Text('Log out', style: theme.textTheme.labelLarge),
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                  ),
                  if (_canResetPassword)
                    TextButton.icon(
                      icon: Icon(Icons.security, color: theme.primaryColor),
                      label: Text('Reset password', style: theme.textTheme.labelLarge),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordPage(
                              email: widget.currentUser.email,
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  const ThemeSwitcher(),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Want to support me?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _launchBuyMeACoffee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.scaffoldBackgroundColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/social/bmc-button.svg',
                        height: 56,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Note: All donations are optional and not required to use the app.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              theme.brightness == Brightness.light
                ? 'assets/images/background.png'
                : 'assets/images/background-dark.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0.5,
                  color: theme.dividerColor,
                ),
              ),
            ),
            child: NotesList(userId: widget.currentUser.id),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: FloatingActionButton(
          onPressed: _createNewNote,
          tooltip: 'New',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
} 