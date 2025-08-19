import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'loading_screen.dart';

class WriteScreen extends StatefulWidget {
  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _todoController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage; // 선택된 이미지 파일
  final ImagePicker _picker = ImagePicker(); // 이미지 피커
  
  // 상태 관리
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  
  // 상수
  static const int _maxImageSizeMB = 10; // 최대 이미지 크기 (MB)
  static const int _maxTitleLength = 50; // 최대 제목 길이
  static const int _maxContentLength = 1000; // 최대 내용 길이

  final List<String> _todoList = []; // ToDo List 저장용 리스트

  // 날짜 선택 함수
  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _clearError();
      });
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

  // 이미지 크기 검증
  bool _validateImageSize(File imageFile) {
    final sizeInBytes = imageFile.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    
    if (sizeInMB > _maxImageSizeMB) {
      setState(() {
        _errorMessage = '이미지 크기는 ${_maxImageSizeMB}MB 이하여야 합니다. (현재: ${sizeInMB.toStringAsFixed(1)}MB)';
      });
      return false;
    }
    return true;
  }

  // 입력 데이터 검증
  bool _validateInputs() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = '제목을 입력해 주세요.';
      });
      return false;
    }

    if (title.length > _maxTitleLength) {
      setState(() {
        _errorMessage = '제목은 $_maxTitleLength자 이하여야 합니다.';
      });
      return false;
    }

    if (content.isEmpty) {
      setState(() {
        _errorMessage = '내용을 입력해 주세요.';
      });
      return false;
    }

    if (content.length > _maxContentLength) {
      setState(() {
        _errorMessage = '내용은 $_maxContentLength자 이하여야 합니다.';
      });
      return false;
    }

    if (_selectedImage == null) {
      setState(() {
        _errorMessage = '사진을 선택해 주세요.';
      });
      return false;
    }

    return true;
  }

  // 카메라로 사진 촬영
  Future<void> _takePhoto() async {
    try {
      setState(() {
        _isLoading = true;
        _clearError();
      });

      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // 이미지 품질 조정
        maxWidth: 1920, // 최대 너비 제한
        maxHeight: 1080, // 최대 높이 제한
      );
      
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        
        if (_validateImageSize(imageFile)) {
          setState(() {
            _selectedImage = imageFile;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '카메라 오류: $e';
      });
    }
  }

  // 갤러리에서 사진 선택
  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
        _clearError();
      });

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        
        if (_validateImageSize(imageFile)) {
          setState(() {
            _selectedImage = imageFile;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '갤러리 오류: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 로딩 중일 때 로딩 화면 표시
    if (_isLoading) {
      return const ImageLoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("추억 새기기"),
        actions: [
          IconButton(
            icon: _isSaving 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveEntry,
            tooltip: '저장',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 에러 메시지 표시
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50]!,
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]!, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]!),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red[600]!, size: 20),
                        onPressed: _clearError,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // 제목 입력
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "제목",
                  border: const OutlineInputBorder(),
                  counterText: '${_titleController.text.length}/$_maxTitleLength',
                  helperText: '추억의 제목을 입력하세요',
                ),
                maxLength: _maxTitleLength,
                onChanged: (_) => _clearError(),
              ),

              const SizedBox(height: 16),

              // 날짜 선택
              Row(
                children: [
                  const Text("날짜: "),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(dateText),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 사진 선택 섹션
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "사진 추가",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "최대 ${_maxImageSizeMB}MB까지 업로드 가능합니다",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      
                      // 선택된 이미지 표시
                      if (_selectedImage != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                                // 이미지 제거 버튼
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                          _clearError();
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // 사진 선택 버튼들
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("카메라"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: const Text("갤러리"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ToDo 입력
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        labelText: "오늘의 할 일 추가",
                        border: OutlineInputBorder(),
                        helperText: '최대 3개까지 추가 가능',
                      ),
                      onChanged: (_) => _clearError(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_todoController.text.isNotEmpty &&
                          _todoList.length < 3) {
                        setState(() {
                          _todoList.add(_todoController.text);
                          _todoController.clear();
                          _clearError();
                        });
                      } else if (_todoList.length >= 3) {
                        setState(() {
                          _errorMessage = 'ToDo는 최대 3개까지 추가할 수 있습니다.';
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ToDo 리스트 표시
              if (_todoList.isNotEmpty)
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _todoList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(_todoList[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _todoList.removeAt(index);
                              _clearError();
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // 내용 입력
              Container(
                height: 200,
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "내용",
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                    counterText: '${_contentController.text.length}/$_maxContentLength',
                    helperText: '추억에 대한 자세한 내용을 입력하세요',
                  ),
                  maxLength: _maxContentLength,
                  maxLines: null,
                  expands: true,
                  onChanged: (_) => _clearError(),
                ),
              ),

              const SizedBox(height: 20),

              // 하단 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveEntry,
                  child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Text("저장 중..."),
                        ],
                      )
                    : const Text("저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _clearError();
    });

    try {
      // 저장 시뮬레이션 (실제로는 DataService 사용)
      await Future.delayed(const Duration(seconds: 1));
      
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      final dateStr = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final newEntry = {
        "title": title,
        "date": dateStr,
        "imagePath": _selectedImage!.path,
        "content": content,
        "liked": false,
        "todos": List<String>.from(_todoList),
      };

      if (mounted) {
        Navigator.pop(context, newEntry);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '저장 중 오류가 발생했습니다: $e';
          _isSaving = false;
        });
      }
    }
  }
}
