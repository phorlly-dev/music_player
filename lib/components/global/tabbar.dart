import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Tabbar extends StatefulWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final Widget? button, bottom;

  const Tabbar({
    super.key,
    this.title = "Sample App",
    required this.tabs,
    required this.tabViews,
    this.button,
    this.bottom,
  });

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.tabs.length, vsync: this);
    tabController.addListener(() {
      setState(() {}); // triggers rebuild to update FAB visibility
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  bool get shouldShowFAB {
    return widget.tabs.isEmpty || tabController.index == 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          title: Text(widget.title),
          leading: shouldShowFAB ? widget.button : null,
          actions: [
            IconButton(
              icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                Get.changeTheme(
                  Get.isDarkMode ? ThemeData.light() : ThemeData.dark(),
                );
              },
              tooltip: 'Toggle Theme',
            ),
          ],
          bottom: widget.tabs.isNotEmpty
              ? TabBar(controller: tabController, tabs: widget.tabs)
              : null,
        ),
        body: widget.tabs.isNotEmpty
            ? Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBarView(
                  controller: tabController,
                  children: widget.tabViews,
                ),
              )
            : const Center(child: Text('No content')),
        bottomSheet: widget.bottom,
        // floatingActionButton: shouldShowFAB ? widget.button : null,
      ),
    );
  }
}
