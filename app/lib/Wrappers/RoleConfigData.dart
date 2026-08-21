class RoleConfigData {
  List<RoleConfig> roleConfig;

  RoleConfigData(this.roleConfig);

  Map<String, dynamic> toJson() {
    return {
      "roleConfig": roleConfig.map((e) => e.toJson()).toList(),
    };
  }
}

class RoleConfig {
  String name;

  bool enabled;
  bool passiveIncome;
  int taskIncome;
  List<InventoryItem> baseInventory;
  List<ShopItemConfig> itemShop;

  RoleConfig({
    required this.name,
    this.enabled = true,
    required this.passiveIncome,
    required this.taskIncome,
    this.baseInventory = const [],
    this.itemShop = const [],
  });

  RoleConfig copyWith({
    String? name,
    bool? enabled,
    bool? passiveIncome,
    int? taskIncome,
    List<InventoryItem>? baseInventory,
    List<ShopItemConfig>? itemShop,
  }) {
    return RoleConfig(
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      passiveIncome: passiveIncome ?? this.passiveIncome,
      taskIncome: taskIncome ?? this.taskIncome,
      baseInventory: baseInventory ?? this.baseInventory,
      itemShop: itemShop ?? this.itemShop,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "enabled": enabled,
      "passiveIncome": passiveIncome,
      "taskIncome": taskIncome,
      "baseInventory": baseInventory.map((e) => e.toJson()).toList(),
      "itemShop": itemShop.map((e) => e.toJson()).toList(),
    };
  }
}

class InventoryItem {
  String name;

  InventoryItem(this.name);

  Map<String, dynamic> toJson() {
    return {
      "name": name,
    };
  }
}

class ShopItemConfig {
  String name;
  int price;
  int? cooldownInSeconds;

  ShopItemConfig(this.name, this.price, {this.cooldownInSeconds});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
      if (cooldownInSeconds != null) "cooldownInSeconds": cooldownInSeconds,
    };
  }
}