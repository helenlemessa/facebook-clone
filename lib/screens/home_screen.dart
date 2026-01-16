import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Post {
  final String id;
  final String userName;
  final String userImage;
  final String content;
  final String timeAgo;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;

  Post({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.content,
    required this.timeAgo,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Post> _posts = [
    Post(
      id: '1',
      userName: 'John Doe',
      userImage: 'https://randomuser.me/api/portraits/men/1.jpg',
      content: 'Beautiful day at the beach! 🌊☀️',
      timeAgo: '2 hours ago',
      likes: 245,
      comments: 43,
      shares: 12,
      isLiked: true,
    ),
    Post(
      id: '2',
      userName: 'Jane Smith',
      userImage: 'https://randomuser.me/api/portraits/women/2.jpg',
      content: 'Just finished my Flutter project! So excited about the results. #Flutter #Dart',
      timeAgo: '5 hours ago',
      likes: 189,
      comments: 28,
      shares: 5,
      isLiked: false,
    ),
    Post(
      id: '3',
      userName: 'Mike Johnson',
      userImage: 'https://randomuser.me/api/portraits/men/3.jpg',
      content: 'New coffee shop opened downtown! The latte art is amazing! ☕️',
      timeAgo: '1 day ago',
      likes: 312,
      comments: 67,
      shares: 23,
      isLiked: true,
    ),
    Post(
      id: '4',
      userName: 'Sarah Wilson',
      userImage: 'https://randomuser.me/api/portraits/women/4.jpg',
      content: 'Weekend hike was absolutely breathtaking! 🏔️',
      timeAgo: '2 days ago',
      likes: 456,
      comments: 89,
      shares: 34,
      isLiked: false,
    ),
  ];
  
  get Provider => null;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 4) { // Profile index
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      setState(() {
        _selectedIndex = 0; // Reset to home
      });
    }
  }

  Widget _buildPost(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.userImage),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.content),
            const SizedBox(height: 15),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: post.isLiked ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        // Handle like
                      },
                    ),
                    Text('${post.likes}'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.grey),
                      onPressed: () {
                        // Handle comment
                      },
                    ),
                    Text('${post.comments}'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.grey),
                      onPressed: () {
                        // Handle share
                      },
                    ),
                    Text('${post.shares}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Consumer<AuthProvider>(
    builder: (context, authProvider, child) {
      final user = authProvider.user;
      
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'facebook',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              letterSpacing: -1.0,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView(
          children: [
            // Create Post Section
            Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: user?.profileImage != null
                              ? NetworkImage(user!.profileImage!)
                              : const NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              backgroundColor: Colors.grey[200],
                            ),
                            child: const Text(
                              "What's on your mind?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.video_call, color: Colors.red),
                          label: const Text('Live'),
                        ),
                        const VerticalDivider(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.photo_library, color: Colors.green),
                          label: const Text('Photo'),
                        ),
                        const VerticalDivider(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.room, color: Colors.purple),
                          label: const Text('Check in'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ... rest of your home screen code
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.ondemand_video),
              label: 'Watch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    },
  );
}
}