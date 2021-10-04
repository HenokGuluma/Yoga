import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:tinder_clone/bloc/authentication/authentication_bloc.dart';
import 'package:tinder_clone/repositories/messageRepository.dart';
import 'package:tinder_clone/ui/constants.dart';
import 'package:tinder_clone/ui/pages/matches.dart';
import 'package:tinder_clone/ui/pages/messages.dart';
import 'package:tinder_clone/ui/pages/profile_screen.dart';
import 'package:tinder_clone/ui/pages/search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinder_clone/models/user.dart';


class Tabs extends StatefulWidget {

  final userId;

  const Tabs({this.userId});
  @override
  _TabsState createState() => _TabsState();
}

PageController pageController;

class _TabsState extends State<Tabs> {

  int _page = 0;
  User _currentUser = User();
  bool loading = true;
  MessageRepository _messagesRepository = MessageRepository();

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    //Animating Page
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
  Future<void >getCurrentUser() async {
    _messagesRepository.getUserDetail(userId: widget.userId).then((value) {
      setState(() {
        _currentUser = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController();
    getCurrentUser().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return homeWidget();
  }

  Widget homeWidget(){
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarOpacity: 1,
        brightness: Brightness.light,
        toolbarHeight: size.height*0.07,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset('assets/yogamates logo.png').image
                )
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              'YogaMates',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue),
            )
          ]
        ),
        actions: [
          MaterialButton(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //border: Border.all(color: Color(0xff00ffff)),
                image: DecorationImage(
                  image: ProgressiveImage(
                    placeholder: AssetImage('assets/profilephoto.png'),
                    // size: 1.87KB
                    //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                    thumbnail: AssetImage('assets/profilephoto.png'),
                    // size: 1.29MB
                    image: loading
                        ?AssetImage('assets/profilephoto.png')
                    :CachedNetworkImageProvider(_currentUser.photo),
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                  ).image,
                  fit: BoxFit.cover,
                ),
              ),
              width: 30,
              height: 30,
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                      builder: ((context) => ProfileScreen(userId: _currentUser.uid,))));
            },
          )
        ],
      ),
      body: new PageView(
        children: [
          new Container(color: Colors.white, child: Search(userId: widget.userId)),
          new Container(color: Colors.white, child: Matches(userId: widget.userId)),
          new Container(color: Colors.white, child: Messages(userId: widget.userId)),
        ],
        controller: pageController,
        physics: new NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: new CupertinoTabBar(
        border: Border(top: BorderSide(color: Colors.white, width: 0.5)),
        iconSize: size.height*0.05,
        currentIndex: _page,
        backgroundColor: Colors.white,
        activeColor: Color(0xff00ffff),
        inactiveColor: Color(0xff009999),
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: _page==0 ? SvgPicture.asset("assets/home_fill.svg", width: 20, height: 20, color: Colors.blue):SvgPicture.asset("assets/home_fill.svg", width: 20, height: 20, color: Color(0xffcaeaed)),
            title: new Text('Home', style: TextStyle(color: _page==0 ?Colors.black:Colors.grey, fontWeight: FontWeight.w400, fontSize: 12), ),
            //activeIcon: SvgPicture.asset("assets/home.svg", width: 20, height: 20, color: Color(0xff00ffff)),
          ),
          new BottomNavigationBarItem(
              icon: _page==1 ? SvgPicture.asset("assets/explore.svg", width: 20, height: 20, color: Colors.blue):SvgPicture.asset("assets/explore.svg", width: 20, height: 20, color: Color(0xffcaeaed)),
              title: new  Text('Explore', style: TextStyle(color: _page==1 ?Colors.black:Colors.grey,  fontWeight: FontWeight.w400, fontSize: 12), ),
              backgroundColor: Colors.white),
          new BottomNavigationBarItem(
              icon: _page==2 ? SvgPicture.asset("assets/email.svg", width: 25, height: 25, color: Colors.blue):SvgPicture.asset("assets/email.svg", width: 25, height: 25, color: Color(0xffcaeaed)),
              title: Text('Messages', style: TextStyle(color: _page==2 ?Colors.black:Colors.grey,  fontWeight: FontWeight.w400, fontSize: 12), ),
              backgroundColor: Colors.white),

        ],
        onTap: navigationTapped,
      ),
    );
  }
}
/*
class UserVariables extends ChangeNotifier {
  int boltTimer = 2;
  int dailyPosts = 0;
  int postTimer =2;

  void updateBoltTimer(int timer) {
    boltTimer = timer;
    notifyListeners();
  }
  void updatePostTimer(int timer) {
    postTimer = timer;
    notifyListeners();
  }
  void updateDailyPosts(int posts){
    dailyPosts = posts;
    notifyListeners();
  }
}
*/



/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tinder_clone/bloc/authentication/authentication_bloc.dart';
import 'package:tinder_clone/ui/constants.dart';
import 'package:tinder_clone/ui/pages/matches.dart';
import 'package:tinder_clone/ui/pages/messages.dart';
import 'package:tinder_clone/ui/pages/search.dart';

class Tabs extends StatelessWidget {
  final userId;

  const Tabs({this.userId});
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Search(userId: userId),
      Matches(
        userId: userId,
      ),
      Messages(userId: userId),
    ];

    return Theme(
      data: ThemeData(
        primaryColor: backgroundColour,
        accentColor: Colors.white,
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Chill',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context)
                        .add(LoggedOut());
                  })
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60.0),
              child: Container(
                height: 48.0,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TabBar(tabs: [
                      Tab(icon: Icon(Icons.search)),
                      Tab(icon: Icon(Icons.people)),
                      Tab(icon: Icon(Icons.message))
                    ])
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: pages,
          ),
        ),
      ),
    );
  }
}
*/
