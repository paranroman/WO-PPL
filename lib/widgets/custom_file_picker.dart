import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class CustomFilePicker extends StatelessWidget {
  final String label;
  final String? fileName;
  final Function(PlatformFile?) onFilePicked;

  const CustomFilePicker({
    super.key,
    required this.label,
    this.fileName,
    required this.onFilePicked,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final dynamicFontSize = (size.width * 0.035).clamp(12.0, 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: dynamicFontSize,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD64F5C), width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.01,
          ),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                          allowMultiple: false,
                        );

                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.first;
                      final fileSizeInBytes = file.size;
                      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

                      if (fileSizeInMB > 2) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ukuran file melebihi batas maksimal 2 MB',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return; // Don't call onFilePicked at all
                      } else {
                        onFilePicked(file);
                      }
                    }
                  } catch (e) {
                    debugPrint('Error picking file: $e');
                    onFilePicked(null);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD64F5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.008,
                  ),
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Pilih File',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: dynamicFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.025),
              Expanded(
                child: Text(
                  fileName ?? 'Belum ada file dipilih',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: dynamicFontSize,
                    color: fileName != null
                        ? Colors.black
                        : const Color(0xFFCCCCCC),
                    fontWeight: FontWeight.w400,
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
}
