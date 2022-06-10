#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的，多了没用，增加编译错误，自己需要的才好
# 修改IP项的EOF于EOF之间请不要插入其他扩展代码，可以删除或注释里面原本的代码
# 如果你的OP是当主路由的话，网关、DNS、广播都不需要，代码前面加 # 注释掉，只保留后台地址和子网掩码就可以
# 如果你有编译ipv6的话，‘去掉LAN口使用内置的 IPv6 管理’代码前面也加 # 注释掉

# 添加istore应用商店
svn co https://github.com/linkease/istore/tree/main/luci/luci-app-store package/luci-app-store
svn co https://github.com/linkease/istore-ui/tree/main/app-store-ui package/store-ui

#添加kenzok8插件包
git clone https://github.com/waynesg/OpenWrt-Software package/x64_Software
git clone https://github.com/maddie/openwrt-tinc-1.1.git package/tinc
git clone https://github.com/kuoruan/luci-app-frpc package/luci-app-frpc
git clone https://github.com/alecthw/openwrt-n2n.git package/n2nx
mv package/n2nx/luci-app-n2n_v2 package/luci-app-n2n_v2
mv package/n2nx/n2n_v2 package/n2n_v2
rm -rf package/n2nx
git clone https://github.com/mwarning/zerotier-openwrt.git package/ze
mv package/ze/zerotier package/zerotier
rm -rf package/ze


cat >$NETIP <<-EOF
#uci set network.lan.ipaddr='10.0.0.1'                     # IPv4 地址(openwrt后台地址)
#uci set network.lan.netmask='255.255.255.0'                  # IPv4 子网掩码
#uci set network.lan.gateway='10.0.0.1'                    # IPv4 网关
#uci set network.lan.broadcast='10.0.0.255'                # IPv4 广播
#uci set network.lan.dns='10.0.0.1 10.0.0.10'          # DNS(多个DNS要用空格分开)
uci set network.lan.delegate='1'                              # 去掉LAN口使用内置的 IPv6 管理(若用IPV6请把'0'改'1')
uci set dhcp.@dnsmasq[0].filter_aaaa='0'                      # 禁止解析 IPv6 DNS记录(若用IPV6请把'1'改'0')
uci set system.@system[0].hostname='OpenWrt-NEXTRT'            # 修改主机名称为OpenWrt-123

uci set network.ipv6=interface
uci set network.ipv6.proto='dhcpv6'
uci set network.ipv6.ifname='@lan'
uci set network.ipv6.reqaddress='try'
uci set network.ipv6.reqprefix='auto'
uci set firewall.@zone[0].network='lan ipv6'
EOF


# 把bootstrap替换成argon为源码必选主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],源码内必须有该主题,要不然编译失败）
sed -i "s/bootstrap/argon/ig" feeds/luci/collections/luci/Makefile


# 编译多主题时,设置固件默认主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],和肯定编译了该主题,要不然进不了后台）
#sed -i "/exit 0/i\uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit luci" "$FIN_PATH"


# 增加个性名字 ${Author} 默认为你的github帐号,修改时候把 ${Author} 替换成你要的
sed -i "s/OpenWrt /OpenWrt by 华夏梦客 build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" "$ZZZ_PATH"


# 设置首次登录后台密码为空（进入openwrt后自行修改密码）
# sed -i '/CYXluq4wUazHjmCDBCqXF/d' "$ZZZ_PATH"


# 删除默认防火墙
sed -i '/to-ports 53/d' "$ZZZ_PATH"


# 取消路由器每天跑分任务
sed -i "/exit 0/i\sed -i '/coremark/d' /etc/crontabs/root" "$FIN_PATH"


# x86机型,默认内核5.15，修改内核为5.10（源码时时变,自行根据target/linux/x86/Makefile文件修改）
#sed -i 's/PATCHVER:=5.15/PATCHVER:=5.10/g' target/linux/x86/Makefile


# K3专用，编译K3的时候只会出K3固件（其他机型也适宜,把phicomm_k3和对应路径替换一下，名字要绝对正确才行）
#sed -i 's|^TARGET_|# TARGET_|g; s|# TARGET_DEVICES += phicomm_k3|TARGET_DEVICES += phicomm_k3|' target/linux/bcm53xx/image/Makefile


# 在线更新时，删除不想保留固件的某个文件，在EOF跟EOF之间加入删除代码，记住这里对应的是固件的文件路径，比如： rm -rf /etc/config/luci
cat >$DELETE <<-EOF
EOF


# 修改插件名字
#sed -i 's/"aMule设置"/"电驴下载"/g' `egrep "aMule设置" -rl ./`
#sed -i 's/"网络存储"/"NAS"/g' `egrep "网络存储" -rl ./`
#sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `egrep "Turbo ACC 网络加速" -rl ./`
#sed -i 's/"实时流量监测"/"流量"/g' `egrep "实时流量监测" -rl ./`
#sed -i 's/"KMS 服务器"/"KMS激活"/g' `egrep "KMS 服务器" -rl ./`
#sed -i 's/"TTYD 终端"/"命令窗"/g' `egrep "TTYD 终端" -rl ./`
#sed -i 's/"USB 打印服务器"/"打印服务"/g' `egrep "USB 打印服务器" -rl ./`
#sed -i 's/"Web 管理"/"Web管理"/g' `egrep "Web 管理" -rl ./`
#sed -i 's/"管理权"/"改密码"/g' `egrep "管理权" -rl ./`
#sed -i 's/"带宽监控"/"监控"/g' `egrep "带宽监控" -rl ./`


# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间（根据编译机型变化,自行调整需要删除的固件名称）
cat >"$CLEAR_PATH" <<-EOF
packages
config.buildinfo
feeds.buildinfo
openwrt-x86-64-generic-kernel.bin
openwrt-x86-64-generic.manifest
openwrt-x86-64-generic-squashfs-rootfs.img.gz
sha256sums
version.buildinfo
ipk.tar.gz
openwrt-x86-64-generic-ext4-combined.img.gz
openwrt-x86-64-generic-ext4-combined-efi.img.gz
openwrt-x86-64-generic-ext4-rootfs.img.gz
openwrt-x86-64-generic-rootfs.tar.gz
EOF
