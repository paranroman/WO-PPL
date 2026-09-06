import 'dart:io';
import 'package:eventure/navigation/app_router.dart';
import 'package:eventure/providers/auth_provider.dart';
import 'package:eventure/utils/toast_helper.dart';
import 'package:eventure/widgets/custom_button.dart';
import 'package:eventure/widgets/custom_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color _scaffoldBg = const Color(0xFFF9F5F6);
  final Color _brandColor = const Color(0xFFE55B5B);

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoadingUser = true;

  File? _profileImageFile;
  File? _ktmFile;

  String? _initialProfileUrl;
  String? _ktmFileLabel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = context.read<AuthProvider>();
    final user = await auth.getUserData();

    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _initialProfileUrl = user.profilePicture;
        if (user.ktm.isNotEmpty) {
          _ktmFileLabel = "KTM sudah terunggah";
        }
        _isLoadingUser = false;
      });
    } else {
      setState(() => _isLoadingUser = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _brandColor),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text(
          "Edit Profil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileImagePicker(),
                  const SizedBox(height: 35),
                  _buildForm(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: CustomButton(text: "Simpan", onPressed: _handleSave),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            hintText: "Nama Lengkap",
            icon: Icons.person,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: _emailController,
            hintText: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: _phoneController,
            hintText: "Nomor Telepon",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildKtmPicker(),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    ImageProvider profileImage;

    if (_profileImageFile != null) {
      profileImage = FileImage(_profileImageFile!);
    } else if (_initialProfileUrl != null && _initialProfileUrl!.isNotEmpty) {
      profileImage = NetworkImage(_initialProfileUrl!);
    } else {
      profileImage = const AssetImage("assets/images/person.png");
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10),
              ],
              image: DecorationImage(image: profileImage, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickProfileImage,
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: _brandColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;
      final fileSizeInMB = picked.size / (1024 * 1024);

      if (fileSizeInMB > 2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran file melebihi batas maksimal 2 MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (picked.path != null) {
        setState(() => _profileImageFile = File(picked.path!));
      }
    }
  }

  Widget _buildKtmPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Kartu Tanda Mahasiswa (KTM)",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFD64F5C), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _pickKtmFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD64F5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Pilih KTM',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _ktmFileLabel ?? 'Belum ada file dipilih',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _ktmFileLabel != null
                        ? Colors.black
                        : const Color(0xFFCCCCCC),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickKtmFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;
      final fileSizeInMB = picked.size / (1024 * 1024);

      if (fileSizeInMB > 2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran file melebihi batas maksimal 2 MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (picked.path != null) {
        setState(() {
          _ktmFile = File(picked.path!);
          _ktmFileLabel = picked.name;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    final auth = context.read<AuthProvider>();

    final success = await auth.changeUserData(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      newKtm: _ktmFile,
      newProfilePicture: _profileImageFile,
    );

    if (!mounted) return;

    if (success) {
      ToastHelper.showShortToast("Profil berhasil diperbarui");
      context.go(AppRoutes.home);
    } else {
      ToastHelper.showShortToast("Gagal memperbarui profil");
    }
  }
}
