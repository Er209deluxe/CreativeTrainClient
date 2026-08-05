import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:creativetrainclient/Wrappers/RoleWrapper.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class RenderActivesession extends StatefulWidget {
  const RenderActivesession({super.key});

  @override
  State<RenderActivesession> createState() => _RenderActivesessionState();
}

class _RenderActivesessionState extends State<RenderActivesession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GradientHomeBG(),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                M3EHeader(
                  headerText: "Role: ${app_state.getRole()?.team.name}",
                ),
                const SizedBox(height: 25),
                ValueListenableBuilder<double>(
                  valueListenable: app_state.sanityNotifier,
                  builder: (context, sanity, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: app_state.depressionNotifier,
                      builder: (context, depression, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sanity',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(sanity * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: sanity,
                                  end: sanity,
                                ),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                builder: (context, animatedSanity, _) {
                                  return LinearProgressIndicator(
                                    value: animatedSanity,
                                    minHeight: 22,
                                    borderRadius: BorderRadius.circular(6),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      animatedSanity > 0.5
                                          ? Colors.greenAccent
                                          : animatedSanity > 0.25
                                          ? Colors.amber
                                          : Colors.redAccent,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Depression',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(depression * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: depression,
                                  end: depression,
                                ),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                builder: (context, animatedDepression, _) {
                                  return LinearProgressIndicator(
                                    value: animatedDepression,
                                    minHeight: 22,
                                    borderRadius: BorderRadius.circular(4),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      animatedDepression > 0.9
                                          ? Colors.greenAccent
                                          : animatedDepression > 0.4
                                          ? Colors.amber
                                          : Colors.redAccent,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 25),
                ValueListenableBuilder<int>(
                  valueListenable: app_state.coinsNotifier,
                  builder: (context, coins, _) {
                    return M3EHeader(headerText: 'Coins: $coins');
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const SizedBox(width: 25),
                    Expanded(
                      child: M3EButton(
                        onPressed: () {
                          //Leave Game
                          showLeaveConfirmDialog(context);
                        },
                        size: M3EButtonSize.custom(height: 85),
                        decoration: M3EButtonDecoration.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Leave Game',
                          style: TextStyle(fontSize: 27),
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: M3EButton(
                        onPressed: () {
                          showInventoryDialog(context);
                        },
                        size: M3EButtonSize.custom(height: 85),
                        decoration: M3EButtonDecoration.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            3,
                            59,
                            143,
                          ),
                          foregroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                        ),
                        child: Text(
                          'Inventory',
                          style: TextStyle(fontSize: 27),
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showInventoryDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 16.0,
        backgroundColor: const Color.fromARGB(255, 34, 68, 117),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Inventory',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ValueListenableBuilder<RoleWrapper?>(
                valueListenable: app_state.roleNotifier,
                builder: (context, role, _) {
                  final baseInventory = role?.team.baseInventory ?? [];
                  final inventoryItems = baseInventory
                      .where((item) => item != null)
                      .toList();

                  if (inventoryItems.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Inventory is empty',
                        style: TextStyle(fontSize: 20, color: Colors.white70),
                      ),
                    );
                  }

                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: inventoryItems.length,
                      itemBuilder: (context, index) {
                        final item = inventoryItems[index];
                        final name = item['name'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: M3EButton(
                            onPressed: () {},
                            decoration: M3EButtonDecoration.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                5,
                                88,
                                157,
                              ),
                            ),
                            child: Text(
                              '${index + 1}. $name',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text(
                      'Exit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                      showShopDialog(context, app_state.getRole());
                    },
                    child: const Text(
                      'To Shop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showShopDialog(BuildContext context, RoleWrapper? role) {
  final itemShop = role?.team.itemShop ?? {};
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 16.0,
        backgroundColor: const Color.fromARGB(255, 34, 68, 117),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Shop',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (itemShop.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Shop is empty',
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemShop.length,
                    itemBuilder: (context, index) {
                      final entry = itemShop.entries.elementAt(index);
                      final item = entry.value;
                      final name = item.name;
                      final price = item.price;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: M3EButton(
                          onPressed: () async {
                            String result;
                            try {
                              result = await buyItem(
                                app_state.getIpAddress().toString(),
                                app_state.getCurrentSession().playerUuid,
                                app_state.getCurrentSession().token,
                                item.itemUuid,
                              );
                              if (result == 'Bought Item') {
                                final inventory = await fetchInventory(
                                  app_state.getIpAddress().toString(),
                                  app_state.getCurrentSession().playerUuid,
                                  app_state.getCurrentSession().token,
                                );
                                app_state.updateInventory(inventory);
                              }
                            } catch (e) {
                              result = 'Failed to buy item: $e';
                            }
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return ErrorDialogM3E(
                                  errorHeader: 'Server Message',
                                  errorText: result,
                                );
                              },
                            );
                          },
                          decoration: M3EButtonDecoration.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              5,
                              88,
                              157,
                            ),
                          ),
                          child: Text(
                            '${index + 1}. $name - $price coins',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                      showInventoryDialog(context);
                    },
                    child: const Text(
                      'Exit Shop',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showLeaveConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 16.0,
        backgroundColor: const Color.fromARGB(255, 34, 68, 117),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Are you Sure?',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Do you really want to Leave the Game',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      //Confirm Leave
                      await leaveSession(
                        app_state.getIpAddress().toString(),
                        app_state.getCurrentSession().playerUuid,
                        app_state.getCurrentSession().token,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.red.shade700,
                      ),
                    ),
                    child: const Text(
                      'Leave Game',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
