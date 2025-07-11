import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';

class FirebaseService {
  static late FirebaseAdminApp _app;
  static late Firestore _firestore;

  static Future<void> init() async {
    try {
      _app = FirebaseAdminApp.initializeApp(
        'ton-farm-project',
        Credential.fromApplicationDefaultCredentials(),
      );

      _firestore = Firestore(_app);
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }

  static Firestore get firestore => _firestore;

  static Future<String> createPlayer(Map<String, dynamic> playerData) async {
    try {
      final docRef = await _firestore.collection('players').add(playerData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create player: $e');
    }
  }

  static Future<Map<String, dynamic>?> getPlayer(String playerId) async {
    try {
      final doc = await _firestore.collection('players').doc(playerId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get player: $e');
    }
  }

  static Future<void> updatePlayer(
      String playerId,
      Map<String, dynamic> data,
      ) async {
    try {
      await _firestore.collection('players').doc(playerId).update(data);
    } catch (e) {
      throw Exception('Failed to update player: $e');
    }
  }

  static Future<void> saveGameState(
      String playerId,
      Map<String, dynamic> state,
      ) async {
    try {
      await _firestore
          .collection('game_states')
          .doc(playerId)
          .set(state);
    } catch (e) {
      throw Exception('Failed to save game state: $e');
    }
  }

  static Future<Map<String, dynamic>?> getGameState(String playerId) async {
    try {
      final doc = await _firestore
          .collection('game_states')
          .doc(playerId)
          .get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get game state: $e');
    }
  }

  static Future<String?> findPlayerByTelegramId(String telegramId) async {
    try {
      final query = await _firestore
          .collection('players')
          .where(WhereFilter('telegramId', '==', telegramId))
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find player: $e');
    }
  }
}
