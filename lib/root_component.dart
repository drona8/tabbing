import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tab/data/app_data.dart';

class RootComponent extends StatefulWidget {
  @override
  _RootComponentState createState() => _RootComponentState();
}

class _RootComponentState extends State<RootComponent> {
  final ScrollController controller = ScrollController();
  final GlobalKey widgetKey = GlobalKey();
  StreamController<bool> _streamController = StreamController<bool>();
  List<Map<String, dynamic>> _commonData = [];
  Map<String, dynamic> _tabData;

  @override
  void initState() {
    super.initState();
    for (Map<String, dynamic> commonMap in AppData.articleData) {
      if (commonMap['code'] != 'tab') {
        _commonData.add(commonMap);
      } else {
        _tabData = commonMap;
      }
    }
    controller.addListener(
      () {
        if (widgetKey.currentContext != null) {
          double height = widgetKey.currentContext.size.height;
          _streamController.add(controller.offset >= (height - 50.0));
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            collapsedHeight: 0.1,
            expandedHeight: 0.1,
            toolbarHeight: 0.0,
          )
        ];
      },
      body: ListView(
        controller: controller,
        children: <Widget>[_buildHeaderRow(context), _buildPagerRow(context)],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return AppData.getWidget(
            context, _commonData.elementAt(index), index == 0 ? 0 : 20);
      },
      itemCount: _commonData.length,
      key: widgetKey,
    );
  }

  Widget _buildPagerRow(BuildContext context) => _EventSpeakerPager(
      scrollCallback,
      _streamController.stream.asBroadcastStream(),
      _tabData['content']);
  scrollCallback(double position) =>
      controller.position.jumpTo(controller.position.pixels - position - 10.0);
}

typedef ScrollCallback = void Function(double position);

class _EventSpeakerPager extends StatefulWidget {
  _EventSpeakerPager(this.callback, this.stream, this.tabMap);

  final ScrollCallback callback;
  final Stream<bool> stream;
  final Map<String, dynamic> tabMap;

  @override
  State<StatefulWidget> createState() => _EventSpeakerPagerState();
}

class _EventSpeakerPagerState extends State<_EventSpeakerPager>
    with SingleTickerProviderStateMixin {
  bool isChildScrollEnabled = false;
  ListView tab1, tab2;
  List<Map<String, dynamic>> map1, map2;
  TabController tabController;
  ListView selectedTabList;

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    map1 = List<Map<String, dynamic>>.from(
        widget.tabMap[widget.tabMap.keys.elementAt(0)]);
    map2 = List<Map<String, dynamic>>.from(
        widget.tabMap[widget.tabMap.keys.elementAt(1)]);

    widget.stream.distinct().listen((bool data) {
      print('dsvghfvdefe ' + data.toString());
      if (mounted) {
        setState(() {
          isChildScrollEnabled = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    tab1 = ListView.builder(
      primary: false,
      physics: isChildScrollEnabled
          ? ClampingScrollPhysics()
          : NeverScrollableScrollPhysics(),
      controller: ScrollController(),
      itemBuilder: (context, index) {
        return AppData.getWidget(context, map1.elementAt(index), 20);
      },
      itemCount: map1.length,
      shrinkWrap: true,
    );
    tab2 = ListView.builder(
      primary: false,
      physics: isChildScrollEnabled
          ? ClampingScrollPhysics()
          : NeverScrollableScrollPhysics(),
      controller: ScrollController(),
      itemBuilder: (context, index) {
        return AppData.getWidget(context, map2.elementAt(index), 20);
      },
      itemCount: map2.length,
      shrinkWrap: true,
    );
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TabBar(
            unselectedLabelColor: Colors.black54,
            labelColor: Colors.black,
            indicatorColor: Colors.orange,
            controller: tabController,
            tabs: [
              new Text(
                widget.tabMap.keys.elementAt(0),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  //fontFamily: 'PoppinsMedium',
                  fontStyle: FontStyle.normal,
                ),
              ),
              new Text(
                widget.tabMap.keys.elementAt(1),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  //fontFamily: 'PoppinsMedium',
                  fontStyle: FontStyle.normal,
                ),
              )
            ],
          ),
        ),
        Listener(
          onPointerMove: (event) {
            setState(() {
              selectedTabList = tabController.index == 0 ? tab1 : tab2;
            });
            print('hhhhh ' +
                isChildScrollEnabled.toString() +
                ' ' +
                selectedTabList.physics.toString());

            if (selectedTabList.controller.hasClients) {
              double pixels = selectedTabList.controller.position.pixels;
              if (event.delta.dy > 0.0 && pixels == 0.0)
                widget.callback(event.delta.dy);
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.amber,
            child: TabBarView(
              children: [tab1, tab2],
              controller: tabController,
            ),
          ),
        )
      ],
    );
  }
}
