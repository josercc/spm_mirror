# spm_mirror

采用 https://xiaozhuanlan.com/topic/4812796035 方案的 Swift Package Manager 加速脚本

## 安装

1 安装 Mint

```bash
brew install mint
```

2 安装 Swift Package Manager Mirror

```bash
mint install josercc/spm_mirror@main --fore
```

## 使用

1 cd 到对应 SPM 工程目录

```bash
cd /Users/king/Documents/build_android
```

2 执行正常的 SPM命令

```bash
swift package update --verbose
```

3 执行转移缓存

```
mint run spm_mirror@main
# --derivedDataPath 可以自定义 DerivedData 目录，不设置默认为 $Home/Library/Developer/Xcode/DerivedData
```

## 后续更新

后面更新会支持 workspace 的工程缓存加速
