import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:drawing_robot_app/a4_painter.dart';
import 'package:drawing_robot_app/connected_device.dart';
import 'package:drawing_robot_app/painter_size.dart';
import 'package:drawing_robot_app/path_painter.dart';
import 'package:drawing_robot_app/point_paths_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ImageEditPage extends StatefulWidget {
  final List<List<List<double>>> pointPaths;
  final List<double> bbox;

  const ImageEditPage({
    required this.pointPaths,
    required this.bbox,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageEditPageState();
}

class ImageEditPageState extends State<ImageEditPage> {
  List<List<List<double>>>? originalPointPaths;
  List<double>? bbox;
  List<double> delta = [0.0, 0.0];
  List<double> deltaBefore = [0.0, 0.0];
  List<double> startPoint = [0.0, 0.0];
  List<List<List<double>>>? editedPointPaths;
  double scale = 1.0;
  double scaleBefore = 1.0;

  ImageEditPageState() : super();

  @override
  void initState() {
    originalPointPaths = widget.pointPaths;
    bbox = widget.bbox;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 210 / 297,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: A4Painter(),
                    child: Container(),
                  ),
                  GestureDetector(
                    onScaleStart: (details) {
                      startPoint = [
                        details.focalPoint.dx,
                        details.focalPoint.dy,
                      ];
                    },
                    onScaleUpdate: (details) {
                      delta = [
                        details.focalPoint.dx - startPoint[0],
                        details.focalPoint.dy - startPoint[1],
                      ];
                      scale = details.scale;

                      setState(() => {});
                    },
                    onScaleEnd: (details) {
                      deltaBefore = [
                        deltaBefore[0] + delta[0],
                        deltaBefore[1] + delta[1],
                      ];
                      delta = [0.0, 0.0];
                      scaleBefore = scaleBefore * scale;
                      scale = 1.0;
                      setState(() => {});
                    },
                    child: LayoutBuilder(
                      builder: (BuildContext context, constraints) {
                        List<List<List<double>>> normalizedPointPaths =
                            NormalizeToShape(
                          bbox!,
                          [
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ],
                        ).apply(originalPointPaths!);
                        List<double> normalizedBbox =
                            getBbox(normalizedPointPaths);
                        List<List<List<double>>> scaledPointPaths =
                            ScalePointPaths(
                          scaleBefore * scale,
                          normalizedBbox,
                        ).apply(normalizedPointPaths);
                        List<List<List<double>>> offsetedPointPaths =
                            OffsetPointPaths([
                          deltaBefore[0] + delta[0],
                          deltaBefore[1] + delta[1],
                        ]).apply(scaledPointPaths);
                        List<double> offsetedBbox = getBbox(offsetedPointPaths);
                        editedPointPaths = offsetedPointPaths;
                        return CustomPaint(
                          painter: PathPainter(
                            offsetedPointPaths,
                            offsetedBbox,
                          ),
                          willChange: true,
                          child: Container(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 100,
              child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.black12),
                onPressed: () async {
                  try {
                    ProgressDialog pd = ProgressDialog(context: context);
                    pd.update(value: 0);
                    pd.show(max: 100, msg: '이미지를 업로드중입니다....');
                    BluetoothDevice device = ConnectedDevice().getDevice();
                    List<BluetoothService> services =
                        await device.discoverServices();
                    for (BluetoothService service in services) {
                      for (BluetoothCharacteristic characteristic
                          in service.characteristics) {
                        if (characteristic.characteristicUuid ==
                                Guid.fromString(
                                  '00002a37-0000-1000-8000-00805f9b34fb',
                                ) &&
                            characteristic.properties.write &&
                            editedPointPaths != null) {
                          await characteristic.write(
                            Uint8List.fromList(utf8.encode('<start>')),
                          );
                          await characteristic.write(
                            Uint8List.fromList(
                              utf8.encode(
                                PainterSize().getSize().toString(),
                              ),
                            ),
                          );
                          String data = editedPointPaths!.toString();
                          for (var i = 0; i * 500 < data.length; i++) {
                            await characteristic.write(
                              Uint8List.fromList(
                                utf8.encode(
                                  data.substring(
                                    i * 500,
                                    min((i + 1) * 500, data.length),
                                  ),
                                ),
                              ),
                            );
                            pd.update(
                              value: ((min((i + 1) * 500, data.length) /
                                          data.length) *
                                      100)
                                  .toInt(),
                            );
                          }
                          await characteristic.write(Uint8List.fromList(
                            utf8.encode('<end>'),
                          ));
                          pd.close();
                        }
                      }
                    }
                  } catch (e) {
                    print(e.toString());
                  }
                },
                child: const Text('시작!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
