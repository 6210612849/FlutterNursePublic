import 'package:flutter/material.dart';

class NotificationItem {
  final String friendName;
  final String gameName;
  final String time;

  NotificationItem({
    required this.friendName,
    required this.gameName,
    required this.time,
  });
}

class AnimatedNotificationCard extends StatefulWidget {
  final NotificationItem notification;
  final Duration delay;

  AnimatedNotificationCard({required this.notification, required this.delay});

  @override
  _AnimatedNotificationCardState createState() =>
      _AnimatedNotificationCardState();
}

class _AnimatedNotificationCardState extends State<AnimatedNotificationCard> {
  bool _isDisplayed = false;

  @override
  void initState() {
    super.initState();
    _animateIn();
  }

  void _animateIn() async {
    await Future.delayed(widget.delay);
    setState(() {
      _isDisplayed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isDisplayed ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          leading: CircleAvatar(
            // Use a custom avatar image or letter avatar for the friend
            child: Text(widget.notification.friendName[0]),
          ),
          title: Text(
              '${widget.notification.friendName} is playing ${widget.notification.gameName}'),
          subtitle: Text(widget.notification.time),
          trailing: Icon(
              Icons.play_arrow), // Use a custom icon for the game being played
          onTap: () {
            // Handle tapping on the notification (e.g., navigate to the game page)
          },
        ),
      ),
    );
  }
}
