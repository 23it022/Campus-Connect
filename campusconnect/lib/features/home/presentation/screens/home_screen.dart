import 'package:flutter/material.dart';
import '../../../feed/presentation/screens/feed_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../groups/presentation/screens/groups_screen.dart';
import '../../../messaging/presentation/screens/chat_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../../shared/constants/constants.dart';

/// Home Screen
/// Main navigation screen with premium bottom navigation bar
/// Shows different content based on selected tab

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const EventsScreen(),
    const GroupsScreen(),
    const ExploreScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.event_rounded,
    Icons.group_rounded,
    Icons.explore_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  final List<IconData> _outlinedIcons = [
    Icons.home_outlined,
    Icons.event_outlined,
    Icons.group_outlined,
    Icons.explore_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline_rounded,
  ];

  final List<String> _labels = [
    'Feed',
    'Events',
    'Groups',
    'Explore',
    'Messages',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(6, (index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppGradients.button : null,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? _icons[index] : _outlinedIcons[index],
                          color: isSelected ? AppColors.white : AppColors.grey,
                          size: 24,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            _labels[index],
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? Container(
              decoration: BoxDecoration(
                gradient: AppGradients.button,
                shape: BoxShape.circle,
                boxShadow: AppShadows.elevated,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-post');
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: AppColors.white),
              ),
            )
          : null,
    );
  }
}
