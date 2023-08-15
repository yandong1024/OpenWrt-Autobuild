#### 提醒

- 默认密码：无
- 固件的增减基于我目前用到的设备
- 上游为 openwrt 官方，原汁原味，一些 package 取自第三方
- 内置一些 usb 无线 ac 网卡与千兆有线网卡，各设备内置的应用，可以查看 config 文件夹
- 如需添加其他包或设备，请 fork 后自行在如下文件中添加
    - scripts/
    - config/
- 如果 upnpd 在 nat 网关之后（有公网 IP），则需要（自己寻找免费的 stun 服务器）

        uci set upnpd.config.use_stun='1'
        uci set upnpd.config.stun_host='stun.qq.com'
        uci set upnpd.config.stun_port='3478'
        uci commit upnpd

#### TODO

- [ ] 考虑 opkg feeds，减少固件大小，如此可以按需安装

#### 感谢

- [![coolsnowwolf](https://img.shields.io/badge/Lede-Lean-orange.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede)
- [![Lienol](https://img.shields.io/badge/OpenWrt-Lienol-orange.svg?style=flat&logo=appveyor)](https://github.com/Lienol/openwrt)
- [![CTCGFW](https://img.shields.io/badge/OpenWrt-CTCGFW-orange.svg?style=flat&logo=appveyor)](https://github.com/immortalwrt/immortalwrt)
