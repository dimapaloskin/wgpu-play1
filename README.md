zig, wgpu, macos window

```
wget 'https://github.com/gfx-rs/wgpu-native/releases/download/v22.1.0.5/wgpu-macos-aarch64-debug.zip' -P ./deps/wgpu
unzip deps/wgpu/wgpu-macos-aarch64-debug.zip -d ./deps/wgpu
rm deps/wgpu/wgpu-macos-aarch64-debug.zip
zig build run
```
