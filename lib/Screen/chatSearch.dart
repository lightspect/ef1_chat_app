import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/core/widget/loading.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/messages_model.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../locator.dart';

class ChatSearchScreen extends StatefulWidget {
  final String keyword;
  final GroupModel? group;
  final List<UserModel?>? members;
  ChatSearchScreen(this.keyword, this.group, this.members);
  @override
  _ChatSearchScreenState createState() =>
      new _ChatSearchScreenState(keyword, group, members);
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  _ChatSearchScreenState(this.keyword, this.group, this.searchMembers);
  List<AlgoliaObjectSnapshot> _results = [];
  bool _searching = false;
  String keyword;
  GroupModel? group;
  List<MessagesModel> searchMessage = [];
  List<UserModel?>? searchMembers = [];
  DatabaseService? databaseService;
  String alert = "";

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    startSearch();
  }

  void startSearch() async {
    setState(() {
      _searching = true;
    });
    Algolia algolia = Algolia.init(
      applicationId: dotenv.env['ALGOLIA_ID']!,
      apiKey: dotenv.env['API_KEY'] ?? "",
    );

    AlgoliaQuery query = algolia.instance.index(group!.groupId);
    query = query.query(keyword);

    _results = (await query.getObjects()).hits;

    for (AlgoliaObjectSnapshot snap in _results) {
      if (snap.data["contentType"] == 1 && snap.data["type"] != 4) {
        MessagesModel messagesModel =
            MessagesModel.fromMap(snap.data, snap.data["objectID"]);
        searchMessage.add(messagesModel);
      }
    }
    setState(() {
      _searching = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "All Member",
            style: TextStyle(color: colorBlack),
          ),
          leading: BackButton(
            color: colorBlack,
          ),
          backgroundColor: colorMainBG,
          elevation: 0,
        ),
        body: WillPopScope(
            child: Stack(
              children: [
                buildBody(),
                buildLoading(),
              ],
            ),
            onWillPop: () {
              if (_searching) {
                return Future.value(false);
              } else {
                databaseService!.currentGroupId = "";
                return Future.value(true);
              }
            }));
  }

  Widget buildBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              searchMessage.length.toString() + " message matched",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(context, searchMessage[index]),
              itemCount: searchMessage.length,
            ),
          )
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: _searching ? const Loading() : Container(),
    );
  }

  List<TextSpan> highlightOccurrences(String source, String query) {
    if (query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: source)];
    }
    final matches = query.toLowerCase().allMatches(source.toLowerCase());

    int lastMatchEnd = 0;

    final List<TextSpan> children = [];
    for (var i = 0; i < matches.length; i++) {
      final match = matches.elementAt(i);

      if (match.start != lastMatchEnd) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.start),
        ));
      }

      children.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ));

      if (i == matches.length - 1 && match.end != source.length) {
        children.add(TextSpan(
          text: source.substring(match.end, source.length),
        ));
      }

      lastMatchEnd = match.end;
    }
    return children;
  }

  Widget buildItem(BuildContext context, MessagesModel message) {
    UserModel member = searchMembers!.firstWhere(
        (element) => element!.userId == message.sentBy,
        orElse: () => UserModel())!;
    return Column(
      children: [
        Container(
          child: InkWell(
              child: Row(
                children: <Widget>[
                  Material(
                    child: member.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                              width: 40.0,
                              height: 40.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: member.photoUrl!,
                            width: 40.0,
                            height: 40.0,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            group!.type == 1
                                ? Icons.account_circle
                                : Icons.group,
                            size: 40.0,
                            color: Colors.grey,
                          ),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  SizedBox(
                    width: 150,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            member.nickname!,
                            style: TextStyle(
                                color: colorBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          RichText(
                            text: TextSpan(
                              children: highlightOccurrences(
                                  message.messageContent, keyword),
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12, height: 2),
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 12.0),
                    ),
                  ),
                  Spacer(),
                  Text(
                    formatDateTime(message.sentAt),
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
              onTap: () {}),
        ),
        Divider(
          color: Colors.grey,
        ),
      ],
    );
  }
}
