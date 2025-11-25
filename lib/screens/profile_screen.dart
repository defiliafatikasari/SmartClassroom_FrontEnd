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
      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });

      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
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

      if (!mounted) return;

      setState(() {
        _user = updatedUser;
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isSaving = false);
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
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isLoading && _user != null)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Colors.indigo.shade700,
              ),
              onPressed: () =>
                  _isEditing ? _cancelEdit() : setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text("Profile not found"))
              : _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 20),
          _buildProfileCard(),
        ],
      ),
    );
  }

  // Header Gradient + Avatar
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.deepPurple.shade500],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.indigo.shade200, blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: Text(
              _user!.name[0].toUpperCase(),
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _user!.email,
            style: TextStyle(
                color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Chip(
            label: Text(
              "Role: ${_user!.role}",
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
            backgroundColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  // Card Glassmorphism untuk form & info
  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState:
              _isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: _buildInfoView(),
          secondChild: _buildEditForm(),
        ),
      ),
    );
  }

  // View Mode
  Widget _buildInfoView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Informasi Akun:",
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
        const SizedBox(height: 16),
        _infoTile(Icons.person, "Name", _user!.name),
        _infoTile(Icons.email, "Email", _user!.email),
        _infoTile(Icons.school, "Role", _user!.role),
        _infoTile(Icons.verified, "Status", "Active"),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.indigo.shade700),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(value, style: const TextStyle(fontSize: 13)),
    );
  }

  // Edit Form Mode
  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Edit Profile",
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
          const SizedBox(height: 20),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: "Full Name", prefixIcon: Icon(Icons.person)),
            validator: (value) =>
                value == null || value.isEmpty ? "Name cannot be empty" : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
                labelText: "Email", prefixIcon: Icon(Icons.email)),
            validator: (value) =>
                value == null || !value.contains("@") ? "Enter a valid email" : null,
          ),

          const SizedBox(height: 30),

          Row(
            children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _cancelEdit,
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Save"),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
