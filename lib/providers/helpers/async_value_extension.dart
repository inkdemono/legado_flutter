import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueNullableData<T> on AsyncValue<T> {
  T? get valueOrNull => asData?.value;
}
