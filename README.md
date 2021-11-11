# spm_mirror

Swift Package Manager acceleration script using https://xiaozhuanlan.com/topic/4812796035 scheme

## Install

1 Install Mint

```bash
brew install mint
```

2 Install Swift Package Manager Mirror

```bash
mint install josercc/spm_mirror@main -f
```

## How To Use

1 cd to the corresponding SPM project directory

```bash
cd /Users/king/Documents/build_android
```

2 Execute SPM command

```bash
swift package update --verbose
```

3 Perform transfer caching

```
mint run spm_mirror@main
# --derivedDataPath can customize the DerivedData directory, if it is not set, the default is $Home/Library/Developer/Xcode/DerivedData
```

## Xcode Swift Package Manager acceleration

https://github.com/josercc/SPMTools
