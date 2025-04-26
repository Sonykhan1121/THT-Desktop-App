import 'package:flutter/material.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

class SocialLinkPreview extends StatefulWidget {
  final String url;

  const SocialLinkPreview({Key? key, required this.url}) : super(key: key);

  @override
  _SocialLinkPreviewState createState() => _SocialLinkPreviewState();
}

class _SocialLinkPreviewState extends State<SocialLinkPreview> {
  Metadata? _metadata;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMetadata();
  }

  Future<void> fetchMetadata() async {

    try {
      final data = await MetadataFetch.extract(widget.url);
      print('metadata: ${data.toString()}');
      if (data != null) {
        setState(() {
          _metadata = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching metadata: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_metadata == null) {
      return Text('❌ Could not load preview', style: TextStyle(color: Colors.red));
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _metadata!.image != null
            ? Image.network(_metadata!.image!, width: 50, height: 50, fit: BoxFit.cover)
            : Icon(Icons.link),
        title: Text(_metadata!.title ?? 'No Title'),
        subtitle: Text(_metadata!.description ?? 'No Description'),
      ),
    );
  }
}
