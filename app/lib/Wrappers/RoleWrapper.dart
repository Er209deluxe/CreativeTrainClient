class RoleWrapper {
  final Team team;

  RoleWrapper({
    required this.team,
  });

  factory RoleWrapper.fromJson(Map<String, dynamic> json) {
    return RoleWrapper(
      team: Team.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return team.toJson();
  }
}

class Team {
  final String name;
  final String team;
  final String hex;
  final Map<String, ShopItem> itemShop;
  final List<dynamic> baseInventory;

  Team({
    required this.name,
    required this.team,
    required this.hex,
    required this.itemShop,
    required this.baseInventory,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      team: json['team'],
      hex: json['hex'],
      itemShop: (json['itemShop'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, ShopItem.fromJson(value)),
      ),
      baseInventory: json['baseInventory'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'team': team,
      'hex': hex,
      'itemShop': itemShop.map(
            (key, value) => MapEntry(key, value.toJson()),
      ),
      'baseInventory': baseInventory,
    };
  }
}

class ShopItem {
  final List<String> tags;
  final String itemUuid;
  final int price;
  final String name;

  ShopItem({
    required this.tags,
    required this.itemUuid,
    required this.price,
    required this.name,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      tags: List<String>.from(json['tags']),
      itemUuid: json['itemUuid'],
      price: json['price'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tags': tags,
      'itemUuid': itemUuid,
      'price': price,
      'name': name,
    };
  }
}