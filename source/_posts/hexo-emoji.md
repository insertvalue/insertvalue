title: Hexo NexT 开启 emoji
author: 冯平宇
tags:
  - hexo
categories:
  - 安装教程
date: 2018-12-18 16:54:00
---
原始链接：http://kinboyw.github.io/2018/10/29/Hexo-NexT-开启-emoji/

Hexo 开启欢乐的 emoji 之旅 💛

Hexo 默认的 markdown 渲染引擎不支持将 Github emoji 渲染到静态的 html 页面中，我们换一个支持 emoji 的引擎，再增加一个 emoji 插件即可.

<!-- more -->

##### 安装
命令行如下：
```
npm un hexo-renderer-marked --save
npm i hexo-renderer-markdown-it --save
npm install markdown-it-emoji --save
```
Tips：据说[hexo-renderer-markdown-it](https://github.com/hexojs/hexo-renderer-markdown-it)的速度要比 Hexo 原装插件要快，而且功能更多

##### 配置
完成插件安装后还需要修改 Hexo 站点配置文件 _config.yml（不是主题配置哦）

```
## markdown 渲染引擎配置，默认是hexo-renderer-marked，这个插件渲染速度更快，且有新特性
markdown:
  render:
    html: true
    xhtmlOut: false
    breaks: true
    linkify: true
    typographer: true
    quotes: '“”‘’'
  plugins:
    - markdown-it-footnote
    - markdown-it-sup
    - markdown-it-sub
    - markdown-it-abbr
    - markdown-it-emoji
  anchors:
    level: 2
    collisionSuffix: 'v'
    permalink: true
    permalinkClass: header-anchor
    permalinkSymbol: ¶
```

这里需要注意`render:`下的`html:`配置项，它的作用是控制`Markdown`渲染引擎是否转义文档中出现的`html`标签，默认为`false`，这里要设置为`true`，否则回导致`<!--more-->`渲染失败。

```
html: true # 不转义 HTML 内容，即允许 HTML
    ## OR
html: false # 转义 HTML，< > 尖括号会被转义成 &lt; &gt;等
```

`plugins:`中的最后一项`- markdown-it-emoji`是手动添加的，官方 Github Wiki 中给出的配置不包含这一项，其他配置参照的 Github Wiki 中的默认配置，hexo-renderer-markdown-it 提供的其他新特性还没有一一尝试，暂时只想用它的 emoji 功能。✌️

##### 使用方法
1. 在[Emoji](https://emoji.codes/)中找到你想要的表情，然后点击复制粘贴。
2. 常用的emoji可以记下它的编码，直接输入，例如直接输入笑脸对应的 emoji 编码 :smile: 就可以得到 😄 。