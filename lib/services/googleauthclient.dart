
import 'dart:async';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Use your Web‐type client ID here as serverClientId
final _googleSignIn = GoogleSignIn(
  scopes: [drive.DriveApi.driveFileScope],
  // This needs to be the *Web* OAuth Client ID, not the Android one
  serverClientId: '1056242218752-45a5q1jnakohcbkc7jspmu11otgf4cai.apps.googleusercontent.com',
);

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest req) =>
      _inner.send(req..headers.addAll(_headers));
}

Future<String> uploadToGoogleDrive(File file) async {
  try {
    // Sign-in with Google
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception("Sign-in aborted");

    // Authenticate using the account's auth headers
    final auth = await account.authHeaders;
    final client = GoogleAuthClient(auth);
    final driveApi = drive.DriveApi(client);

    // Create a new file and upload it to Google Drive
    final driveFile = drive.File()..name = path.basename(file.path);
    final media = drive.Media(file.openRead(), file.lengthSync());

    final result = await driveApi.files.create(driveFile, uploadMedia: media);

    // Print the file ID (you could also save this to your app's database)
    print('Uploaded to Drive, file ID: ${result.id}');

    // Construct the file's download URL
    final fileId = result.id;
    final fileUrl = 'https://drive.google.com/uc?id=$fileId';
    print('File URL: $fileUrl');

    return fileUrl; // Return the file URL

  } catch (e) {
    // Catch any errors that occurred during the process
    print("Upload failed: $e");
    return "Error: $e"; // Return the error message
  }
}

