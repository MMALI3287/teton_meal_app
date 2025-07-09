import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/data/models/menu_item_model.dart';

class MenuItemService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'menu_items';

  /// Initialize default menu items if the collection is empty
  static Future<void> initializeDefaultItems() async {
    try {
      // Check if menu_items collection has any documents
      final snapshot = await _firestore.collection(_collection).limit(1).get();

      if (snapshot.docs.isEmpty) {
        // Collection is empty, add default items
        final defaultItems = [
          MenuItem(
            id: '',
            name: 'Beef Khichuri',
            subItem: null,
            createdAt: DateTime.now(),
          ),
          MenuItem(
            id: '',
            name: 'Fried Rice',
            subItem: 'With vegetables',
            createdAt: DateTime.now(),
          ),
          MenuItem(
            id: '',
            name: 'Fried Egg with Rice',
            subItem: null,
            createdAt: DateTime.now(),
          ),
          MenuItem(
            id: '',
            name: 'Chicken Curry',
            subItem: 'With basmati rice',
            createdAt: DateTime.now(),
          ),
          MenuItem(
            id: '',
            name: 'Fish Curry',
            subItem: 'With steamed rice',
            createdAt: DateTime.now(),
          ),
        ];

        // Add each default item to Firestore
        for (final item in defaultItems) {
          await _firestore.collection(_collection).add(item.toMap());
        }

        print('Default menu items initialized successfully');
      }
    } catch (e) {
      print('Error initializing default menu items: $e');
    }
  }

  /// Get all menu items
  static Future<List<MenuItem>> getAllMenuItems() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting menu items: $e');
      return [];
    }
  }

  /// Add a new menu item
  static Future<MenuItem?> addMenuItem(String name, String? subItem) async {
    try {
      final newItem = MenuItem(
        id: '',
        name: name,
        subItem: subItem,
        createdAt: DateTime.now(),
      );

      final docRef =
          await _firestore.collection(_collection).add(newItem.toMap());

      return MenuItem(
        id: docRef.id,
        name: newItem.name,
        subItem: newItem.subItem,
        createdAt: newItem.createdAt,
      );
    } catch (e) {
      print('Error adding menu item: $e');
      return null;
    }
  }

  /// Delete a menu item
  static Future<bool> deleteMenuItem(String itemId) async {
    try {
      await _firestore.collection(_collection).doc(itemId).delete();
      return true;
    } catch (e) {
      print('Error deleting menu item: $e');
      return false;
    }
  }
}
