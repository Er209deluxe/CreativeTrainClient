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
  List<ShopItem> itemShop;

  RoleConfig({
    required this.name,
    this.enabled = true,
    required this.passiveIncome,
    required this.taskIncome,
    this.baseInventory = const [],
    this.itemShop = const [],
  });

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

class ShopItem {
  String name;
  int price;

  ShopItem(this.name, this.price);

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
    };
  }
}