---
title: "Wireguard的分流方法"
date: 2019-09-07T15:45:22+08:00
lastmod: 2023-07-30T15:45:22+08:00
draft: false
keywords: []
description: ""
tags: ["wireguard"]
categories: ["技术与实践"]
slug: tech-wireguard-split-tunneling

---

Wireguard开启后，由于默认采用的全局路由，所有流量都通过Wireguard隧道，造成不必要的流量浪费，有必要进行流量分流。

分流的一种方法主要利用路由方式，让特定的IP包转发到Wireguard隧道中，可参见这篇：WireGuard —— Windows 客户端国内外IP分流教程。这种方式是将国内地址段以路由方式不走隧道，但需要不时维护国内地址段，同时一些常规状态下能访问的国外IP地址也走了隧道。

用Wireguard，主要就是要科学上网，不能直接访问的毕竟是少数，因此就有了另外一种方式，见这一篇：wireguard+ss/v2ray/brook等实现域名分流。方法是先利用Wireguard建立隧道，再开启Brook等服务，然后利用Wireguard的AllowIPs功能，限定Brook通过隧道建立连接，利用SwitchOmega等代理插件的PAC列表，实现域名分流。

在Win10和Linuxmint设置了一下，效果不错。手机上因为Wireguard可以设置某些App通过Wireguard，也就不用考虑了。
