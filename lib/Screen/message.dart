import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Screen/chat.dart';
import 'package:chat_app_ef1/Screen/chatGroup.dart';
import 'package:chat_app_ef1/Screen/createMessage.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key key, this.title}) : super(key: key);

  final String title;

  static const route = '/message';

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _searchController = TextEditingController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  //final _debouncer = Debouncer(milliseconds: 500);
  DatabaseService databaseService;

  List<GroupModel> groups;

  GroupModel group;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    databaseService.refreshMessageList();
  }

  void _onRefresh() async {
    databaseService.refreshMessageList();
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void search(String search) {
    /*searchList = [];
    if (search.isNotEmpty) {
      for (int i = 0; i < contactList.length; i++) {
        if (contactList[i].alias.toLowerCase().contains(search) ||
            contactList[i].address.toLowerCase().contains(search)) {
          setState(() {
            searchList.add(contactList[i]);
          });
        }
      }
    } else {
      setState(() {
        searchList = [];
      });
    }*/
  }

  String formatDateTime(String dateTime) {
    DateTime parsed = DateTime.parse(dateTime);
    String formatted = "";
    if (DateTime.now().year == parsed.year &&
        DateTime.now().month == parsed.month &&
        DateTime.now().day == parsed.day) {
      formatted = DateFormat('h:mm a').format(parsed);
    } else if (DateTime.now().difference(parsed).inDays <= 5) {
      formatted = DateFormat('EEE').format(parsed);
    } else if (DateTime.now().year > parsed.year) {
      formatted = DateFormat('yMMMd').format(parsed);
    } else {
      formatted = DateFormat('MMMd').format(parsed);
    }
    return formatted;
  }

  void _navigateAndReturnData() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .pushNamed('/qrscan', arguments: "getAddress");
    setState(() {
      if (result.toString() != "null") {
        _searchController.text = result.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                        width: 60.0,
                        height: 60.0,
                        padding: EdgeInsets.all(10.0),
                      ),
                      imageUrl: databaseService.user.photoUrl,
                      width: 60.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Chats",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateMessagePage()));
                      })
                ],
              ),
            ),
            Container(
              child: TextFormField(
                cursorColor: colorBlue,
                style: TextStyle(
                  color: colorBlack,
                  fontSize: 14.0,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      _navigateAndReturnData();
                      search(_searchController.text);
                    },
                  ),
                  hintText: "Search",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorBlack),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorBlack),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorBlack),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                    letterSpacing: 1.2,
                  ),
                  isDense: true,
                ),
                controller: _searchController,
                onFieldSubmitted: (value) {
                  search(value);
                },
                onChanged: (value) {
                  search(value);
                },
              ),
            ),
            Flexible(
              child: StreamBuilder(
                stream: databaseService.groupStream,
                builder: (context, AsyncSnapshot<List<GroupModel>> snapshot) {
                  if (!snapshot.hasData) {
                    print("No data");
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    );
                  } else {
                    print("Has data");
                    groups = List.from(snapshot.data);
                    groups.sort((group1, group2) {
                      if (DateTime.parse(group1.recentMessageTime)
                          .isAfter(DateTime.parse(group2.recentMessageTime))) {
                        return -1;
                      } else {
                        return 1;
                      }
                    });
                    return SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      header: WaterDropHeader(),
                      footer: CustomFooter(
                        builder: (BuildContext context, LoadStatus mode) {
                          Widget body;
                          if (mode == LoadStatus.idle) {
                            body = Text("pull up load");
                          } else if (mode == LoadStatus.loading) {
                            body = Text("Loading");
                          } else if (mode == LoadStatus.failed) {
                            body = Text("Load Failed!Click retry!");
                          } else if (mode == LoadStatus.canLoading) {
                            body = Text("release to load more");
                          } else {
                            body = Text("No more Data");
                          }
                          return Container(
                            height: 55.0,
                            child: Center(child: body),
                          );
                        },
                      ),
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildItem(context, groups[index]),
                        itemCount: groups.length,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, GroupModel group) {
    if (group.recentMessageContent == '') {
      return Container();
    } else {
      return Column(
        children: [
          Container(
            child: InkWell(
                child: Row(
                  children: <Widget>[
                    Material(
                      child: group.groupPhoto.isNotEmpty
                          ? CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey),
                                ),
                                width: 60.0,
                                height: 60.0,
                                padding: EdgeInsets.all(10.0),
                              ),
                              imageUrl: group.groupPhoto,
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              group.type == 1
                                  ? Icons.account_circle
                                  : Icons.group,
                              size: 60.0,
                              color: Colors.grey,
                            ),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    SizedBox(
                      width: 200,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              group.groupName,
                              style: TextStyle(
                                  color: colorBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              group.recentMessageContent,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  height: 1.6),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 12.0),
                      ),
                    ),
                    Spacer(),
                    Text(
                      formatDateTime(group.recentMessageTime),
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                onTap: () {
                  switch (group.type) {
                    case 1:
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              settings:
                                  RouteSettings(name: "/message/chatPage"),
                              builder: (context) => ChatPage(group: group)));
                      break;
                    case 2:
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              settings: RouteSettings(
                                  name: "/message/chatGroup", arguments: Map()),
                              builder: (context) =>
                                  ChatGroupPage(group: group)));
                      break;
                  }
                }),
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      );
    }
  }
}
