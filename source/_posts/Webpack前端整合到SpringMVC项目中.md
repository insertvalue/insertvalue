---
title: Webpack前端整合到SpringMVC项目中
date: 2018-12-26 10:45:03
tags:
  - NodeJS
  - SpringMVC
  - Webpack
categories:
  - 技术
---

# Webpack前端整合到SpringMVC项目中

## 背景

> 容器引擎系统不支持直接部署Nodejs环境，需要结合maven插件在jenkins构建阶段编译Webpack项目。这里我把前端代码整合到SpringMVC项目中，作为一个整体工程进行打包部署。
>
> SpringMVC是已有项目，需要保留旧版本。这次重构前端，并在后端添加单独API模块。

## 目录结构

```markdown
|-- src
    |-- frontend （Webpack项目）
    |-- java
    |-- resources
    |-- webapp
|-- pom.xml
```

> 如上所示，`frontend`是Webpack项目，可以单独在Webstorm进行开发运行。如果要在SpringMVC工程中编译Webpack并部署到Tomcat，需要对pom.xml作少许改动，添加相应的maven插件。

<!-- more -->

## 编译方式

主要用到`maven-war-plugin`、`frontend-maven-plugin`两个插件。

###  frontend-maven-plugin插件

> 下载nodejs到指定目录，执行Webpack编译命令。

### maven-war-plugin插件

> 将Webpack编译后的文件放到target指定目录。

```xml
<plugin>
    <groupId>com.github.eirslett</groupId>
    <artifactId>frontend-maven-plugin</artifactId>
    <version>1.6</version>
    <executions>
        <execution>
            <id>install node and npm</id>
            <goals>
                <goal>install-node-and-npm</goal>
            </goals>
        </execution>
        <execution>
            <id>npm install</id>
            <goals>
                <goal>npm</goal>
            </goals>
            <configuration>
                <arguments>install</arguments>
            </configuration>
        </execution>
        <execution>
            <id>npm run build</id>
            <goals>
                <goal>npm</goal>
            </goals>
            <configuration>
                <arguments>run build</arguments>
            </configuration>
        </execution>
    </executions>
    <configuration>
        <!--node版本-->
        <nodeVersion>v10.14.2</nodeVersion>
        <!--node安装路径-->
        <installDirectory>target</installDirectory>
        <!--前端代码路径-->
        <workingDirectory>src/main/frontend</workingDirectory>
    </configuration>
</plugin>
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-war-plugin</artifactId>
    <version>2.4</version>
    <configuration>
        <warName>[war包名称]</warName>
        <webResources>
            <resource>
                <filtering>true</filtering>
                <directory>src/main/webapp</directory>
            </resource>
            <resource>
                <filtering>true</filtering>
                <!--Webpack编译目标路径-->
                <directory>src/main/frontend/dist</directory>
                <!--拷贝到target指定目录-->
                <targetPath>WEB-INF/web</targetPath>
            </resource>
        </webResources>
    </configuration>
</plugin>
```

## 配置文件

### sitemesh配置

> SpringMVC使用sitemesh+JSP，无法直接访问新增的html及api，需要修改sitemesh配置文件

我的sitemesh配置文件路径为`src/main/webapp/WEB-INF/decorators.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<decorators defaultdir="/WEB-INF/views">
   <decorator name="default" page="layouts/default.jsp" />
    <excludes>
        <!--符合下列模式的url不进行sitemesh装饰-->
        <pattern>*.html</pattern>
        <pattern>/api/*</pattern>
    </excludes>
</decorators>
```

### spring配置

> 访问静态资源时，根据配置的`mapping`到指定的`location`下寻找资源文件。
>
> 不配置静态资源，访问时会报`404 NOT FOUND`错误

```xml
<!-- 静态资源映射 -->
<!-- Webpack编译后的静态资源目录 -->
<mvc:resources mapping="/static/**" location="/static/,/WEB-INF/web/static/" />
<mvc:resources mapping="/**/*.html" location="/WEB-INF/web/" />
<mvc:resources mapping="*.html" location="/WEB-INF/web/" />
```