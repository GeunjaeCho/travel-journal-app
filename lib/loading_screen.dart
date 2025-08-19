import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  final bool showProgress;

  const LoadingScreen({
    Key? key,
    this.message = '로딩 중...',
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로딩 애니메이션
            if (showProgress)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 3,
              ),
            
            const SizedBox(height: 24),
            
            // 로딩 메시지
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // 부가 설명
            const Text(
              '잠시만 기다려주세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 특정 상황별 로딩 화면들
class DataLoadingScreen extends StatelessWidget {
  const DataLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(
      message: '데이터를 불러오는 중...',
      showProgress: true,
    );
  }
}

class ImageLoadingScreen extends StatelessWidget {
  const ImageLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(
      message: '이미지를 처리하는 중...',
      showProgress: true,
    );
  }
}

class SavingLoadingScreen extends StatelessWidget {
  const SavingLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(
      message: '저장하는 중...',
      showProgress: true,
    );
  }
}
