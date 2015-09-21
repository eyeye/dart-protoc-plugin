// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library protoc.benchmark.has_strings;

import '../benchmark.dart';
import '../generated/benchmark.pb.dart'
    show BenchmarkID, Request, Params, Sample;
import '../generated/string_grid.pb.dart' as pb;

/// A benchmark that checks the existence of each item in a grid of strings.
class HasStringsBenchmark extends Benchmark {
  static const width = 10;
  final int height;
  final String fillValue;
  pb.Grid10 grid;

  HasStringsBenchmark(this.height, this.fillValue) : super($id);

  @override
  get summary {
    var fill = fillValue == null ? "null" : "'$fillValue'";
    return "${id.name}($height x $fill)";
  }

  @override
  Params makeParams() {
    var p = new Params()..messageCount = height;
    if (fillValue != null) p.stringValue = fillValue;
    return p;
  }

  @override
  void setup() {
    grid = _makeGrid(width, height, fillValue);
  }

  // makes a rectangle where no fields have been set.
  static pb.Grid10 _makeGrid(int width, int height, String fillValue) {
    var grid = new pb.Grid10();

    for (int y = 0; y < height; y++) {
      var line = new pb.Line10();
      if (fillValue != null) {
        for (int x = 0; x < width; x++) {
          int tag = getTagForColumn(line, x);
          line.setField(tag, fillValue);
        }
      }
      grid.lines.add(line);
    }

    return grid;
  }

  static int getTagForColumn(pb.Line10 line, int x) {
    return line.getTagNumber('cell${x+1}'); // assume x start from 1
  }

  @override
  void run() {
    if (fillValue == null) {
      runEmpty();
    } else {
      runFilled();
    }
  }

  void runFilled() {
    var allPresent = true;
    for (var y = 0; y < height; y++) {
      var line = grid.lines[y];
      allPresent = allPresent && line.hasCell1();
      allPresent = allPresent && line.hasCell2();
      allPresent = allPresent && line.hasCell3();
      allPresent = allPresent && line.hasCell4();
      allPresent = allPresent && line.hasCell5();
      allPresent = allPresent && line.hasCell6();
      allPresent = allPresent && line.hasCell7();
      allPresent = allPresent && line.hasCell8();
      allPresent = allPresent && line.hasCell9();
      allPresent = allPresent && line.hasCell10();
    }
    if (!allPresent) throw "failed";
  }

  void runEmpty() {
    var allEmpty = true;
    for (var y = 0; y < height; y++) {
      var line = grid.lines[y];
      allEmpty = allEmpty && !line.hasCell1();
      allEmpty = allEmpty && !line.hasCell2();
      allEmpty = allEmpty && !line.hasCell3();
      allEmpty = allEmpty && !line.hasCell4();
      allEmpty = allEmpty && !line.hasCell5();
      allEmpty = allEmpty && !line.hasCell6();
      allEmpty = allEmpty && !line.hasCell7();
      allEmpty = allEmpty && !line.hasCell8();
      allEmpty = allEmpty && !line.hasCell9();
      allEmpty = allEmpty && !line.hasCell10();
    }
    if (!allEmpty) throw "failed";
  }

  @override
  void setCounts(Sample s) {
    s.counts.stringReads = width * height * s.loopCount;
  }

  @override
  measureSample(Sample s) => stringReadsPerMillisecond(s);

  @override
  get measureSampleUnits => "string reads/ms";

  static const $id = BenchmarkID.HAS_STRINGS;
  static final $type = new BenchmarkType($id, $create);

  static $create(Request r) {
    assert(r.params.hasMessageCount());
    var value = null;
    if (r.params.hasStringValue()) value = r.params.stringValue;
    return new HasStringsBenchmark(r.params.messageCount, value);
  }
}