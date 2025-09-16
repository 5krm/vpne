import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../ads/ads_callback.dart';
import '../../../controller/home_controller.dart';
import '../../../model/vpn_status.dart';
import '../../../service/vpn_engine.dart';
import '../../../transition/left_to_right.dart';
import '../../../transition/right_to_left.dart';
import '../../../utils/app_layout.dart';
import '../../../utils/switch_colors.dart';
import '../../../utils/my_font.dart';
import '../../../utils/my_helper.dart';
import '../../widgets/elegant_components.dart';
import '../../widgets/ultra_modern_components.dart';
import '../../widgets/switch_components.dart';
import '../../widgets/network_pattern_painter.dart';
import '../auth/login_screen.dart';
import '../account/account_screen.dart';
import '../freePlan/free_plan_screen.dart';
import '../pro/pro_screen.dart';
import '../settings/settings_screen.dart';
import '../features/speed_test_screen.dart';
import '../features/connection_stats_screen.dart';
import '../features/kill_switch_screen.dart';
import '../features/network_scanner_screen.dart';
import '../features/features_menu_screen.dart';
import '../analytics/analytics_screen_simple.dart';
import '../favorite_servers/favorite_servers_screen.dart';
import '../referral/referral_screen.dart';
import 'widget/bottom_sheet.dart';
import 'widget/count_down_timer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find<HomeController>();
    AdsCallBack adsController = Get.put(AdsCallBack());
    AppLayout.screenPortrait();

    VpnEngine.vpnStageSnapshot().listen((event) {
      homeController.vpnState.value = event;
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Gradient Background
          _buildModernBackground(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Modern Header
                _buildModernHeader(context),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Premium Badge (if connected)
                      _buildPremiumBadge(homeController),

                      const SizedBox(height: 30),

                      // Connection Status Text
                      _buildConnectionStatusText(homeController),

                      const SizedBox(height: 50),

                      // Main Connection Button with Animation
                      _buildModernConnectionButton(homeController),

                      const Spacer(),

                      // Modern Server Selection
                      _buildModernServerSelection(
                          homeController, adsController),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Background
  Widget _buildModernBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E1A),
            Color(0xFF1A1F2E),
          ],
        ),
      ),
    );
  }

  // Modern Header
  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(() => const FreePlanScreen());
                },
                borderRadius: BorderRadius.circular(8),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Action Buttons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Referral Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to referral screen
                        Get.to(() => const ReferralScreen());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Favorite Servers Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to favorite servers screen
                        Get.to(() => const FavoriteServersScreen());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Features Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.to(() => const FeaturesMenuScreen());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(
                        Icons.apps,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Analytics Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.to(() => const AnalyticsScreen());
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Settings Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        RtLScreenTransition(
                          screen: const SettingsScreen(),
                        ).navigate(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Premium Badge (Crown icon for connected state)
  Widget _buildPremiumBadge(HomeController homeController) {
    return Obx(() {
      final isConnected =
          homeController.vpnState.value == VpnEngine.vpnConnected;
      if (!isConnected) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.workspace_premium,
          color: Colors.orange,
          size: 24,
        ),
      );
    });
  }

  // Connection Status Text
  Widget _buildConnectionStatusText(HomeController homeController) {
    return Obx(() {
      final isConnected =
          homeController.vpnState.value == VpnEngine.vpnConnected;
      final isConnecting = homeController.checkConnecting;

      if (isConnecting) {
        return Column(
          children: [
            Text(
              'CONNECTING...',
              style: outfitBold.copyWith(
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PLEASE WAIT',
              style: outfitMedium.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      }

      if (isConnected) {
        return Column(
          children: [
            // Use a styled timer display
            Container(
              child: homeController.vpnConnectedStartTime != null
                  ? CountDownTimer(
                      startTimer: true,
                      startTime: homeController.vpnConnectedStartTime,
                    )
                  : Text(
                      '00:00:00',
                      style: outfitBold.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        letterSpacing: 1,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              'CONNECTED',
              style: outfitMedium.copyWith(
                color: Colors.green,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          Text(
            'TAP TO CONNECT',
            style: outfitBold.copyWith(
              color: Colors.white,
              fontSize: 28,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'DISCONNECTED',
            style: outfitMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    });
  }

  // Modern Connection Button with Animation
  Widget _buildModernConnectionButton(HomeController homeController) {
    return Obx(() {
      final isConnected =
          homeController.vpnState.value == VpnEngine.vpnConnected;
      final isConnecting = homeController.checkConnecting;

      return GestureDetector(
        onTap: () => homeController.onTryConnect(),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isConnected
                  ? [
                      const Color(0xFF4285F4).withOpacity(0.3),
                      const Color(0xFF4285F4).withOpacity(0.1),
                      Colors.transparent,
                    ]
                  : [
                      const Color(0xFF1E293B).withOpacity(0.8),
                      const Color(0xFF1E293B).withOpacity(0.4),
                      Colors.transparent,
                    ],
            ),
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected
                    ? const Color(0xFF4285F4)
                    : const Color(0xFF1E293B),
                boxShadow: isConnected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4285F4).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: isConnecting
                  ? const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                      size: 50,
                    ),
            ),
          ),
        ),
      );
    });
  }

  // Modern Server Selection
  Widget _buildModernServerSelection(
      HomeController homeController, AdsCallBack adsController) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          ServerBottomSheet(
            onSelected: (serverValue) {
              homeController.loadCount().then((value) {
                if (homeController.countAds == 0) {
                  homeController.adsService.showInterAd();
                  adsController.openAdsOnMessageEvent().then((value) {
                    if (value.contains(MyHelper.DISMISS)) {
                      homeController.savedAds().then((value) {
                        homeController.saveSelectedServer(serverValue);
                      });
                    } else {
                      homeController.saveSelectedServer(serverValue);
                    }
                  });
                } else {
                  homeController.savedAds().then((value) {
                    homeController.saveSelectedServer(serverValue);
                  });
                }
              });
            },
          ),
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Obx(() => Row(
              children: [
                // Country Flag (simplified as circle)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4285F4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🇺🇸',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Server Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            homeController.selectedServer.value?.vpnCountry ??
                                'United States',
                            style: outfitSemiBold.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4285F4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Basic',
                              style: outfitMedium.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Auto • 07ms',
                        style: outfitMedium.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.6),
                  size: 24,
                ),
              ],
            )),
      ),
    );
  }
}
