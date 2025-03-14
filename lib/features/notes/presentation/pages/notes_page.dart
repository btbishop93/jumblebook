import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
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

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/btbishop93/jumblebook');
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
        builder: (context) => BlocProvider<NotesBloc>.value(
          value: _notesBloc,
          child: NoteView(
            userId: widget.currentUser.id,
            note: newNote,
            isNewNote: true,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your account? This will permanently delete all your notes and account information. This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Add the delete account event
              final authBloc = context.read<AuthBloc>();
              authBloc.add(DeleteAccountRequested());
              
              // We'll handle the response in the BlocListener in the build method
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showReauthenticationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final emailController = TextEditingController(text: widget.currentUser.email);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // Check if user is using email/password authentication
    final isEmailAuth = !widget.currentUser.isAnonymous && widget.currentUser.email.isNotEmpty;
    
    if (!isEmailAuth) {
      // For social login or anonymous users, show a different message
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.security, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text('Authentication Required'),
            ],
          ),
          content: Text(
            widget.currentUser.isAnonymous
                ? 'Anonymous accounts cannot be deleted. You can simply sign out and your data will not be preserved.'
                : 'For security reasons, you need to sign out and sign in again with your social account before deleting your account.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            if (widget.currentUser.isAnonymous)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                child: Text('Sign Out'),
              ),
          ],
        ),
      );
      return;
    }
    
    // For email/password users, show the password confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text('Confirm Your Identity'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'For security reasons, please re-enter your password to delete your account.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // Email is pre-filled and read-only
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);
                
                // Re-authenticate and delete account
                context.read<AuthBloc>().add(
                  ReauthenticateAndDeleteAccountRequested(
                    email: emailController.text,
                    password: passwordController.text,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError && state.data.errorMessage == 'requires-recent-login') {
          // Show re-authentication dialog
          _showReauthenticationDialog(context);
        }
      },
      child: Scaffold(
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
                      label: Text('Log out', style: theme.textTheme.titleSmall),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(SignOutRequested());
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_canResetPassword) 
                      TextButton.icon(
                        icon: Icon(Icons.security, color: theme.primaryColor),
                        label: Text('Reset password',
                            style: theme.textTheme.titleSmall),
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
                    if (_canResetPassword) 
                      const SizedBox(height: 16),
                    TextButton.icon(
                      icon: Icon(Icons.delete_forever, color: theme.primaryColor),
                      label: Text('Delete account',
                          style: theme.textTheme.titleSmall),
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteAccountConfirmationDialog(context);
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
                      'Help | Support',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _launchGitHub,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.scaffoldBackgroundColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          side: BorderSide(
                            color: theme.dividerColor,
                            width: 1.5,
                          ),
                          shadowColor: theme.shadowColor.withOpacity(0.5),
                        ).copyWith(
                          elevation: WidgetStateProperty.resolveWith<double>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return 4;
                              }
                              return 2;
                            },
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/social/github-mark.svg',
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                theme.textTheme.labelLarge?.color ?? Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'View on GitHub',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
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
              child: BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  if (state is NotesError) {
                    return Center(
                      child: Text(state.errorMessage ?? 'An error occurred'),
                    );
                  }
                  return NotesList(userId: widget.currentUser.id);
                },
              ),
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
      ),
    );
  }
}
