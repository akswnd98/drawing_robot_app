import 'package:drawing_robot_app/connection_page.dart';
import 'package:drawing_robot_app/image_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'dart:convert';

import 'package:sn_progress_dialog/progress_dialog.dart';

class FrontPage extends StatelessWidget {
  const FrontPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logger =
        Logger(level: Level.info, printer: PrettyPrinter(methodCount: 0));
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 60),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                offset: const Offset(0, 3),
                blurRadius: 8,
                color: Colors.black.withOpacity(0.05),
              ),
            ]),
            width: 240,
            height: 80,
            child: TextButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnectionPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
              child: const Text('장치를 찾아볼까요?'),
            ),
          ),
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                offset: const Offset(0, 3),
                blurRadius: 8,
                color: Colors.black.withOpacity(0.05),
              ),
            ]),
            width: 240,
            height: 80,
            child: TextButton(
              onPressed: () {
                (context) async {
                  try {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile == null) {
                      return;
                    }
                    ProgressDialog pd = ProgressDialog(context: context);
                    pd.update(value: 0);
                    pd.show(max: 100, msg: '이미지를 변환중입니다...');
                    final file = File(pickedFile.path);
                    final request = http.MultipartRequest(
                      'POST',
                      Uri.parse('http://58.122.59.171:5000/get-paths'),
                    );
                    request.files.add(
                      await http.MultipartFile.fromPath('file', file.path),
                    );
                    final streamRes = await request.send();
                    streamRes.stream.timeout(
                      const Duration(minutes: 5),
                    );
                    final res = await http.Response.fromStream(streamRes);
                    dynamic data = jsonDecode(res.body);
                    List<dynamic> pointPaths = data['pointPaths'];
                    List<dynamic> bbox = data['bbox'];
                    pd.update(value: 100);
                    pd.close();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageEditPage(
                            pointPaths: pointPaths
                                .map(
                                  (v) => (v as List<dynamic>)
                                      .map(
                                        (v) => (v as List<dynamic>)
                                            .map(
                                              (v) => v as double,
                                            )
                                            .toList(),
                                      )
                                      .toList(),
                                )
                                .toList(),
                            bbox: bbox.map((v) => (v as double)).toList()),
                      ),
                    );
                  } catch (e) {
                    print(e);
                  }
                }(context);
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white),
              child: const Text('그려볼까요?'),
            ),
          ),
        ],
      ),
    );
  }
}
