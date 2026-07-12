import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// 증빙(인증샷) 이미지 선택 함수. null이면 사용자가 취소한 것.
/// 테스트·플랫폼별로 교체할 수 있는 주입점이다.
typedef EvidencePick = Future<Uint8List?> Function();

final evidencePickerProvider =
    Provider<EvidencePick>((ref) => _pickWithImagePicker);

Future<Uint8List?> _pickWithImagePicker() async {
  final file = await ImagePicker()
      .pickImage(source: ImageSource.gallery, maxWidth: 1600);
  return file?.readAsBytes();
}
