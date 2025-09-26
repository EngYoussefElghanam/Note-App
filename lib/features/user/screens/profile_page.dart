import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_taker/features/notes/cubit/study_notes_cubit.dart';
import 'package:notes_taker/features/auth/cubit/auth_cubit.dart';
import 'package:notes_taker/features/notes/cubit/notes_cubit.dart';
import 'package:notes_taker/models/user_info.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imgPick = ImagePicker();
  File? cachedImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return _buildSkeleton(theme, colorScheme);
                  }

                  if (state is AuthFailure) {
                    return Text("Error: ${state.message}");
                  }

                  if (state is AuthSuccess || state is AuthInitial) {
                    return FutureBuilder<UserData?>(
                      future: context.read<AuthCubit>().getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildSkeleton(theme, colorScheme);
                        }
                        if (!snapshot.hasData) {
                          return const Text("No user data found");
                        }

                        final user = snapshot.data!;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final picked = await _imgPick.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (picked != null) {
                                  context.read<AuthCubit>().updateUserProfile(
                                    picked,
                                    user.name,
                                  );
                                }
                              },
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: cachedImage != null
                                    ? FileImage(cachedImage!)
                                    : (user.imgUrl != null &&
                                          user.imgUrl!.isNotEmpty)
                                    ? NetworkImage(user.imgUrl!)
                                    : const AssetImage("assets/images/user.png")
                                          as ImageProvider,
                              ),
                            ),

                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: theme.textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }

                  return _buildSkeleton(theme, colorScheme);
                },
              ),

              const SizedBox(height: 32),

              BlocBuilder<StudyNotesCubit, StudyNotesState>(
                builder: (context, state) {
                  final countStudy = state is StudyNotesSuccess
                      ? state.notes.length
                      : 0;
                  return BlocBuilder<NotesCubit, NotesState>(
                    builder: (context, state) {
                      final countNotes = state is NotesSuccess
                          ? state.notes.length
                          : 0;
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(
                            Icons.sticky_note_2_outlined,
                            color: colorScheme.primary,
                          ),
                          title: Text(
                            "${countStudy + countNotes} notes",
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              _buildActionButtons(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: 120,
          color: colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: 200,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            icon: const Icon(Icons.settings),
            label: const Text("Settings"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
