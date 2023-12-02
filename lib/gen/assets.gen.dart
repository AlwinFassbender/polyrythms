/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsSoundGen {
  const $AssetsSoundGen();

  /// File path: assets/sound/key-1.wav
  String get key1 => 'assets/sound/key-1.wav';

  /// File path: assets/sound/key-10.wav
  String get key10 => 'assets/sound/key-10.wav';

  /// File path: assets/sound/key-11.wav
  String get key11 => 'assets/sound/key-11.wav';

  /// File path: assets/sound/key-12.wav
  String get key12 => 'assets/sound/key-12.wav';

  /// File path: assets/sound/key-13.wav
  String get key13 => 'assets/sound/key-13.wav';

  /// File path: assets/sound/key-14.wav
  String get key14 => 'assets/sound/key-14.wav';

  /// File path: assets/sound/key-15.wav
  String get key15 => 'assets/sound/key-15.wav';

  /// File path: assets/sound/key-16.wav
  String get key16 => 'assets/sound/key-16.wav';

  /// File path: assets/sound/key-17.wav
  String get key17 => 'assets/sound/key-17.wav';

  /// File path: assets/sound/key-18.wav
  String get key18 => 'assets/sound/key-18.wav';

  /// File path: assets/sound/key-19.wav
  String get key19 => 'assets/sound/key-19.wav';

  /// File path: assets/sound/key-2.wav
  String get key2 => 'assets/sound/key-2.wav';

  /// File path: assets/sound/key-20.wav
  String get key20 => 'assets/sound/key-20.wav';

  /// File path: assets/sound/key-3.wav
  String get key3 => 'assets/sound/key-3.wav';

  /// File path: assets/sound/key-4.wav
  String get key4 => 'assets/sound/key-4.wav';

  /// File path: assets/sound/key-5.wav
  String get key5 => 'assets/sound/key-5.wav';

  /// File path: assets/sound/key-6.wav
  String get key6 => 'assets/sound/key-6.wav';

  /// File path: assets/sound/key-7.wav
  String get key7 => 'assets/sound/key-7.wav';

  /// File path: assets/sound/key-8.wav
  String get key8 => 'assets/sound/key-8.wav';

  /// File path: assets/sound/key-9.wav
  String get key9 => 'assets/sound/key-9.wav';

  /// List of all assets
  List<String> get values => [
        key1,
        key10,
        key11,
        key12,
        key13,
        key14,
        key15,
        key16,
        key17,
        key18,
        key19,
        key2,
        key20,
        key3,
        key4,
        key5,
        key6,
        key7,
        key8,
        key9
      ];
}

class Assets {
  Assets._();

  static const $AssetsSoundGen sound = $AssetsSoundGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
