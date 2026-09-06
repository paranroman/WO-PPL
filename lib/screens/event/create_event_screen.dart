import 'dart:io';
import 'package:eventure/api/storage_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eventure/navigation/app_router.dart';
import 'package:eventure/providers/auth_provider.dart';
import 'package:eventure/widgets/app_header.dart';
import 'package:eventure/widgets/app_scaffold.dart';
import 'package:eventure/widgets/custom_button.dart';
import 'package:eventure/widgets/custom_textfield.dart';
import 'package:eventure/widgets/custom_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import 'location_picker_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final Color primaryColor = const Color(0xFFD64A53);

  final nameController = TextEditingController();
  final organizerController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();

  final customEventTypeController = TextEditingController();
  final tagsController = TextEditingController();
  final onlineLinkController = TextEditingController();

  File? _bannerImageFile;
  File? _photoImageFile;
  PlatformFile? suratFile;

  LatLng? _selectedLatLng;
  String? _selectedLocationLabel;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isSubmitting = false;

  String? _selectedEventType;
  DateTime? _selectedDate;
  bool _isOnline = false;

  final List<String> _eventTypes = const [
    'Workshop',
    'Seminar',
    'Webinar',
    'Lomba',
    'Lainnya',
  ];

  @override
  void dispose() {
    nameController.dispose();
    organizerController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    dateController.dispose();
    customEventTypeController.dispose();
    tagsController.dispose();
    onlineLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerPicker(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          _buildLabel("Nama Event"),
                          CustomTextField(
                            hintText: "Masukkan nama event",
                            icon: Icons.event,
                            controller: nameController,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel("Nama Penyelenggara"),
                          CustomTextField(
                            hintText: "Masukkan nama penyelenggara",
                            icon: Icons.person,
                            controller: organizerController,
                          ),
                          const SizedBox(height: 16),

                          CustomFilePicker(
                            label: "Surat Keputusan (SK)",
                            fileName: suratFile?.name,
                            onFilePicked: (file) {
                              setState(() => suratFile = file);
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildLabel("Deskripsi Event"),
                          _buildDescriptionField(),
                          const SizedBox(height: 16),

                          _buildLabel("Tipe Event"),
                          const SizedBox(height: 6),
                          _buildEventTypeDropdown(),
                          const SizedBox(height: 12),
                          if (_selectedEventType == 'Lainnya')
                            CustomTextField(
                              hintText: "Isi tipe event secara manual",
                              icon: Icons.edit,
                              controller: customEventTypeController,
                            ),

                          const SizedBox(height: 16),

                          _buildLabel("Tag Acara"),
                          const SizedBox(height: 6),
                          CustomTextField(
                            hintText: "Contoh: IT, Pemula, Gratis",
                            icon: Icons.sell_outlined,
                            controller: tagsController,
                          ),

                          const SizedBox(height: 16),

                          _buildLabel("Tanggal Pelaksanaan"),
                          const SizedBox(height: 6),
                          _buildDatePicker(),

                          const SizedBox(height: 16),

                          _buildLabel("Lokasi Acara"),
                          _buildLocationPicker(),
                          const SizedBox(height: 16),

                          _buildLabel("Waktu Pelaksanaan"),
                          _buildTimePickers(),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: CustomButton(
                              text: _isSubmitting
                                  ? "Mempublish..."
                                  : "Publish Event",
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _publishEvent(),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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

  Widget _buildBannerPicker() {
    ImageProvider bannerImage = _bannerImageFile != null
        ? FileImage(_bannerImageFile!)
        : const NetworkImage(
            "https://via.placeholder.com/1080x400/E55B5B/FFFFFF?text=Banner+Event",
          );

    ImageProvider photoImage = _photoImageFile != null
        ? FileImage(_photoImageFile!)
        : const NetworkImage(
            "https://via.placeholder.com/200x200/E55B5B/FFFFFF?text=Foto",
          );

    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: _pickBannerImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: bannerImage, fit: BoxFit.cover),
              ),
            ),
          ),
          Container(height: 180, color: Colors.black.withAlpha(35)),
          Positioned(
            right: 20,
            bottom: 20,
            child: InkWell(
              onTap: _pickBannerImage,
              child: Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: 30,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(radius: 50, backgroundImage: photoImage),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: _pickPhotoImage,
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: InkWell(
              onTap: () => context.go(AppRoutes.home),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
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

  Future<void> _pickBannerImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;
      if (picked.size / (1024 * 1024) > 2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran banner maksimal 2 MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (picked.path != null) {
        setState(() => _bannerImageFile = File(picked.path!));
      }
    }
  }

  Future<void> _pickPhotoImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.first;
      if (picked.size / (1024 * 1024) > 2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran foto maksimal 2 MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (picked.path != null) {
        setState(() => _photoImageFile = File(picked.path!));
      }
    }
  }

  Widget _buildEventTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEventType,
          isExpanded: true,
          hint: const Text(
            "Pilih tipe event",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFFBBBBBB),
            ),
          ),
          items: _eventTypes
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedEventType = value;
              if (value != 'Lainnya') {
                customEventTypeController.clear();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final text = _selectedDate != null
        ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
        : 'Pilih tanggal pelaksanaan';

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 1.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: Color(0xFFD64F5C),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: _selectedDate != null
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: _selectedDate != null
                      ? Colors.black87
                      : const Color(0xFFBBBBBB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildLocationPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioGroup<bool>(
            groupValue: _isOnline,
            onChanged: (v) => setState(() => _isOnline = v!),
            child: Row(
              children: const [
                Radio<bool>(value: false),
                Text('Offline'),
                Radio<bool>(value: true),
                Text('Online'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (!_isOnline)
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickLocationOnMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.location_pin),
                  label: const Text(
                    "Pilih di Maps",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedLocationLabel ?? 'Belum ada lokasi dipilih',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _selectedLocationLabel == null
                          ? const Color(0xFFAAAAAA)
                          : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            CustomTextField(
              hintText: "Masukkan Link Online Meeting",
              icon: Icons.link,
              controller: onlineLinkController,
            ),
        ],
      ),
    );
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );

    if (result != null) {
      _selectedLatLng = result;
      await _updateAddressFromLatLng(result);
    }
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final addressParts = [
          p.name,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((e) => (e ?? '').isNotEmpty).toList();

        final readableAddress = addressParts.join(', ');

        if (readableAddress.isNotEmpty) {
          setState(() {
            _selectedLocationLabel = readableAddress;
            locationController.text = readableAddress;
          });
          return;
        }
      }

      setState(() {
        _selectedLocationLabel = 'Alamat tidak ditemukan';
        locationController.text = 'Alamat tidak ditemukan';
      });
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      setState(() {
        _selectedLocationLabel = 'Gagal memuat alamat';
        locationController.text = 'Gagal memuat alamat';
      });
    }
  }

  Widget _buildTimePickers() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSingleTimeField(
                label: "Mulai",
                value: _startTime,
                onTap: _pickStartTime,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSingleTimeField(
                label: "Selesai",
                value: _endTime,
                onTap: _pickEndTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            dateController.text.isEmpty
                ? "Format tersimpan: HH:MM - HH:MM"
                : "Tersimpan: ${dateController.text}",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Color(0xFF888888),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleTimeField({
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor, width: 1.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                  Text(
                    value != null ? _formatTime(value) : "Pilih jam & menit",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: value != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: value != null
                          ? Colors.black87
                          : const Color(0xFFBBBBBB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        _updateDateControllerText();
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
        _updateDateControllerText();
      });
    }
  }

  void _updateDateControllerText() {
    if (_startTime != null && _endTime != null) {
      dateController.text =
          "${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}";
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatDateForDb(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day'; // contoh: 2025-12-12
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        style: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        controller: descriptionController,
        maxLines: 5,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Tuliskan deskripsi event...",
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: (MediaQuery.of(context).size.width * 0.035).clamp(
              12.0,
              16.0,
            ),
            color: const Color(0xFFCCCCCC),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Future<void> _publishEvent() async {
    final name = nameController.text.trim();
    final organizerName = organizerController.text.trim();
    final description = descriptionController.text.trim();
    final tags = tagsController.text.trim();
    final onlineLink = onlineLinkController.text.trim();
    final rawLocation = locationController.text.trim();

    final resolvedEventType = _selectedEventType == 'Lainnya'
        ? customEventTypeController.text.trim()
        : _selectedEventType;

    if (name.isEmpty ||
        organizerName.isEmpty ||
        description.isEmpty ||
        resolvedEventType == null ||
        resolvedEventType.isEmpty ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        suratFile == null ||
        (_isOnline && onlineLink.isEmpty) ||
        (!_isOnline && (rawLocation.isEmpty || _selectedLatLng == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data wajib'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newEventRef = FirebaseDatabase.instance.ref('events').push();
      final eventId = newEventRef.key!;

      String? bannerDownloadUrl;
      String? photoDownloadUrl;
      String? skDownloadUrl;

      if (_bannerImageFile != null) {
        final ext = _bannerImageFile!.path.split('.').last;
        bannerDownloadUrl = await StorageService().uploadDocument(
          _bannerImageFile!,
          eventId,
          'banner.$ext',
        );
      }

      if (_photoImageFile != null) {
        final ext = _photoImageFile!.path.split('.').last;
        photoDownloadUrl = await StorageService().uploadDocument(
          _photoImageFile!,
          eventId,
          'photo.$ext',
        );
      }

      if (suratFile != null && suratFile!.path != null) {
        final skFile = File(suratFile!.path!);
        final ext = skFile.path.split('.').last;
        skDownloadUrl = await StorageService().uploadDocument(
          skFile,
          eventId,
          'sk.$ext',
        );
      }

      final event = EventModel(
        id: eventId,
        title: name,
        description: description,
        locationAddress: _isOnline ? 'Online' : rawLocation,
        locationLat: _isOnline ? null : _selectedLatLng?.latitude,
        locationLng: _isOnline ? null : _selectedLatLng?.longitude,
        organizerId: await AuthProvider().currentUser(),
        organizerName: organizerName,
        startTime: _formatTime(_startTime!),
        endTime: _formatTime(_endTime!),
        createdAt: DateTime.now(),
        bannerUrl: bannerDownloadUrl,
        photoUrl: photoDownloadUrl,
        skUrl: skDownloadUrl,
        eventType: resolvedEventType,
        eventDay: _formatDateForDb(_selectedDate!),
        tags: tags,
        isOnline: _isOnline,
        onlineLink: _isOnline ? onlineLink : null,
      );

      await newEventRef.set(event.toJson());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event berhasil dipublish'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(AppRoutes.home);
    } catch (e) {
      debugPrint('Error publish event: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat publish event'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
