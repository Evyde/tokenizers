# 在 macOS 上构建 Windows 版本的指南

由于在 macOS 上直接交叉编译 Windows 版本存在一些技术挑战（主要是依赖库的兼容性问题），这里提供几种可行的解决方案：

## 🎯 推荐方案

### 方案 1: 使用 GitHub Actions（推荐）

这是最简单和可靠的方法：

1. **推送代码到 GitHub**：
   ```bash
   git add .
   git commit -m "Add Windows support"
   git push origin main
   ```

2. **触发 Windows 构建**：
   - 访问你的 GitHub 仓库
   - 点击 "Actions" 标签
   - 选择 "Windows Build" 工作流
   - 点击 "Run workflow"

3. **下载构建产物**：
   - 等待构建完成（通常 5-10 分钟）
   - 在 Actions 页面下载生成的 artifacts

4. **或者使用脚本自动化**：
   ```bash
   ./build-windows-remote.sh
   ```

### 方案 2: 使用 Docker（如果已安装）

如果你有 Docker，可以使用容器来构建：

```bash
# 构建 Docker 镜像
docker build -f Dockerfile.windows -t tokenizers-windows .

# 运行构建
docker run --rm -v $(pwd)/artifacts:/output tokenizers-windows
```

### 方案 3: 使用虚拟机或云服务

1. **Windows 虚拟机**：
   - 在 macOS 上运行 Windows 虚拟机（Parallels, VMware, VirtualBox）
   - 在虚拟机中安装 Rust 和 Go
   - 直接在 Windows 环境中构建

2. **云服务**：
   - 使用 AWS EC2 Windows 实例
   - 使用 Azure Windows VM
   - 使用 Google Cloud Windows VM

## 🔧 技术细节

### 为什么直接交叉编译困难？

1. **依赖库兼容性**：`onig_sys` 和 `esaxx-rs` 等 C/C++ 依赖库在交叉编译时存在兼容性问题
2. **工具链复杂性**：Windows MSVC 工具链在 macOS 上难以完整模拟
3. **系统库差异**：Windows 和 Unix 系统库的差异导致链接问题

### 已实现的 Windows 支持

尽管交叉编译有挑战，我们已经为 Windows 平台添加了完整支持：

✅ **CGO 配置**：Windows 特定的链接器标志
✅ **构建脚本**：PowerShell 和批处理脚本
✅ **文档**：详细的 Windows 安装和使用指南
✅ **CI/CD**：GitHub Actions Windows 构建流水线
✅ **测试**：Windows 特定的测试用例

## 📦 预构建二进制文件

一旦 GitHub Actions 构建完成，Windows 用户可以直接下载预构建的二进制文件：

- [Windows AMD64](https://github.com/daulet/tokenizers/releases/latest/download/libtokenizers.windows-amd64.tar.gz)
- [Windows ARM64](https://github.com/daulet/tokenizers/releases/latest/download/libtokenizers.windows-arm64.tar.gz)

## 🚀 下一步

1. **推送更改**：将所有 Windows 支持代码推送到 GitHub
2. **触发构建**：使用 GitHub Actions 构建 Windows 版本
3. **测试验证**：在 Windows 环境中测试构建的库
4. **发布版本**：创建包含 Windows 支持的新版本

## 💡 提示

- GitHub Actions 提供免费的 Windows 构建环境
- 构建的二进制文件会自动上传为 artifacts
- 可以设置自动发布到 GitHub Releases
- Windows 用户可以直接使用预构建的库，无需自己编译

这种方法虽然不是在本地直接编译，但提供了一个可靠、可重复的 Windows 构建流程。
