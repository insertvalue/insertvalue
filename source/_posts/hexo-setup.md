title: 用hexo搭建Git Page个人博客
date: 2018-12-17 11:04:17
updated: 2018-12-18 14:45:17
---
##### 写在前面
&emsp;&emsp;一直用有道笔记写东西，最近鼓捣了下Git Page，发现还(bu)不(yao)错(qian)，主要是GitHub这条大腿比较粗，抱起来就一个字---稳。Git Page可以结合开源静态站点生成器[Jekyll](http://jekyllrb.com/)、[hexo](https://hexo.io/zh-cn/)等。

&emsp;&emsp;Jekyll需要安装Ruby环境，虽然我的Mac自带了Ruby，但万一哪天用Windows还得装个Ruby环境，好麻烦的说。Jekyll很好，所以我选择hexo。

<!-- more -->

&emsp;&emsp;hexo安装就很简单了，戳这里👉[hexo](https://hexo.io/zh-cn/)，我把安装文档移过来了😂😂😂

> 一路装下来注册了百度统计、leancloud、algolia等账号，用来丰富博客的功能。建议找比较稳的公司提供的插件，能多用一段时间。有钱了还是买个阿里云主机，不用每次换个电脑就要装一套环境。相比传统的CSDN、简书啥的，这个用起来比较折腾。还好支持markdown，可以以后导入到其他博客系统，防止丢失。


##### 安装前提

安装 Hexo 相当简单。然而在安装前，您必须检查电脑中是否已安装下列应用程序：

- [Node.js](http://nodejs.org/)
- [git](http://git-scm.com/)

如果您的电脑中已经安装上述必备程序，那么恭喜您！接下来只需要使用 npm 即可完成 Hexo 的安装。

```
npm install hexo-cli -g
```

> **Mac 用户**
> 
> 您在编译时可能会遇到问题，请先到 App Store 安装 Xcode，Xcode 完成后，启动并进入 **Preferences -> Download -> Command Line Tools -> Install** 安装命令行工具。

##### 安装 Git
- Windows：下载并安装[git](https://git-scm.com/download/win).
- Mac：使用[Homebrew](http://mxcl.github.com/homebrew/), [MacPorts](http://www.macports.org/) ：brew install git;或下载[安装程序](http://sourceforge.net/projects/git-osx-installer/)安装。
- Linux (Ubuntu, Debian)：sudo apt-get install git-core
- Linux (Fedora, Red Hat, CentOS)：sudo yum install git-core

> Windows 用户
> 
> 由于众所周知的原因，从上面的链接下载git for windows最好挂上一个代理，否则下载速度十分缓慢。也可以参考[这个页面](https://github.com/waylau/git-for-win)，收录了存储于百度云的下载地址。

##### 安装 Node.js
安装 Node.js 的最佳方式是使用[nvm](https://github.com/creationix/nvm)。

cURL:
```
$ curl https://raw.github.com/creationix/nvm/v0.33.11/install.sh | sh
```

Wget:
```
$ wget -qO- https://raw.github.com/creationix/nvm/v0.33.11/install.sh | sh
```

安装完成后，重启终端并执行下列命令即可安装 Node.js。
```
$ nvm install stable
```

或者您也可以下载[安装程序](http://nodejs.org/)来安装。

> Windows 用户
>
> 对于windows用户来说，建议使用安装程序进行安装。安装时，请勾选**Add to PATH**选项。
另外，您也可以使用**Git Bash**，这是git for windows自带的一组程序，提供了Linux风格的shell，在该环境下，您可以直接用上面提到的命令来安装Node.js。打开它的方法很简单，在任意位置单击右键，选择“Git Bash Here”即可。由于Hexo的很多操作都涉及到命令行，您可以考虑始终使用**Git Bash**来进行操作。

##### 安装 Hexo
所有必备的应用程序安装完成后，即可使用 npm 安装 Hexo。
```
$ npm install -g hexo-cli
```