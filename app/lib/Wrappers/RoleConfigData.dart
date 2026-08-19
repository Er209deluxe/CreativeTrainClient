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
  String team;
  String hex;
  bool enabled;
  bool passiveIncome;
  int taskIncome;
  List<InventoryItem> baseInventory;
  List<ShopItem> itemShop;

  RoleConfig({
    required this.name,
    required this.team,
    required this.hex,
    this.enabled = true,
    required this.passiveIncome,
    required this.taskIncome,
    this.baseInventory = const [],
    this.itemShop = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "team": team,
      "hex": hex,
      "enabled": enabled,
      "passiveIncome": passiveIncome,
      "taskIncome": taskIncome,
      "baseInventory": baseInventory.map((e) => e.toJson()).toList(),
      "itemShop": itemShop.map((e) => e.toJson()).toList(),
    };
  }
}

class InventoryItem {
  String type;
  String name;

  InventoryItem(this.type, this.name);

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "name": name,
    };
  }
}

class ShopItem {
  String type;
  String name;
  int price;
  int? cooldownInSeconds;

  ShopItem(this.type, this.name, this.price, {this.cooldownInSeconds});

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "name": name,
      "price": price,
      if (cooldownInSeconds != null) "cooldownInSeconds": cooldownInSeconds,
    };
  }
}