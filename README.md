# 每日饮水 · iPhone

适用于 iOS 16 及以上。深色界面和记录功能随 App 一起安装。记录、目标和个人资料保存在 App 的本机数据目录。

## 构建

- 在 macOS 的 Xcode 中打开 `DailyHydration.xcodeproj`。连接 iPhone 后可以使用自己的 Apple 账号，在目标的 Signing & Capabilities 中选择 Personal Team 并运行。
- 在 macOS 上运行 `bash build-ipa.sh` 可以生成 `artifacts/DailyHydration.ipa`。GitHub Actions 同样会运行这条命令并上传安装包。

## Windows 安装及续签

1. 按 [AltStore 的 Windows 安装指南](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows) 安装 AltServer，用数据线将 iPhone 连到电脑，再安装 AltStore Classic。
2. 将 `DailyHydration.ipa` 保存到 iPhone 的「文件」。打开 AltStore，在「My Apps」中点「＋」并选择该文件，使用自己的 Apple 账号签名安装。
3. 用免费 Apple 账号安装时，签名有效期为 7 天。到期前在 AltStore 的「My Apps」里刷新。刷新时保持 AltServer 正在电脑上运行，手机通过 USB 或同一个 Wi-Fi 连接电脑。
4. 后续续签沿用同一个 Apple 账号和同一 App。日常使用可以离线。
