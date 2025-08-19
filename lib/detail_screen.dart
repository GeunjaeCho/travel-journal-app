import 'package:flutter/material.dart';
import 'dart:io';
import 'data_service.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String date;
  final String imagePath;
  final String content;
  final List<String>? todos;

  const DetailScreen({
    Key? key,
    required this.title,
    required this.date,
    required this.imagePath,
    required this.content,
    this.todos,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLiked = false;
  int _entryIndex = -1;

  @override
  void initState() {
    super.initState();
    _findEntryIndex();
  }

  // 현재 항목의 인덱스를 찾아서 좋아요 상태 설정
  Future<void> _findEntryIndex() async {
    try {
      final entries = await DataService.loadTravelEntries();
      final index = entries.indexWhere((entry) => 
        entry['title'] == widget.title && 
        entry['date'] == widget.date
      );
      if (index != -1) {
        setState(() {
          _entryIndex = index;
          _isLiked = entries[index]['liked'] ?? false;
        });
      }
    } catch (e) {
      print('항목 인덱스 찾기 실패: $e');
    }
  }

  // 좋아요 토글
  Future<void> _toggleLike() async {
    if (_entryIndex != -1) {
      try {
        await DataService.toggleLike(_entryIndex);
        setState(() {
          _isLiked = !_isLiked;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('좋아요 상태 변경 실패: $e')),
          );
        }
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
        height: 250,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 250,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
          );
        },
      );
    } else {
      // 파일 경로인 경우
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 250,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // 좋아요 버튼
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : null,
            ),
            onPressed: _toggleLike,
            tooltip: '좋아요',
          ),
          // 삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => Navigator.pop(context, 'deleted'), // 홈에서 처리
            tooltip: '삭제',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(widget.imagePath),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜와 좋아요 상태
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("날짜: ${widget.date}", style: const TextStyle(fontSize: 16)),
                      if (_isLiked)
                        const Chip(
                          label: Text('좋아요!'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ToDo 리스트 (있는 경우)
                  if (widget.todos != null && widget.todos!.isNotEmpty) ...[
                    const Text(
                      "할 일 목록:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.todos!.map((todo) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(child: Text(todo)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                  
                  // 내용
                  const Text(
                    "내용:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.content,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
