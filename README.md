# everfit-ml-spm

**Temporary.** This package wraps Google's prebuilt TensorFlow Lite and MediaPipe iOS binaries so the Everfit iOS app can consume them through Swift Package Manager. It will be retired when the app moves to official SPM releases.

| Product | Upstream | Version | Source of the binaries |
|---|---|---|---|
| `TensorFlowLite` | TensorFlowLiteSwift + TensorFlowLiteC | 2.17.0 | CocoaPods `TensorFlowLiteC` 2.17.0 (dl.google.com) |
| `MediaPipeTasksVision` | MediaPipeTasksVision + MediaPipeTasksCommon | 0.10.14 | CocoaPods `MediaPipeTasksVision` / `MediaPipeTasksCommon` 0.10.14 (dl.google.com) |

## What was changed

- **Binaries:** not modified, so they are byte-identical to the pod downloads. They are only re-zipped, because SPM cannot download `.tar.gz` archives.
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
