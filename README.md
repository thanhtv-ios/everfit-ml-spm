# everfit-ml-spm

**Temporary.** This package wraps Google's prebuilt TensorFlow Lite and MediaPipe iOS binaries so the Everfit iOS app can consume them through Swift Package Manager. It will be retired when the app moves to official SPM releases.

| Product | Upstream | Version | Source of the binaries |
|---|---|---|---|
| `TensorFlowLite` | TensorFlowLiteSwift + TensorFlowLiteC | 2.17.0 | CocoaPods `TensorFlowLiteC` 2.17.0 (dl.google.com) |
| `MediaPipeTasksVision` | MediaPipeTasksVision + MediaPipeTasksCommon | 0.10.14 | CocoaPods `MediaPipeTasksVision` / `MediaPipeTasksCommon` 0.10.14 (dl.google.com) |

## What was changed

- **Binaries:** not modified, so they are byte-identical to the pod downloads. They are only re-zipped, because SPM cannot download `.tar.gz` archives.
- **TensorFlowLiteC:** shipped as a **static-library** xcframework (`libTensorFlowLiteC.a` plus headers and a module map), not as Google's framework. Xcode embeds SPM binary *frameworks* into the app even when they are static, and app validation then fails ("did not contain an Info.plist"); libraries are only linked.
  - Each architecture's object is wrapped in an `ar` archive. The object bytes are unchanged; the only addition is `ar`'s alignment padding.
  - The headers sit under `Headers/TensorFlowLiteC/`, because the umbrella header imports `<TensorFlowLiteC/…>`. The module map keeps Google's module name and its `dl`/`m`/`pthread` links.
  - The C library's privacy manifest (FileTimestamp `C617.1`) ships with the `TensorFlowLite` target.
- **Graph libraries:** `libMediaPipeTasksCommon_{device,simulator}_graph.a` are wrapped as `MediaPipeTasksGraph.xcframework`. Both files are renamed to `libMediaPipeTasksGraph.a`; their bytes are unchanged.
- **`Sources/TensorFlowLite`:** unchanged TensorFlowLiteSwift 2.17.0 sources and privacy manifest.

## Using MediaPipeTasksVision

MediaPipe registers its graphs from a static library that must be force-loaded. SPM does not allow linker flags in remote packages, so add them to the consuming target:

```
OTHER_LDFLAGS = $(inherited) -ObjC -force_load "$(BUILT_PRODUCTS_DIR)/libMediaPipeTasksGraph.a"
```

Stay on MediaPipe 0.10.14. Its newer graph libraries (0.10.35 and 1.0.x) export TensorFlow Lite C symbols that clash with `TensorFlowLiteC`.

## License

TensorFlow Lite and MediaPipe are © Google LLC, licensed under Apache-2.0 (see `LICENSE`).
