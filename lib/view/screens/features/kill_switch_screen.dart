import 'package:flutter/material.dart';
import '../../../service/kill_switch_service.dart';
import '../../../utils/my_color.dart';
import '../../../utils/my_font.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_card.dart';

class KillSwitchScreen extends StatefulWidget {
  const KillSwitchScreen({super.key});

  @override
  State<KillSwitchScreen> createState() => _KillSwitchScreenState();
}

class _KillSwitchScreenState extends State<KillSwitchScreen> {
  late KillSwitchStatus _status;

  @override
  void initState() {
    super.initState();
    _status = KillSwitchService.getStatus();
  }

  void _updateStatus() {
    setState(() {
      _status = KillSwitchService.getStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.bg,
      appBar: CustomAppBar(
        title: 'Kill Switch',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: MyColor.bgGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Kill Switch Status
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _status.isEnabled
                                ? MyColor.success
                                : MyColor.cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _status.isEnabled
                                ? Icons.security
                                : Icons.security_update_warning,
                            color: _status.isEnabled
                                ? MyColor.white
                                : MyColor.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kill Switch',
                                style: outfitSemiBold.copyWith(
                                  color: MyColor.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _status.statusDescription,
                                style: outfitRegular.copyWith(
                                  color: _status.isEnabled
                                      ? MyColor.success
                                      : MyColor.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _status.isEnabled,
                            onChanged: (value) {
                              KillSwitchService.setKillSwitchEnabled(value);
                              _updateStatus();
                            },
                            activeColor: MyColor.success,
                            activeTrackColor: MyColor.success.withOpacity(0.3),
                            inactiveThumbColor: MyColor.textSecondary,
                            inactiveTrackColor: MyColor.cardBg,
                          ),
                        ),
                      ],
                    ),
                    if (_status.isEnabled) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MyColor.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: MyColor.success.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield,
                              color: MyColor.success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _status.protectionLevel,
                                    style: outfitSemiBold.copyWith(
                                      color: MyColor.success,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Your connection is protected',
                                    style: outfitRegular.copyWith(
                                      color: MyColor.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Settings
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kill Switch Settings',
                      style: outfitSemiBold.copyWith(
                        color: MyColor.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Auto Connect
                    _buildSettingItem(
                      'Auto Reconnect',
                      'Automatically reconnect when VPN drops',
                      Icons.autorenew,
                      _status.autoConnectEnabled,
                      _status.isEnabled,
                      (value) {
                        KillSwitchService.setAutoConnectEnabled(value);
                        _updateStatus();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Block on Disconnect
                    _buildSettingItem(
                      'Block Internet',
                      'Block all internet when VPN disconnects',
                      Icons.block,
                      _status.blockOnDisconnectEnabled,
                      _status.isEnabled,
                      (value) {
                        KillSwitchService.setBlockOnDisconnectEnabled(value);
                        _updateStatus();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Information
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: MyColor.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How Kill Switch Works',
                          style: outfitSemiBold.copyWith(
                            color: MyColor.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoItem(
                      'Monitors your VPN connection continuously',
                    ),
                    _buildInfoItem(
                      'Blocks internet access if VPN disconnects unexpectedly',
                    ),
                    _buildInfoItem(
                      'Automatically attempts to reconnect (if enabled)',
                    ),
                    _buildInfoItem(
                      'Protects your real IP address from leaking',
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MyColor.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: MyColor.warning.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: MyColor.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kill switch may temporarily block internet access to protect your privacy.',
                              style: outfitRegular.copyWith(
                                color: MyColor.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String description,
    IconData icon,
    bool value,
    bool enabled,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColor.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  enabled ? MyColor.primary.withOpacity(0.2) : MyColor.cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: enabled ? MyColor.primary : MyColor.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: outfitMedium.copyWith(
                    color:
                        enabled ? MyColor.textPrimary : MyColor.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: outfitRegular.copyWith(
                    color: MyColor.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: MyColor.primary,
              activeTrackColor: MyColor.primary.withOpacity(0.3),
              inactiveThumbColor: MyColor.textSecondary,
              inactiveTrackColor: MyColor.cardBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: MyColor.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: outfitRegular.copyWith(
                color: MyColor.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
