<p align="center">
  <a href="https://github.com/swiftly-solution/shop-core">
    <img src="https://cdn.swiftlycs2.net/swiftly-logo.png" alt="SwiftlyLogo" width="80" height="80">
  </a>

  <h3 align="center">[Swiftly] Shop Core</h3>

  <p align="center">
    A simple plugin for Swiftly that implements the core of the shop.
    <br/>
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/github/downloads/swiftly-solution/shop-core/total" alt="Downloads"> 
  <img src="https://img.shields.io/github/contributors/swiftly-solution/shop-core?color=dark-green" alt="Contributors">
  <img src="https://img.shields.io/github/issues/swiftly-solution/shop-core" alt="Issues">
  <img src="https://img.shields.io/github/license/swiftly-solution/shop-core" alt="License">
</p>

---

### Installation 👀

1. Download the newest [release](https://github.com/swiftly-solution/shop-core/releases).
2. Everything is drag & drop, so i think you can do it!
3. Setup database connection in `addons/swiftly/configs/databases.json` with the key `shop` like in the following example:

```json
{
  "shop": {
    "hostname": "...",
    "username": "...",
    "password": "...",
    "database": "...",
    "port": 3306
  }
}
```

(!) Don't forget to replace the `...` with the actual values !!

### Configuring the plugin 🧐

- After installing the plugin, you should change the default prefix from `addons/swiftly/configs/plugins/shop/core.json` (optional)
- In order to have items to buy in shop, you need to install modules. Check out [this](https://github.com/swiftly-solution/shop-modules/) list of modules.

### Shop Exports 🛠️

The following exports are available:

|     Name    |    Arguments    |                            Description                            |
|:-----------:|:---------------:|:-----------------------------------------------------------------:|
|   RegisterItems  | category_id, category_title_translation, category_items, only_one_item_equipable | Registers a new item  |
|   UnregisterItems  | category_id | Unregisters an item  |
|   GetCredits  | playerid | Get the credits of a player  |
|   GiveCredits  | playerid, credits | Give credits to a player  |
|   RemoveCredits  | playerid, credits | Remove credits from a player  |
|   GiveItem  | playerid, itemid, shouldRemoveCredits | Gives an item to a player  |
|   RemoveItem  | playerid, itemid, shouldRemoveCredits | Removes an item from a player  |
|   ToggleEquipState  | playerid, itemid, state | Toggles the equip state for a player  |
|   HasItemEquipped  | playerid, itemid | Returns the equip state of a player  |
|   GetItemsFromCategory  | playerid, category_id | Gets all items from a category  |


### Creating A Pull Request 😃

1. Fork the Project
2. Create your Feature Branch
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request

### Have ideas/Found bugs? 💡

Join [Swiftly Discord Server](https://swiftlycs2.net/discord) and send a message in the topic from `📕╎plugins-sharing` of this plugin!

---
