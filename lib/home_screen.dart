import 'package:flutter/material.dart';
import 'dart:io';
import 'write_screen.dart';
import 'detail_screen.dart';
import 'data_service.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 메모리 내 소셜피드 데이터
  List<Map<String, dynamic>> travelEntries = [];
  bool _isLoading = true; // 로딩 상태
  bool _isRefreshing = false; // 새로고침 상태
  String? _errorMessage; // 에러 메시지

  @override
  void initState() {
    super.initState();
    _loadData(); // 앱 시작 시 데이터 로드
  }

  // 데이터 로드
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final entries = await DataService.loadTravelEntries();
      setState(() {
        travelEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '데이터 로드 실패: $e';
      });
    }
  }

  // 데이터 새로고침
  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadData();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  // 데이터 저장
  Future<void> _saveData() async {
    try {
      await DataService.saveTravelEntries(travelEntries);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '데이터 저장 실패: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 저장 실패: $e')),
        );
      }
    }
  }

  // 이미지 위젯 생성 함수
  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      // assets 이미지인 경우
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          );
        },
      );
    } else {
      // 파일 경로인 경우
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          );
        },
      );
    }
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('추억을 지우시겠습니까?'),
        content: const Text('이 추억은 삭제 후 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('삭제'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      try {
        setState(() => travelEntries.removeAt(index));
        await _saveData(); // 데이터 저장
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('해당 추억이 지워졌습니다.'),
            action: SnackBarAction(
              label: '실행취소',
              onPressed: () => _undoDelete(index),
            ),
          ),
        );
      } catch (e) {
        // 삭제 실패 시 원래 상태로 복원
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  // 삭제 실행취소 (실제로는 DataService에서 복원 로직 필요)
  void _undoDelete(int index) {
    // 간단한 실행취소 구현 (실제로는 더 복잡한 로직 필요)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('실행취소는 현재 지원되지 않습니다.')),
    );
  }

  // 좋아요 토글
  Future<void> _toggleLike(int index) async {
    try {
      await DataService.toggleLike(index);
      await _loadData(); // 데이터 다시 로드
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 상태 변경 실패: $e')),
        );
      }
    }
  }

  // 에러 메시지 제거
  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("旅ログ"),
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: _isRefreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: '새로고침',
          ),
          // 개발용 데이터 초기화 버튼
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('데이터 초기화'),
                  content: const Text('모든 데이터를 초기화하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), 
                      child: const Text('초기화'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              );
              if (ok == true && mounted) {
                try {
                  await DataService.clearAllData();
                  await _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('데이터가 초기화되었습니다.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('데이터 초기화 실패: $e')),
                  );
                }
              }
            },
            tooltip: '데이터 초기화',
          ),
        ],
      ),
      body: _isLoading
          ? const DataLoadingScreen() // const 다시 추가
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildBody(),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) async {
          if (index == 1) {
            // 글쓰기 → 저장 후 피드에 추가
            final newEntry = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WriteScreen()),
            );
            if (newEntry != null && mounted) {
              try {
                await DataService.addTravelEntry(newEntry);
                await _loadData(); // 데이터 다시 로드
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('새로운 추억을 추가하였습니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('추억 추가 실패: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "추억 보관소"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "추억 새기기"),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // 에러 메시지가 있는 경우
    if (_errorMessage != null) {
      return Column(
        children: [
          // 에러 메시지 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50]!,
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600]!, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]!),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red[600]!),
                  onPressed: _clearError,
                ),
              ],
            ),
          ),
          // 재시도 버튼
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    // 데이터가 없는 경우
    if (travelEntries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 추억이 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '새로운 추억을 추가해보세요!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Icon(Icons.arrow_upward, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              '아래 + 버튼을 눌러보세요',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
      );
    }

    // 데이터가 있는 경우
    return ListView.builder(
      itemCount: travelEntries.length,
      itemBuilder: (context, index) {
        final entry = travelEntries[index];

        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 2,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    title: entry["title"] as String,
                    date: entry["date"] as String,
                    imagePath: entry["imagePath"] as String,
                    content: (entry["content"] as String?) ?? "내용 없음",
                    todos: entry["todos"] != null ? List<String>.from(entry["todos"]) : null,
                  ),
                ),
              );
              if (result == 'deleted' && mounted) {
                setState(() => travelEntries.removeAt(index));
                await _saveData(); // 데이터 저장
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제되었습니다.')));
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 + 삭제 버튼 + 좋아요 버튼
                Stack(
                  children: [
                    _buildImageWidget(entry["imagePath"] as String),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _confirmDelete(index),
                          tooltip: '삭제',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            (entry["liked"] ?? false) ? Icons.favorite : Icons.favorite_border,
                            color: (entry["liked"] ?? false) ? Colors.red : Colors.white,
                          ),
                          onPressed: () => _toggleLike(index),
                          tooltip: '좋아요',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry["title"] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry["date"] as String,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      // ToDo 리스트 표시 (있는 경우)
                      if (entry["todos"] != null && (entry["todos"] as List).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 4,
                            children: (entry["todos"] as List).take(2).map<Widget>((todo) {
                              return Chip(
                                label: Text(
                                  todo.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue[100],
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
