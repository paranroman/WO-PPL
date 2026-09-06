import 'dart:io';
import 'package:eventure/widgets/app_header.dart';
import 'package:eventure/widgets/app_scaffold.dart';
import 'package:eventure/widgets/custom_button.dart';
import 'package:eventure/widgets/custom_file_picker.dart';
import 'package:eventure/widgets/custom_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../../api/database_service.dart';
import '../../models/event_model.dart';
import '../../navigation/app_router.dart';
import 'location_picker_screen.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
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

  String? _bannerUrlFromDb;
  String? _photoUrlFromDb;
  String? _skUrlFromDb;

  LatLng? _selectedLatLng;
  String? _selectedLocationLabel;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isSubmitting = false;

  String? _selectedEventType;
  DateTime? _selectedDate;
  bool _isOnline = false;

  bool _initialized = false;

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

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventRef = FirebaseDatabase.instance.ref('events/${widget.eventId}');

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: eventRef.onValue,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final raw = snap.data?.snapshot.value;
                  if (raw == null || raw is! Map) {
                    return const Center(
                      child: Text(
                        'Event tidak ditemukan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  final map = Map<String, dynamic>.from(raw);
                  final event = EventModel.fromJson(map);

                  if (!_initialized) {
                    _initialized = true;

                    nameController.text = event.title;
                    organizerController.text = event.organizerName;
                    descriptionController.text = event.description;
                    tagsController.text = event.tags;
                    onlineLinkController.text = event.onlineLink ?? '';

                    _isOnline = event.isOnline;

                    _bannerUrlFromDb = event.bannerUrl;
                    _photoUrlFromDb = event.photoUrl;
                    _skUrlFromDb = event.skUrl;

                    locationController.text = event.locationAddress;
                    _selectedLocationLabel = event.locationAddress;

                    if (!event.isOnline &&
                        event.locationLat != null &&
                        event.locationLng != null) {
                      _selectedLatLng = LatLng(
                        event.locationLat!,
                        event.locationLng!,
                      );
                    } else {
                      _selectedLatLng = null;
                    }

                    try {
                      _selectedDate = DateTime.parse(event.eventDay);
                    } catch (_) {
                      _selectedDate = null;
                    }

                    _startTime = _parseTime(event.startTime);
                    _endTime = _parseTime(event.endTime);
                    _updateDateControllerText();

                    final type = event.eventType.trim();
                    if (_eventTypes.contains(type)) {
                      _selectedEventType = type;
                      customEventTypeController.clear();
                    } else {
                      _selectedEventType = 'Lainnya';
                      customEventTypeController.text = type;
                    }
                  }

                  return SingleChildScrollView(
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
                                fileName:
                                    suratFile?.name ??
                                    (_skUrlFromDb != null
                                        ? 'SK sudah ada'
                                        : null),
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
                                      ? "Menyimpan..."
                                      : "Simpan Perubahan",
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => _updateEvent(event),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerPicker() {
    final ImageProvider bannerImage = _bannerImageFile != null
        ? FileImage(_bannerImageFile!)
        : (_bannerUrlFromDb != null && _bannerUrlFromDb!.isNotEmpty)
        ? NetworkImage(_bannerUrlFromDb!)
        : const NetworkImage(
            "https://via.placeholder.com/1080x400/E55B5B/FFFFFF?text=Banner+Event",
          );

    final ImageProvider photoImage = _photoImageFile != null
        ? FileImage(_photoImageFile!)
        : (_photoUrlFromDb != null && _photoUrlFromDb!.isNotEmpty)
        ? NetworkImage(_photoUrlFromDb!)
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
        _snack('Ukuran banner maksimal 2 MB', Colors.red);
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
        _snack('Ukuran foto maksimal 2 MB', Colors.red);
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
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedEventType = value;
              if (value != 'Lainnya') customEventTypeController.clear();
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
      setState(() => _selectedDate = picked);
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
                Text(
                  'Offline',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Radio<bool>(value: true),
                Text(
                  'Online',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
              fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w500,
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

  TimeOfDay? _parseTime(String raw) {
    try {
      final parts = raw.trim().split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
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

  Future<void> _updateEvent(EventModel oldEvent) async {
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
        (_isOnline && onlineLink.isEmpty) ||
        (!_isOnline && (rawLocation.isEmpty || _selectedLatLng == null))) {
      _snack('Lengkapi semua data wajib', Colors.red);
      return;
    }

    File? skFile;
    if (suratFile != null && suratFile!.path != null) {
      skFile = File(suratFile!.path!);
    }

    setState(() => _isSubmitting = true);

    try {
      await DatabaseService().updateEvent(
        eventId: widget.eventId,
        oldEvent: oldEvent,
        title: name,
        organizerName: organizerName,
        description: description,
        tags: tags,
        eventType: resolvedEventType,
        eventDay: _selectedDate!,
        startTime: _formatTime(_startTime!),
        endTime: _formatTime(_endTime!),
        isOnline: _isOnline,
        locationAddress: rawLocation,
        locationLat: _selectedLatLng?.latitude,
        locationLng: _selectedLatLng?.longitude,
        onlineLink: _isOnline ? onlineLink : null,
        bannerImageFile: _bannerImageFile,
        photoImageFile: _photoImageFile,
        skFile: skFile,
      );

      if (!mounted) return;
      _snack('Event berhasil diupdate', Colors.green);
      context.go(
        AppRoutes.eventDashboard.replaceFirst(':eventId', widget.eventId),
      );
    } catch (e) {
      debugPrint('Error update event: $e');
      if (!mounted) return;
      _snack('Terjadi kesalahan saat update event', Colors.red);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
