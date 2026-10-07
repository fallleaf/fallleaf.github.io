---
title: "ZEROTIER内网穿透实践"
date: 2020-12-30T20:59:15+08:00
lastmod: 2023-07-29T20:59:15+08:00
draft: false
keywords: ["zerotier","内网"]
description: "内网和外网计算机组成一个局域网络"
tags: ["zerotier"]
categories: ["技术与实践"]
slug: tech-zerotier-nat-traversal-practice

---

内网和外网计算机组成一个局域网，相互能访问，并能访问内网资源。


### 应用环境

公司内网：一台运行linux的NAS,一台win10笔记本电脑

外网：linux的VPS

家：Win10一台电脑

个人：Android手机

### 需求

在外网，笔记本电脑、家中的电脑和手机均能访问内网NAS上的云存储，在外网能通过NAS访问内网资源。

### 方案

在各个终端上安装zerotier，设置VPS为moon，在NAS开启转发。

zerotier的设置可上网查询，记录一下NAS设置转发的命令（网卡名称据实更改）:

    设置/etc/sysctl.conf中的net.ipv4.ip_forward=1

    iptables -t nat -A POSTROUTING -o enp123s0f0(物理网卡) -j MASQUERADE

    iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    iptables -A FORWARD -i zt7u3fcxwr(zerotier虚拟网卡) -o enp123s0f0(物理网卡) -j ACCEPT

如果访问内网资源需要用内部域名，需对访问设备的虚拟卡配置dns地址
