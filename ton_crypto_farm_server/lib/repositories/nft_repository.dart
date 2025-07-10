import '../services/firebase_service.dart';
import '../models/game_state_model.dart';

class NFTRepository {
  static Future<List<ToolNFT>> getPlayerTools(String playerId) async {
    try {
      final gameStateData = await FirebaseService.getGameState(playerId);
      if (gameStateData == null) return [];

      final gameState = GameState.fromMap(gameStateData);
      return gameState.tools;
    } catch (e) {
      throw Exception('Failed to get player tools: $e');
    }
  }

  static Future<List<LandNFT>> getPlayerLands(String playerId) async {
    try {
      final gameStateData = await FirebaseService.getGameState(playerId);
      if (gameStateData == null) return [];

      final gameState = GameState.fromMap(gameStateData);
      return gameState.lands;
    } catch (e) {
      throw Exception('Failed to get player lands: $e');
    }
  }

  static Future<ToolNFT?> getToolById(String toolId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('tools')
          .doc(toolId)
          .get();

      if (doc.data == null) return null;

      return ToolNFT.fromMap(doc.data!);
    } catch (e) {
      throw Exception('Failed to get tool: $e');
    }
  }

  static Future<LandNFT?> getLandById(String landId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('lands')
          .doc(landId)
          .get();

      if (doc.data == null) return null;

      return LandNFT.fromMap(doc.data!);
    } catch (e) {
      throw Exception('Failed to get land: $e');
    }
  }

  static Future<String> createTool(ToolNFT tool) async {
    try {
      final docRef = await FirebaseService.firestore
          .collection('tools')
          .add(tool.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create tool: $e');
    }
  }

  static Future<String> createLand(LandNFT land) async {
    try {
      final docRef = await FirebaseService.firestore
          .collection('lands')
          .add(land.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create land: $e');
    }
  }

  static Future<void> updateToolDurability(String toolId, int durability) async {
    try {
      await FirebaseService.firestore
          .collection('tools')
          .doc(toolId)
          .update({'durability': durability});
    } catch (e) {
      throw Exception('Failed to update tool durability: $e');
    }
  }

  static Future<void> transferNFTOwnership(String nftId, String newOwner, String collection) async {
    try {
      await FirebaseService.firestore
          .collection(collection)
          .doc(nftId)
          .update({'owner': newOwner});
    } catch (e) {
      throw Exception('Failed to transfer NFT ownership: $e');
    }
  }
}
