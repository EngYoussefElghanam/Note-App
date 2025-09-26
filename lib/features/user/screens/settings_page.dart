import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';
import 'package:notes_taker/features/auth/cubit/auth_cubit.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';
import 'package:notes_taker/features/notes/cubit/notes_cubit.dart';
import 'package:notes_taker/features/notes/cubit/study_notes_cubit.dart';
import 'package:notes_taker/models/user_info.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? cachedImage;
  final ImagePicker _imgPick = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  bool editingName = false;
  bool _loadingUser = true;
  bool _uploadingImage = false; // 🔑 new flag
  UserData? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthServicesImpl().getUserData();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loadingUser = false;
    });
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colors.onPrimary,
      ),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) async {
            if (state is AuthSuccess) {
              await _loadUser();
              if (mounted) {
                setState(() {
                  editingName = false;
                  _uploadingImage = false; // stop loader
                });
              }
            } else if (state is AuthFailure) {
              if (mounted) {
                setState(() => _uploadingImage = false); // stop loader
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Stack(
            children: [
              _loadingUser
                  ? const Center(child: CircularProgressIndicator())
                  : _user == null
                  ? const Center(child: Text("No user data found"))
                  : _buildContent(theme, colors),
              if (_uploadingImage)
                // 🔑 Overlay when uploading image
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          "Uploading image...",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProfileSection(theme, colors),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
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
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          _buildNotesCount(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, ColorScheme colors) {
    final user = _user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await _imgPick.pickImage(
              source: ImageSource.gallery,
            );
            if (picked != null) {
              setState(() => _uploadingImage = true); // start loader
              context.read<AuthCubit>().updateUserProfile(picked, user.name);
            }
          },
          child: CircleAvatar(
            radius: 50,
            backgroundImage: cachedImage != null
                ? FileImage(cachedImage!)
                : (user.imgUrl != null && user.imgUrl!.isNotEmpty)
                ? NetworkImage(user.imgUrl!)
                : const AssetImage("assets/images/user.png") as ImageProvider,
          ),
        ),
        const SizedBox(height: 16),
        editingName
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Enter your name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      context.read<AuthCubit>().updateUserData(
                        name: _nameController.text.trim(),
                      );
                    },
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.name, style: theme.textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => editingName = true),
                  ),
                ],
              ),
        const SizedBox(height: 8),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCount() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notes, size: 48),
              const SizedBox(height: 8),
              BlocBuilder<NotesCubit, NotesState>(
                builder: (_, state) {
                  final count = state is NotesSuccess ? state.notes.length : 0;
                  return Text(
                    "$count",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              Text("General", style: theme.textTheme.bodySmall),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.book, size: 48),
              const SizedBox(height: 8),
              BlocBuilder<StudyNotesCubit, StudyNotesState>(
                builder: (_, state) {
                  final count = state is StudyNotesSuccess
                      ? state.notes.length
                      : 0;
                  return Text(
                    "$count",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              Text("Study", style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
