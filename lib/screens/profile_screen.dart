import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
        if (user != null) {
          _nameController.text = user.name;
          _emailController.text = user.email;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final updatedUser = await authService.updateProfile(
        _nameController.text.trim(),
        _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _user = updatedUser;
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      if (_user != null) {
        _nameController.text = _user!.name;
        _emailController.text = _user!.email;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isLoading && _user != null)
            IconButton(
              onPressed: _isEditing ? _cancelEdit : () => setState(() => _isEditing = true),
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Profile not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          _user!.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _user!.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user!.email,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Chip(
                        label: Text('Role: ${_user!.role}'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _isEditing
                              ? Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Edit Profile',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                          prefixIcon: Icon(Icons.person),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          prefixIcon: Icon(Icons.email),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Email is required';
                                          }
                                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                            return 'Enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _isSaving ? null : _cancelEdit,
                                              child: const Text('Cancel'),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: FilledButton(
                                              onPressed: _isSaving ? null : _saveProfile,
                                              child: _isSaving
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    )
                                                  : const Text('Save'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account Information',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    ListTile(
                                      leading: const Icon(Icons.person),
                                      title: const Text('Name'),
                                      subtitle: Text(_user!.name),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.email),
                                      title: const Text('Email'),
                                      subtitle: Text(_user!.email),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.school),
                                      title: const Text('Role'),
                                      subtitle: Text(_user!.role),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.verified_user),
                                      title: const Text('Account Status'),
                                      subtitle: const Text('Active'),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}