import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              TextButton.icon(
                icon: Icon(
                  state.themeMode == ThemeMode.system
                    ? Icons.brightness_auto
                    : state.themeMode == ThemeMode.light
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  color: theme.primaryColor,
                ),
                label: Text('Dark mode', style: theme.textTheme.labelLarge),
                onPressed: () {},
              ),
              const Spacer(),
              Switch(
                value: state.themeMode == ThemeMode.dark || 
                       (state.themeMode == ThemeMode.system && 
                        MediaQuery.platformBrightnessOf(context) == Brightness.dark),
                onChanged: (bool value) {
                  if (state.themeMode == ThemeMode.system) {
                    context.read<ThemeBloc>().add(
                      ChangeThemeEvent(value ? ThemeMode.dark : ThemeMode.light)
                    );
                  } else {
                    context.read<ThemeBloc>().add(
                      const ChangeThemeEvent(ThemeMode.system)
                    );
                  }
                },
                activeColor: theme.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
} 