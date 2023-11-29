import 'dart:math';

abstract class PointPathsUtil {
  List<List<List<double>>> apply(List<List<List<double>>> pointPaths);
}

abstract class SimplePointPathsUtil extends PointPathsUtil {
  @override
  List<List<List<double>>> apply(List<List<List<double>>> pointPaths) {
    List<List<List<double>>> res = [];
    for (List<List<double>> pointPath in pointPaths) {
      List<List<double>> subRes = [];
      for (List<double> point in pointPath) {
        subRes.add(applyEach(point));
      }
      res.add(subRes);
    }
    return res;
  }

  List<double> applyEach(List<double> point);
}

class ContainerPointPathsUtil extends PointPathsUtil {
  List<PointPathsUtil> pointPathsUtils;

  ContainerPointPathsUtil(this.pointPathsUtils);

  @override
  List<List<List<double>>> apply(List<List<List<double>>> pointPaths) {
    List<List<List<double>>> res = pointPaths;
    for (PointPathsUtil pointPathsUtil in pointPathsUtils) {
      res = pointPathsUtil.apply(res);
    }
    return res;
  }
}

class OffsetPointPaths extends SimplePointPathsUtil {
  List<double> offset;

  OffsetPointPaths(this.offset);

  @override
  List<double> applyEach(List<double> point) {
    return [point[0] + offset[0], point[1] + offset[1]];
  }
}

class ScalePointPaths extends SimplePointPathsUtil {
  double scale;
  List<double> bbox;

  ScalePointPaths(this.scale, this.bbox);

  @override
  List<double> applyEach(List<double> point) {
    List<double> midPoint = [
      (bbox[0] + (bbox[2] - bbox[0]) / 2),
      (bbox[1] + (bbox[3] - bbox[1]) / 2),
    ];
    return [
      (point[0] - midPoint[0]) * scale + midPoint[0],
      (point[1] - midPoint[1]) * scale + midPoint[1],
    ];
  }
}

class NormalizeToShape extends SimplePointPathsUtil {
  List<double> bbox;
  List<double> targetShape;

  NormalizeToShape(this.bbox, this.targetShape);

  @override
  List<double> applyEach(List<double> point) {
    if (checkVertical()) {
      final multiplier = targetShape[1] / (bbox[3] - bbox[1]);
      return [
        (point[0] - bbox[0]) * multiplier,
        (point[1] - bbox[1]) * multiplier,
      ];
    } else {
      final multiplier = targetShape[0] / (bbox[2] - bbox[0]);
      return [
        (point[0] - bbox[0]) * multiplier,
        (point[1] - bbox[1]) * multiplier,
      ];
    }
  }

  checkVertical() {
    return targetShape[1] / targetShape[0] <=
        (bbox[3] - bbox[1]) / (bbox[2] - bbox[0]);
  }
}

List<List<List<int>>> castPointPathsToInt(pointPaths) {
  List<List<List<int>>> res = [];
  for (List<List<double>> pointPath in pointPaths) {
    List<List<int>> subRes = [];
    for (List<double> point in pointPath) {
      subRes.add([point[0] as int, point[1] as int]);
    }
    res.add(subRes);
  }
  return res;
}

List<double> getBbox(List<List<List<double>>> pointPaths) {
  List<double> res = [1e9, 1e9, -1e9, -1e9];
  for (List<List<double>> pointPath in pointPaths) {
    for (List<double> point in pointPath) {
      res[0] = min(res[0], point[0]);
      res[1] = min(res[1], point[1]);
      res[2] = max(res[2], point[0]);
      res[3] = max(res[3], point[1]);
    }
  }
  return res;
}
