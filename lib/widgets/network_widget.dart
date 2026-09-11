import 'package:flauncher/providers/network_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetworkWidget extends StatelessWidget
{
  const NetworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<NetworkService, (NetworkType, CellularNetworkType, int, bool)>(
      selector: (_, ns) => (ns.networkType, ns.cellularNetworkType, ns.wirelessNetworkSignalLevel, ns.vpnActive),
      builder: (context, state, _) {
        final (networkType, cellularNetworkType, wirelessSignalLevel, vpnActive) = state;
        final networkService = context.read<NetworkService>();
        IconData physicalIcon = Icons.link_off;
        Color? iconColor;

        switch (networkType)
        {
          case NetworkType.Cellular:
            switch (cellularNetworkType)
            {
              case CellularNetworkType.Cdma || CellularNetworkType.Gsm || CellularNetworkType.Gprs:
                physicalIcon = Icons.g_mobiledata;

              case CellularNetworkType.Edge: physicalIcon = Icons.e_mobiledata;

              case CellularNetworkType.Hspa || CellularNetworkType.Hsdpa || CellularNetworkType.Hsupa:
                physicalIcon = Icons.h_mobiledata;

              case CellularNetworkType.Hspap: physicalIcon = Icons.h_plus_mobiledata;

              case CellularNetworkType.Umts || CellularNetworkType.TdScdma:
                physicalIcon = Icons.three_g_mobiledata; break;

              case CellularNetworkType.Lte: physicalIcon = Icons.four_g_mobiledata_outlined; break;
              case CellularNetworkType.Nr: physicalIcon = Icons.five_g;

              default: physicalIcon = Icons.question_mark; break;
            }
            break;
          case NetworkType.Wifi:
            if (wirelessSignalLevel == 0) {
              physicalIcon = Icons.signal_wifi_0_bar;
            }
            else if (wirelessSignalLevel == 1) {
              physicalIcon = Icons.network_wifi_1_bar;
            }
            else if (wirelessSignalLevel == 2) {
              physicalIcon = Icons.network_wifi_2_bar;
            }
            else if (wirelessSignalLevel == 3) {
              physicalIcon = Icons.network_wifi_3_bar;
            }
            else {
              physicalIcon = Icons.signal_wifi_4_bar;
            }
            break;
          case NetworkType.Vpn: physicalIcon = Icons.vpn_key; break;
          case NetworkType.Wired: physicalIcon = Icons.lan; break;
          case NetworkType.Unknown: 
            physicalIcon = Icons.link_off;
            iconColor = Colors.red; // Make no connection icon red
            break;
        }

        Widget physicalWidget = Icon(
          physicalIcon,
          color: iconColor,
          shadows: const [
            Shadow(
              color: Colors.black54,
              offset: Offset(0, 2),
              blurRadius: 8
            )
          ]
        );

        if (!vpnActive || physicalIcon == Icons.vpn_key) {
          return _NetworkIconButton(
            onTap: () {
              if (vpnActive || networkType == NetworkType.Vpn) {
                networkService.openVpnSettings();
              } else {
                networkService.openWifiSettings();
              }
            },
            child: physicalWidget,
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NetworkIconButton(
              onTap: () => networkService.openWifiSettings(),
              child: physicalWidget,
            ),
            const SizedBox(width: 4),
            _NetworkIconButton(
              onTap: () => networkService.openVpnSettings(),
              child: const Icon(
                Icons.vpn_key,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NetworkIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _NetworkIconButton({
    required this.onTap,
    required this.child,
  });

  @override
  State<_NetworkIconButton> createState() => _NetworkIconButtonState();
}

class _NetworkIconButtonState extends State<_NetworkIconButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap()),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => widget.onTap()),
      },
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        child: InkWell(
          onTap: widget.onTap,
          canRequestFocus: false,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _focused ? Colors.black.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              // Constant border width so focus changes never resize the widget.
              border: Border.all(
                color: _focused ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: _focused
                  ? const [BoxShadow(color: Colors.black54, blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}