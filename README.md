## 介绍

ACP（Automatically Compress Pictures，自动压缩图片）是一个简单的bash脚本工具，可以监听特定文件夹，并对移入文件夹内的图片进行压缩

## 依赖

- `pngquant`：压缩png图片
- `jpegoptim`：压缩jpg、jpeg图片
- `inotifywait`：监听文件更改

> 注：在RH系/Debian系下，以上依赖项可通过脚本自动安装

## 使用

安装

```bash
git clone https://github.com/JadeVane/acp.git
cd acp
chmod +x ./setup.sh
./setup.sh
```

> **注意**：压缩后的文件将覆盖源文件

卸载

```bash
./setup.sh uninstall
```
