// note: All classes without prefix in this code are from material.dart.
//       Also, material.dart exports many dart files, including widgets.dart,
//         so Widget classes are referred to without prefix
import 'package:flutter/material.dart';

// or from flutter_charts exports (library)
// provides: chart_data.dart, random_chart_data.dart, line_chart_options.dart
import 'package:flutter_charts/flutter_charts.dart';

import 'dart:ui' as ui;

/// Example of simple line chart usage in an application.
///
/// Library note: This file is same level as _lib_ so everything from _lib_ must
/// be imported using the "package:" scheme, e.g.
/// > import 'package:flutter_charts/flutter_charts.dart';
void main() {
  // runApp is function (not method) in PROJ/packages/flutter/lib/src/widgets/binding.dart.
  //
  // Why we do not have to import binding.dart?
  //
  // In brief, because it is imported through another file, material.dart.
  //
  // Longer reason
  //
  //      - Because Any Flutter app must have:
  //        1) main() { runApp(new MyApp()) } // entry point
  //        2) import 'package:flutter/material.dart';
  //          Note: *NOT* 'package:flutter/material/material.dart'.
  //          Note: material.dart is on path: PROJ/packages/flutter/lib/material.dart
  //          so another
  //          Note:
  //             * the lib level is skipped int the import reference
  //             * package: represent a directory where packages
  //               for this project are installed in pub update package (todo 1)
  //
  //      - And:
  //        3) The imported 'package:flutter/material.dart' contains line:
  //            export 'widgets.dart';
  //            which references, same level, path:
  //               PROJ/packages/flutter/lib/widgets.dart
  //            which contains:
  //               export 'src/widgets/binding.dart';
  //               on path: PROJ/packages/flutter/lib/src/widgets/binding.dart
  //            which contains function runApp()
  //
  //  So, eventually, the loading of binding .dart goes in MyApp goes like this:

  //    1) line_chart_layout_example.dart of MyApp has
  //        - import 'package:flutter/material.dart' (references PROJ/packages/flutter/lib/material.dart)
  //    2) material.dart has
  //        - export 'widgets.dart'; (references same dir        PROJ/packages/flutter/lib/widgets.dart)
  //    3) widgets.dart has
  //        - export 'src/widgets/binding.dart'; (references dir PROJ/packages/flutter/lib/src/widgets/binding.dart)
  //
  // achieves importing (heh via exports) the file
  //    packages/flutter/lib/src/widgets/binding.dart
  //    which has the runApp() function.
  //
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo Title',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Chart Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful,
  // meaning that it has a State object (defined below) that contains
  // fields that affect how it looks.

  // This class is the configuration for the state. It holds the
  // values (in this case the title) provided by the parent (in this
  // case the App widget) and used by the build method of the State.
  // Fields in a Widget subclass are always marked "final".

  final String title;

  /// Stateful widgets must implement the [createState()] method.
  ///
  /// The [createState()] method will typically return the
  /// new state of the widget.
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /// Members [_chartData] and [_chartOptions] must be initialized
  ///   otherwise first time this.build passes down nulls
  ///   to the [LineChart].
  /// However, the intended use also causes
  ///   "only static members can be accessed in initializers".
  ///   todo 0 resolve this ^ (current code works in practice as long as the RandomChartData size is the same)

  RandomLineChartOptions _chartOptions;
  RandomChartData _chartData;

   _MyHomePageState() {

      // todo 0 move to a common method
     var randomChartOptions = new RandomLineChartOptions();
     _chartOptions = randomChartOptions;
     _chartData = new RandomChartData(chartOptions: _chartOptions);
     _chartOptions.setDataRowsRandomColors(_chartData.dataRows.length);

   }

  void _chartStateChanger() { // MVC Controller todo -1
    setState(() {
      // This call to setState tells the Flutter framework that
      // something has changed in this State, which causes it to rerun
      // the build method below so that the display can reflect the
      // updated values. If we changed state without calling
      // setState(), then the build method would not be called again,
      // and so nothing would appear to happen.

      /// here we create new random data to illustrate working state change
      var randomChartOptions = new RandomLineChartOptions();
      _chartOptions = randomChartOptions;
      _chartData = new RandomChartData(chartOptions: _chartOptions);
      _chartOptions.setDataRowsRandomColors(_chartData.dataRows.length);

    });
  }

  @override
  Widget build(BuildContext context) {
    // The (singleton?) window object is available anywhere using ui.
    // From window, we can get  ui.window.devicePixelRatio, and also
    //   ui.Size windowLogicalSize = ui.window.physicalSize / devicePixelRatio
    // Note: Do not use ui.window for any sizing: see
    //       https://github.com/flutter/flutter/issues/11697

    // Use MediaQuery.of(context) for any sizing.
    // note: mediaQueryData can still return 0 size,
    //       but if MediaQuery.of(context) is used, Flutter will guarantee
    //       the build(context) will be called again !
    //        (once non 0 size becomes available)
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    // note: windowLogicalSize = size of the media (screen) in logical pixels
    // note: same as ui.window.physicalSize / ui.window.devicePixelRatio;
    ui.Size windowLogicalSize = mediaQueryData.size;

    // devicePixelRatio = number of device pixels for each logical pixel.
    // note: in all known hardware, size(logicalPixel) > size(devicePixel)
    // note: this is also, practically, never needed
    double logicalToDevicePixelSize = mediaQueryData.devicePixelRatio;

    // textScaleFactor = number of font pixels for each logical pixel.
    // note: with some fontSize, if text scale factor is 1.5
    //       => text is 1.5x larger than the font size.
    double fontScale = mediaQueryData.textScaleFactor;

    // Let us give the LineChart full width and half of height of window.
    final ui.Size chartLogicalSize =
        new Size(windowLogicalSize.width, windowLogicalSize.height / 2);

    print(" ### Size: ui.window.physicalSize=${ui.window.physicalSize}, "
        "windowLogicalSize = mediaQueryData.size = $windowLogicalSize,"
        "chartLogicalSize=$chartLogicalSize");

    LineChart lineChart = new LineChart(                // Controller (View and Controller essentially collapsed) - Painting knows about Painter
      // size: chartLogicalSize,
      painter: new LineChartPainter(),   // View
      // layouter was not here
      layouter: new LineChartLayouter( // part of Controller // was: SimpleChartLayouter
          chartData: _chartData,         // Model
          chartOptions: _chartOptions),  // Model
    );

    // [MyHomePage] extends [StatefulWidget].
    // [StatefulWidget] calls build(context) every time setState is called,
    // for instance as done by the _chartStateChanger method above.
    // The Flutter framework has been optimized to make rerunning
    // build methods fast, so that you can just rebuild anything that
    // needs updating rather than having to individually change
    // instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that
        // was created by the App.build method, and use it to set
        // our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and
        // positions it in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children
          // and arranges them vertically. By default, it sizes itself
          // to fit its children horizontally, and tries to be as tall
          // as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you
          // ran "flutter run", or select "Toggle Debug Paint" from the
          // Flutter tool window in IntelliJ) to see the wireframe for
          // each widget.
          //
          // Column has various properties to control how it sizes
          // itself and how it positions its children. Here we use
          // mainAxisAlignment to center the children vertically; the
          // main axis here is the vertical axis because Columns are
          // vertical (the cross axis would be horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
              color: Colors.green,
              onPressed: _chartStateChanger,
            ),
            new Text(
              'vvvvvvvv:',
            ),

            // Column -> Expanded(Row), expands row vertically |
            //   BUT also needs crossAxisAlignment:  CrossAxisAlignment.stretch,
            //   on Row -> Expanded(Chart). The cross alignmnet stretch carries
            //   the | expansion from inside row to column, sort of speak
            new Expanded(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  new Text('>>>'),
                  // LineChart is CustomPaint:
                  // A widget that provides a canvas on which to draw
                  // during the paint phase.

                  // Row -> Expanded -> Chart expands horizontally <-->
                  /* todo -1 remove
                  new Expanded(
                    child: new LineChart(                // Controller (View and Controller essentially collapsed) - Painting knows about Painter
                      // size: chartLogicalSize,
                      painter: new LineChartPainter(),   // View
                      // layouter was not here
                      layouter: new SimpleChartLayouter( // part of Controller
                          chartData: _chartData,         // Model
                          chartOptions: _chartOptions),  // Model
                    ),
                  ), // Row -> Expanded ,
                  */
                  new Expanded(
                    child: lineChart,
                  ), // Row -> Expanded ,
                  new Text('<<<'),
                ],
              ), //
            ), // Column -> Expanded

            new Text('^^^^^^:'),
            new RaisedButton(
              color: Colors.green,
              onPressed: _chartStateChanger,
            ),
          ],
        ),
      ),

      floatingActionButton: new FloatingActionButton(
        onPressed: _chartStateChanger,
        tooltip: 'Set Chart Data',
        child: new Icon(Icons.add),
      ),
    );
  }
}
