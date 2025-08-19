import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static const String _storageKey = 'travel_entries';
  
  // 데이터 저장
  static Future<void> saveTravelEntries(List<Map<String, dynamic>> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Map을 JSON으로 변환하여 저장
      final List<String> jsonList = entries.map((entry) {
        // File 객체는 경로만 저장
        final Map<String, dynamic> serializableEntry = Map<String, dynamic>.from(entry);
        return jsonEncode(serializableEntry);
      }).toList();
      
      await prefs.setStringList(_storageKey, jsonList);
      print('데이터 저장 완료: ${entries.length}개 항목');
    } catch (e) {
      print('데이터 저장 오류: $e');
      throw Exception('데이터 저장에 실패했습니다: $e');
    }
  }
  
  // 데이터 로드
  static Future<List<Map<String, dynamic>>> loadTravelEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList(_storageKey);
      
      if (jsonList == null || jsonList.isEmpty) {
        print('저장된 데이터가 없습니다.');
        return _getDefaultEntries();
      }
      
      // JSON을 Map으로 변환
      final List<Map<String, dynamic>> entries = jsonList.map((jsonString) {
        final Map<String, dynamic> entry = jsonDecode(jsonString);
        return entry;
      }).toList();
      
      print('데이터 로드 완료: ${entries.length}개 항목');
      return entries;
    } catch (e) {
      print('데이터 로드 오류: $e');
      // 오류 발생 시 기본 데이터 반환
      return _getDefaultEntries();
    }
  }
  
  // 기본 데이터 (앱 첫 실행 시)
  static List<Map<String, dynamic>> _getDefaultEntries() {
    return [
      {
        "title": "1년만에 다시 온 도쿄",
        "date": "2023-12-01",
        "imagePath": "assets/sibuya.jpeg",
        "content": "시부야 거리에서 즐거운 하루를 보냈다!",
        "liked": false,
        "todos": [],
      },
      {
        "title": "나혼자 떠나는 첫 도쿄",
        "date": "2024-10-03",
        "imagePath": "assets/skytree.jpeg",
        "content": "스카이트리 전망대에서 멋진 야경을 봤다!",
        "liked": false,
        "todos": [],
      },
    ];
  }
  
  // 단일 항목 추가
  static Future<void> addTravelEntry(Map<String, dynamic> entry) async {
    try {
      final entries = await loadTravelEntries();
      entries.insert(0, entry);
      await saveTravelEntries(entries);
      print('새 항목 추가 완료');
    } catch (e) {
      print('항목 추가 오류: $e');
      throw Exception('항목 추가에 실패했습니다: $e');
    }
  }
  
  // 단일 항목 삭제
  static Future<void> deleteTravelEntry(int index) async {
    try {
      final entries = await loadTravelEntries();
      if (index >= 0 && index < entries.length) {
        entries.removeAt(index);
        await saveTravelEntries(entries);
        print('항목 삭제 완료');
      }
    } catch (e) {
      print('항목 삭제 오류: $e');
      throw Exception('항목 삭제에 실패했습니다: $e');
    }
  }
  
  // 좋아요 상태 토글
  static Future<void> toggleLike(int index) async {
    try {
      final entries = await loadTravelEntries();
      if (index >= 0 && index < entries.length) {
        entries[index]['liked'] = !(entries[index]['liked'] ?? false);
        await saveTravelEntries(entries);
        print('좋아요 상태 변경 완료');
      }
    } catch (e) {
      print('좋아요 상태 변경 오류: $e');
      throw Exception('좋아요 상태 변경에 실패했습니다: $e');
    }
  }
  
  // 모든 데이터 삭제 (개발용)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      print('모든 데이터 삭제 완료');
    } catch (e) {
      print('데이터 삭제 오류: $e');
      throw Exception('데이터 삭제에 실패했습니다: $e');
    }
  }
}
