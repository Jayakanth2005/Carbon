import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DroneUploadPage extends StatefulWidget {
  final void Function(String)? onAction;
  const DroneUploadPage({Key? key, this.onAction}) : super(key: key);

  @override
  State<DroneUploadPage> createState() => _DroneUploadPageState();
}

class _DroneUploadPageState extends State<DroneUploadPage> {
  bool _uploading = false;
  double _progress = 0.0;
  String? _taskStatus;
  int? _taskId;
  int? _projectId;
  final Dio _dio = Dio();

  // TODO: replace with your WebODM host & credentials
  final String webodmBase = "http://YOUR_WEBODM_HOST:8000";
  final String username = "admin";
  final String password = "admin";

  Future<String> _getToken() async {
    final res = await _dio.post('$webodmBase/api/token-auth/',
      data: {'username': username, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return res.data['token'];
  }

  Future<File?> _createZipFromFiles(List<PlatformFile> files) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final zipPath = "${tempDir.path}/images_${DateTime.now().millisecondsSinceEpoch}.zip";
      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      for (final f in files) {
        if (f.path != null) {
          encoder.addFile(File(f.path!));
        } else if (f.bytes != null) {
          // write bytes to temp file then add
          final tmp = File('${tempDir.path}/${f.name}');
          await tmp.writeAsBytes(f.bytes!);
          encoder.addFile(tmp);
        }
      }
      encoder.close();
      return File(zipPath);
    } catch (e) {
      print("Zip error: $e");
      return null;
    }
  }

  Future<void> _pickAndUpload() async {
    setState(() { _uploading = true; _progress = 0; _taskStatus = "Picking files..."; });

    // Allow either multiple images or a zip
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg','png','zip'],
      withData: true,
    );

    if (result == null) {
      setState(() { _uploading = false; _taskStatus = "Cancelled"; });
      return;
    }

    List<PlatformFile> files = result.files;

    // if user picked a single zip, use it directly
    File? uploadFile;
    if (files.length == 1 && files.first.extension?.toLowerCase() == 'zip') {
      uploadFile = File(files.first.path!);
    } else {
      // create zip from the selected image files
      _taskStatus = "Zipping ${files.length} files...";
      final zip = await _createZipFromFiles(files);
      if (zip == null) {
        setState(() { _uploading = false; _taskStatus = "Failed to create zip"; });
        return;
      }
      uploadFile = zip;
    }

    try {
      final token = await _getToken();
      // 1) create project
      final prRes = await _dio.post(
        '$webodmBase/api/projects/',
        options: Options(headers: {'Authorization': 'JWT $token'}),
        data: {'name': 'Mobile upload ${DateTime.now()}'},
        // formEncode not necessary for simple fields, Dio will handle
      );
      _projectId = prRes.data['id'];

      setState(() { _taskStatus = "Uploading to project $_projectId..."; });

      // 2) Create task by uploading images. We upload the zip as a file named 'images'
      final formData = FormData.fromMap({
        // WebODM expects images[] normally, but sending a single zipped 'images' file is supported when importing.
        // To upload raw images you would add them as multiple ('images', MultipartFile.fromFile(...)).
        'images': await MultipartFile.fromFile(uploadFile.path, filename: uploadFile.path.split('/').last),
        'options': jsonEncode([]), // pass ODM options here as JSON list of {name,value}
      });

      final uploadRes = await _dio.post(
        '$webodmBase/api/projects/$_projectId/tasks/',
        data: formData,
        options: Options(
          headers: {'Authorization': 'JWT $token'},
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (count, total) {
          final p = total > 0 ? count / total : 0.0;
          setState(() { _progress = p; });
        },
      );

      _taskId = uploadRes.data['id'];
      widget.onAction?.call("Uploaded drone zip -> project=$_projectId task=$_taskId");
      setState(() { _taskStatus = "Upload complete. Task $_taskId created."; });

      // 3) Poll the task until completed
      await _pollTask(token, _projectId!, _taskId!);

    } catch (e, st) {
      print("Upload error $e\n$st");
      setState(() { _taskStatus = "Error uploading: $e"; _uploading = false; });
      return;
    } finally {
      // keep uploading flag until post-processing done
    }
  }

  Future<void> _pollTask(String token, int projectId, int taskId) async {
    setState(() { _taskStatus = "Polling task..."; });
    try {
      while (true) {
        final res = await _dio.get(
          '$webodmBase/api/projects/$projectId/tasks/$taskId/',
          options: Options(headers: {'Authorization': 'JWT $token'}),
        );
        final status = res.data['status'];
        setState(() { _taskStatus = "Status: $status"; });

        // status codes: check WebODM docs; typical string statuses include PROCESSING/COMPLETED/FAILED
        if (status == 4 || status == "COMPLETED" || status == "completed") {
          // Completed
          widget.onAction?.call("Task $taskId completed");
          setState(() { _uploading = false; _progress = 1.0; });
          // Download results
          await _downloadAndShowAssets(token, projectId, taskId);
          break;
        } else if (status == 5 || status == "FAILED" || status == "failed") {
          setState(() { _uploading = false; });
          widget.onAction?.call("Task $taskId failed");
          break;
        } else {
          await Future.delayed(const Duration(seconds: 5));
        }
      }
    } catch (e) {
      setState(() { _uploading = false; _taskStatus = "Error polling: $e"; });
    }
  }

  Future<void> _downloadAndShowAssets(String token, int projectId, int taskId) async {
    // Two options:
    // 1) Download textured_model.zip (textured 3D model) and a report (if you configured one)
    // 2) Or access raw assets via the assets endpoint and show Potree / model in WebView.
    // We'll attempt to link to textured_model.zip and a report PDF if available.
    setState(() { _taskStatus = "Downloading assets..."; });

    try {
      // Example: textured_model.zip
      final modelResp = await _dio.get(
        '$webodmBase/api/projects/$projectId/tasks/$taskId/download/textured_model.zip',
        options: Options(headers: {'Authorization': 'JWT $token'}, responseType: ResponseType.bytes),
      );

      final tmpDir = await getTemporaryDirectory();
      final modelPath = '${tmpDir.path}/textured_model_$taskId.zip';
      final modelFile = File(modelPath);
      await modelFile.writeAsBytes(modelResp.data);

      // Example: if you have a server-generated PDF report, it may be available at a known path:
      // try orthophoto or a custom 'report.pdf' (this depends on your server pipeline).
     // inside _downloadAndShowAssets
String? pdfPath;
try {
  final pdfResp = await _dio.get(
    '$webodmBase/api/projects/$projectId/tasks/$taskId/download/report.pdf',
    options: Options(
      headers: {'Authorization': 'JWT $token'},
      responseType: ResponseType.bytes,
    ),
  );
  final pdfFile = File('${tmpDir.path}/report_$taskId.pdf');
  await pdfFile.writeAsBytes(pdfResp.data);
  pdfPath = pdfFile.path;
} catch (_) {
  // report.pdf might not exist
}

if (pdfPath != null) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PDFViewerPage(path: pdfPath!)),
  );
} else {
  final potreeUrl =
      '$webodmBase/api/projects/$projectId/tasks/$taskId/assets/potree/index.html';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ThreeDViewerPage(url: potreeUrl, token: token),
    ),
  );
}


    } catch (e) {
      setState(() { _taskStatus = "Error downloading assets: $e"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Drone Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: const Text('Upload images (zip or images)'),
                subtitle: Text(_taskStatus ?? 'Tap to pick files and upload'),
                trailing: _uploading
                    ? CircularProgressIndicator(value: _progress)
                    : IconButton(icon: const Icon(Icons.folder_open), onPressed: _pickAndUpload),
              ),
            ),
            const SizedBox(height: 12),
            if (_projectId != null && _taskId != null)
              Text('Last upload: project=$_projectId task=$_taskId', style: const TextStyle(fontSize: 12)),
            const Spacer(),
            ElevatedButton(
              child: const Text('Cancel / Back'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}


class PDFViewerPage extends StatelessWidget {
  final String path;
  const PDFViewerPage({required this.path, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report PDF')),
      body: PDFView(filePath: path),
    );
  }
}

class ThreeDViewerPage extends StatefulWidget {
  final String url;
  final String token;
  const ThreeDViewerPage({required this.url, required this.token, Key? key}) : super(key: key);

  @override
  State<ThreeDViewerPage> createState() => _ThreeDViewerPageState();
}

class _ThreeDViewerPageState extends State<ThreeDViewerPage> {
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onNavigationRequest: (nav) {
        return NavigationDecision.navigate;
      }))
      // add Authorization header when requesting potree assets if needed:
      ..loadRequest(Uri.parse(widget.url), headers: {'Authorization': 'JWT ${widget.token}'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D Viewer')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
