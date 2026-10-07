---
title: "V2ray的WebSocket+TLS+Web安装记录"
date: 2019-09-28T15:41:27+08:00
lastmod: 2023-07-30T15:41:27+08:00
draft: false
keywords: []
description: ""
tags: ["v2ray","websock"]
categories: ["技术与实践"]
author: ""
slug: tech-v2ray-websocket-tls-web-installation
---

一些vpn或代理的特征比较明显容易被识别，虽然是加密的，看不到内容，但知道是vpn，容易被block，采用websoket+tls+web，虽然也是加密的，但和正常web访问类似，不易被block。

整个过程比较简单，前提是要有一个墙外的VPS。
## 1. vps安装v2ray（服务端）

root权限下执行：

bash <(curl -L -s https://install.direct/go.sh)
## 2. 修改服务器端配置
```
{
  "inbounds": [{
    "port": xxxxx, //端口
    "Listen": "127.0.0.1",  //本机环回地址，防止外部访问
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", //uuid，客户端一致
          "level": 1,
          "alterId": 64
        }
      ]
    },
    "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/ray"
        }
      }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  },{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      }
    ]
  }
}
```
## 3. 安装caddy

wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/caddy_install.sh && chmod +x caddy_install.sh && bash caddy_install.sh install

## 4. 修改caddy配置
```
xxx.xxx.xxx //域名
{
  tls xxx@xxx.com  //修改为邮箱
  log /var/log/caddy.log
  proxy /ray localhost:xxxx {  //和v2ray的端口好对应
    websocket
    header_upstream -Origin
  }
}
```
## 5. 重启动服务端

service caddy restart
service v2ray restart

## 6. 客户端安装v2ray

见网络教程
## 7. 修改v2ray客户端配置
```
{
  "inbounds": [
    {
      "port": 1080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      },
      "settings": {
        "auth": "noauth",
        "udp": false
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "xxx.xxx.xxx", //v2ray服务器域名
            "port": 443,
            "users": [
              {
                "id": "xxxxxxxxx-xxxx-xxxx-xxxxxxxx",//和服务器uuid一致
                "alterId": 64
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "/ray"
        }
      }
    }
  ]
}
```
## 8. 上网

启动客户端v2ray，上网设置为socks，地址127.0.0.1，端口1080
