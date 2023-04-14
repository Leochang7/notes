[toc]

# Sevlet学习与使用

## 1. 前言

### 1.1 Servlet简介

`Java Servlet `是运行在 Web 服务器或应用服务器上的程序，它是作为来自 Web 浏览器或其他 HTTP 客户端的请求和 HTTP 服务器上的数据库或应用程序之间的中间层。

使用` Servlet`，您可以收集来自网页表单的用户输入，呈现来自数据库或者其他源的记录，还可以动态创建网页。

`Java Servlet `通常情况下与使用` CGI（Common Gateway Interface，公共网关接口）`实现的程序可以达到异曲同工的效果。但是相比于` CGI`，`Servlet `有以下几点优势：

- 性能明显**更好**。
- Servlet 在 Web 服务器的地址空间内执行。这样它就没有必要再创建一个单独的进程来处理每个客户端请求。
- Servlet 是**独立于平台**的，因为它们是用 Java 编写的。
- 服务器上的 Java 安全管理器执行了一系列限制，以保护服务器计算机上的资源。因此，`Servlet `是**可信**的。
- Java 类库的全部功能对 Servlet 来说都是可用的。它可以通过` sockets` 和` RMI 机制`与` applets`、数据库或其他软件进行交互。

### 1.2 Servlet架构

![Servlet 架构](D:\Notes\javaWeb\image\servlet-arch.jpg)

### 1.3 Servlet任务

`Servlet `执行以下主要任务：

- **读取客户端（浏览器）发送的显式的数据**。这包括网页上的 `HTML 表单`，或者也可以是来自` applet `或`自定义的 HTTP 客户端程序的表单`。
- **读取客户端（浏览器）发送的隐式的 HTTP 请求数据**。这包括` cookies`、`媒体类型`和`浏览器能理解的压缩格式`等等。
- **处理数据并生成结果。这个过程可能需要访问数据库**，执行 `RMI `或 `CORBA `调用，调用 `Web 服务`，或者直接`计算得出对应的响应`。
- **发送显式的数据（即文档）到客户端（浏览器）**。该文档的格式可以是多种多样的，包`括文本文件（HTML 或 XML）`、`二进制文件（GIF 图像）`、`Excel` 等。
- **发送隐式的 HTTP 响应到客户端（浏览器）**。这包括告诉浏览器或其他客户端被返回的文档类型（例如 HTML），设置 cookies 和缓存参数，以及其他类似的任务。

### 1.4 Servlet容器

引用自[C语言中文网](http://c.biancheng.net/servlet2/container.html)

> 您可能已经知道，部署动态网站一般需要 Web 服务器的支持，例如：
>
> - 运行 PHP 网站一般选择 Apache 或者 Nginx；
> - 运行 ASP/ASP.NET 网站一般选择 IIS；
> - 运行 Python 网站一般选择内置的 WSGI 服务器模块——wsgiref。
>
> 
> Web 服务器是一种对外提供 Web 服务的软件，它可以接收浏览器的 HTTP 请求，并将处理结果返回给浏览器。
>
> 在部署 Servlet 网站时，同样需要一种类似的软件，例如 Tomcat、Jboss、Jetty、WebLogic 等，但是它们通常被称为“容器”，而不是“服务器”，这究竟是为什么呢？Servlet 容器和传统意义上的服务器有什么不同呢？
>
> 本节我们先讲解传统 Web 服务器的架构模式，再讲解 Servlet 容器的架构模式，然后将它们进行对比，加深读者的理解。
>
> ## Web 服务器
>
> 初学者可能认为，只要有 Web 服务器，我们编写的网站代码就可以运行了，就可以访问数据库了，就可以注册登录并发布文章了，这其实是一种误解。
>
> 我们通常所说的 Web 服务器，比如 Apache、Nginx、IIS 等，它们的功能往往都比较单一，只能提供 http(s) 服务，让用户访问静态资源（HTML 文档、图片、CSS 文件、JavaScript 文件等），它们不能执行任何编程语言，也不能访问数据库，更不能让用户注册和登录。
>
> 也就是说，如果只有 Web 服务器，那您只能部署静态网站，不能部署动态网站。要想部署动态网站，必须要有编程语言运行环境（运行时，Runtime）的和数据库管理系统的支持。
>
> #### 运行环境（运行时）
>
> 开发网站使用的编程语言一般都是脚本语言（比如 PHP、ASP、Python），部署网站时都是将源代码直接扔到服务器上，然而源代码自己并不能运行，必须要有解释器的支持；当用户访问动态页面时，解释器负责分析、编译和执行源代码，然后得到处理结果。
>
> 解释器是执行脚本语言的核心部件，除此以外还有一些辅助性的部件，例如：
>
> - 垃圾回收器：负责及时释放不需要的内存，腾出资源供其它页面使用；
> - 标准库：任何编程语言都会附带标准库，它们提供了很多通用性的功能，极大地提高了开发效率，避免重复造轮子。
>
> 
> 我们习惯将以上各种支持脚本语言运行的部件统称为运行环境，或者运行时（Runtime）。
>
> #### 数据库
>
> Web 服务器不带数据库，编程语言也不带数据库，数据库是一款独立的软件；要想实现用户注册、发布文章、提交评论等功能，就必须安装一款数据库，比如 MySQL、Oracle、SQL Server 等。
>
> #### 总结
>
> 部署动态网站一般至少需要三个组件，分别是 Web 服务器、脚本语言运行时和数据库，例如，部署 PHP 网站一般选择「Apache + PHP 运行时 + MySQL」的组合。
>
> 
>
> ![img](http://c.biancheng.net/uploads/allimg/210616/135I02Q1-0.jpg)
>
> ## Web 容器
>
> 我们知道，Servlet 是基于 Java 语言的，运行 Servlet 必然少不了 JRE 的支持，它负责解析和执行字节码文件（`.class`文件）。然而 JRE 只包含了 Java 虚拟机（JVM）、Java 核心类库和一些辅助性性文件，它并不支持 Servlet 规范。要想运行 Servlet 代码，还需要一种额外的部件，该部件必须支持 Servlet 规范，实现了 Servlet 接口和一些基础类，这种部件就是 Servlet 容器。
>
> Servlet 容器就是 Servlet 代码的运行环境（运行时），它除了实现 Servlet 规范定义的各种接口和类，为 Servlet 的运行提供底层支持，还需要管理由用户编写的 Servlet 类，比如实例化类（创建对象）、调用方法、销毁类等。
>
> Servlet 中的容器和生活中的容器是类似的概念：生活中容器用来装水、装粮食，Servlet 中的容器用来装类，装对象。
>
> 读者可能会提出疑问，我们自己编写的 Servlet 类为什么需要 Servlet 容器来管理呢？这是因为我们编写的 Servlet 类没有 main() 函数，不能独立运行，只能作为一个模块被载入到 Servlet 容器，然后由 Servlet 容器来实例化，并调用其中的方法。
>
> 一个动态页面对应一个 Servlet 类，开发一个动态页面就是编写一个 Servlet 类，当用户请求到达时，Servlet 容器会根据配置文件（web.xml）来决定调用哪个类。
>
> 下图演示了 Servlet 容器在整个 HTTP 请求流程中的位置：
>
> 
>
> ![HTTP请求流程](http://c.biancheng.net/uploads/allimg/210616/135I031T-1.jpg)
>
> 
> 您看，Web 服务器是整个动态网站的“大门”，用户的 HTTP 请求首先到达 Web 服务器，Web 服务器判断该请求是静态资源还是动态资源：如果是静态资源就直接返回，此时相当于用户下载了一个服务器上的文件；如果是动态资源将无法处理，必须将该请求转发给 Servlet 容器。
>
> Servlet 容器接收到请求以后，会根据配置文件（web.xml）找到对应的 Servlet 类，将它加载并实例化，然后调用其中的方法来处理用户请求；处理结束后，Servlet 容器将处理结果再转交给 Web 服务器，由 Web 服务器将处理结果进行封装，以 HTTP 响应的形式发送给最终的用户。
>
> 常用的 Web 容器有 Tomcat、Jboss、Jetty、WebLogic 等，其中 Tomcat 由 Java 官方提供，是初学者最常使用的。
>
> 为了简化部署流程，Web 容器往往也会自带 Web 服务器模块，提供基本的 HTTP 服务，所以您可以不用再安装 Apache、IIS、Nginx 等传统意义上的服务器，只需要安装一款 Web 容器，就能部署 Servlet 网站了。正是由于这个原因，有的教材将 Tomcat 称为 Web 容器，有的教材又将 Tomcat 称为 Web 服务器，两者的概念已经非常模糊了。
>
> 将 Web 容器当做服务器使用后，上面的流程图就变成了下面的样子：
>
> 
>
> ![HTTP 请求流程](http://c.biancheng.net/uploads/allimg/210616/135I03C4-2.jpg)
>
> 
> 注意，Servlet 容器自带的 Web 服务器模块虽然没有传统的 Web 服务器强大，但是也足以应付大部分开发场景，对初学者来说是足够的。当然，您也可以将传统的 Web 服务器和 Servlet 容器组合起来，两者分工协作，各司其职，共同完成 HTTP 请求。
>
> #### 总结
>
> Servlet 容器就是 Servlet 程序的运行环境，它主要包含以下几个功能：
>
> - 实现 Servlet 规范定义的各种接口和类，为 Servlet 的运行提供底层支持；
> - 管理用户编写的 Servlet 类，以及实例化以后的对象；
> - 提供 HTTP 服务，相当于一个简化的服务器。

## 2. 准备工作

### 2.1  Tomcat的下载和安装

进入到Tomcat官网[Apache Tomcat® - Welcome!](https://tomcat.apache.org/)，在首页左侧的导航栏中找到“Download”分类，可以看到在它下面有多个版本的 Tomcat，如图所示。

![image-20220726120046638](D:\Notes\javaWeb\image\image-20220726120046638.png)

不同的 Tomcat 版本支持的 Java 版本也不同，读者可以根据自己的 JDK/JRE 版本来选择对应的 Tomcat 版本，如下图所示：

|    Tomcat 版本    |     最新子版本     | Servlet 规范 | JSP 规范 | EL 规范 | WebSocket 规范 | 认证（JASIC） 规范 |             Java 版本 JDK/JRE 版本             |
| :---------------: | :----------------: | :----------: | :------: | :-----: | :------------: | :----------------: | :--------------------------------------------: |
|  10.0.x（内测）   |       10.0.0       |     5.0      |   3.0    |   4.0   |      2.0       |        2.0         |                   8 以及更高                   |
|       9.0.x       |       9.0.36       |     4.0      |   2.3    |   3.0   |      1.1       |        1.1         |                   8 以及更高                   |
|       8.5.x       |       8.5.56       |     3.1      |   2.3    |   3.0   |      1.1       |        1.1         |                   7 以及更高                   |
| 8.0.x（已被取代） | 8.0.53（已被取代） |     3.1      |   2.3    |   3.0   |      1.1       |        N/A         |                   7 以及更高                   |
|       7.0.x       |      7.0.104       |     3.0      |   2.2    |   2.2   |      1.1       |        N/A         | 6 以及更高 （对于 WebSocket，支持 7 以及更高） |
|  6.0.x（已废弃）  |  6.0.53（已废弃）  |     2.5      |   2.1    |   2.1   |      N/A       |        N/A         |                   5 以及更高                   |
|  5.5.x（已废弃）  |  5.5.36（已废弃）  |     2.4      |   2.0    |   N/A   |      N/A       |        N/A         |                  1.4 以及更高                  |
|  4.1.x（已废弃）  |  4.1.40（已废弃）  |     2.3      |   1.2    |   N/A   |      N/A       |        N/A         |                  1.3 以及更高                  |
|  3.3.x（已废弃）  |  3.3.2（已废弃）   |     2.2      |   1.1    |   N/A   |      N/A       |        N/A         |                  1.1 以及更高                  |

我电脑使用的是JDK11这里我选择了Tomcat 9

![Tomcat 9 下载页面](http://c.biancheng.net/uploads/allimg/210616/13593J232-1.gif)

这里我下载了Tomcat 9 64位解压版

### 2.2 Tomcat的目录结构



 																								 			Tomcat子目录及其说明

| 子目录  |                            说明                            |
| :-----: | :--------------------------------------------------------: |
|   bin   |              命令中心（启动命令，关闭命令……）              |
|  conf   |               配置中心（端口号，内存大小……）               |
|   lib   |  Tomcat 的库文件。Tomcat 运行时需要的 jar 包所在的目录。   |
|  logs   |                       存放日志文件。                       |
|  temp   |                存储临时产生的文件，即缓存。                |
| webapps | 存放项目的文件，web 应用放置到此目录下浏览器可以直接访问。 |
|  work   |                  编译以后的 class 文件。                   |

#### 2.2.1. bin 目录

bin 目录用来存放 Tomcat 命令，主要分为两大类，一类是以`.sh`结尾的 Linux 命令，另一类是以`.bat`结尾的 Windows 命令。很多环境变量都在此处设置，例如 JDK 路径、Tomcat 路径等。



![bin 目录包含的内容](http://c.biancheng.net/uploads/allimg/210616/1400464001-0.gif)
图1：bin 目录包含的内容


下面是几个常用的 Tomcat 命令：

- startup.sh/startup.bat：用来启动 Tomcat；
- shutdown.sh/shutdown.bat：用来关闭 Tomcat；
- catalina.bat/ catalina.bat：用来设置 Tomcat 的内存。

#### 2.2.2 conf 目录

conf 目录主要是用来存放 Tomcat 的配置文件，如下图所示：



![conf 目录包含的内容](http://c.biancheng.net/uploads/allimg/210616/1400463A9-1.gif)
图2：conf 目录包含的内容


下面是常用到的几个文件：

- server.xml 用来设置域名、IP、端口号、默认加载的项目、请求编码等；
- context.xml 用来配置数据源等；
- tomcat-users.xml 用来配置和管理 Tomcat 的用户与权限；
- web.xml 可以设置 Tomcat 支持的文件类型；
- 在 Catalina 目录下可以设置默认加载的项目。 

#### 2.2.3. lib 目录

lib 目录主要用来存放 Tomcat 运行需要加载的 jar 包。



![lib 目录包含的内容](http://c.biancheng.net/uploads/allimg/210616/14004B0Q-2.gif)
图3：lib 目录包含的内容

#### 2.2.4. logs 目录

logs 目录用来存放 Tomcat 在运行过程中产生的日志文件，清空该目录中的文件不会对 Tomcat 的运行带来影响。

在 Windows 系统中，控制台的输出日志在 catalina.xxxx-xx-xx.log 文件中；在 Linux 系统中，控制台的输出日志在 catalina.out 文件中。

#### 2.2.5. temp 目录

temp 目录用来存放 Tomcat 在运行过程中产生的临时文件，清空该目录中的文件不会对 Tomcat 的运行带来影响。 



![temp 目录包含的内容](http://c.biancheng.net/uploads/allimg/210616/14004630B-3.gif)
图4：temp 目录包含的内容

#### 2.2.6. webapps 目录

webapps 目录用来存放应用程序（也就是通常所说的网站），当 Tomcat 启动时会去加载 webapps 目录下的应用程序，我们编写的 Servlet 程序就可以放在这里。Tomcat 允许以文件夹、war 包、jar 包的形式发布应用。



![webapps 目录包含的内容](http://c.biancheng.net/uploads/allimg/210616/1400464130-4.gif)
图5：webapps 目录包含的内容

#### 2.2.7. work 目录

work 目录用来存放 Tomcat 在运行时的编译文件（也即 class 字节码文件），例如 JSP 编译后的文件。清空 work 目录，然后重启 Tomcat，可以达到清除缓存的作用。

### 2.3 导入jar包

去[Maven官方仓库](https://mvnrepository.com/)下载 **javax.servlet**包

![image-20220726121102211](D:\Notes\javaWeb\image\image-20220726121102211.png)

复制Xml代码段到Maven项目的pom.xml文件中

![image-20220726121128332](D:\Notes\javaWeb\image\image-20220726121128332.png)

点击右侧Maven标签选择刷新即可完成自动下载

![image-20220724132245578](D:\Notes\javaWeb\image\image-20220724132245578-165864647588812.png)

## 3.Servlet创建

在 Servlet 中，一个动态网页对应一个 Servlet 类，我们可以通过` web.xml` 配置文件将 URL 路径和 Servlet 类对应起来。**访问一个动态网页的过程，实际上是将对应的 Servlet 类加载、实例化并调用相关方法的过程**；网页上显示的内容，就是通过 Servlet 类中的某些方法向浏览器输出的 HTML 语句。

所以，使用 Servlet 创建动态网页的第一步，就是创建 Servlet 类。

Servlet 规范的最顶层是一个名为 javax.servlet.Servlet 的接口，所有的 Servlet 类都要直接或者间接地实现该接口。直接实现 Servlet 接口不太方便，所以 Servlet 又内置了两个 Servlet 接口的实现类（抽象类），分别为 GenericServlet 和 HttpServlet，因此，创建 Servlet 类有如下三种方式：

1. 实现 javax.servlet.Servlet 接口，重写其全部方法。
2. 继承 javax.servlet.GenericServlet 抽象类，重写 `service() `方法。
3. 继承 javax.servlet.http.HttpServlet 抽象类，重写` doGet() `或` doPost() `方法。

### 3.1 Servlet、GenericServlet 、HttpServlet 的关系

下图展示了 Servlet、GenericServlet 以及 HttpServlet 三者之间的关系，其中 MyServlet 是我们自定义的 Servlet 类。



![Servlet 关系图](http://c.biancheng.net/uploads/allimg/210616/14021Mc6-0.png)


由上图可知：

1. GenericServlet 是实现了 Servlet 接口的抽象类。
2. HttpServlet 是 GenericServlet 的子类，具有 GenericServlet 的一切特性。
3. Servlet 程序（MyServlet 类）是一个实现了 Servlet 接口的 Java 类。

### 3.2 Servlet 接口

javax.servlet.Servlet 是 Servlet API 的核心接口，所有的 Servlet 类都直接或间接地实现了这一接口。

Servlet 接口中定义了 5 个方法，下面我们对他们做简单的介绍。



| 返回值        | 方法                                            | 备注                                                         |
| ------------- | ----------------------------------------------- | ------------------------------------------------------------ |
| void          | init(ServletConfig config)                      | Servlet 实例化之后，由 Servlet 容器调用，用来初始化 Servlet 对象。该方法只能被调用一次。 参数 config 用来向 Servlet 传递配置信息。 |
| void          | service(ServletRequest req,ServletResponse res) | Servlet 容器调用该方法处理客户端请求。                       |
| void          | destroy()                                       | 服务器关闭、重启或者 Servlet 对象被移除时，由 Servlet 容器调用，负责释放 Servlet 对象占用的资源。 |
| ServletConfig | getServletConfig()                              | 该方法用来获取 ServletConfig 对象，该对象中包含了 Servlet 的初始化参数。 |
| String        | getServletInfo()                                | 该方法用于获取 Servlet 的信息，例如作者、版本、版权等。      |

* 示例 1

通过实现 Servlet 接口创建 Servlet，示例代码如下。

```java
package net.biancheng.www;
import javax.servlet.*;
import java.io.IOException;
import java.io.PrintWriter;
public class MyServlet implements Servlet {
    //Servlet 实例被创建后，调用 init() 方法进行初始化，该方法只能被调用一次
    @Override
    public void init(ServletConfig servletConfig) throws ServletException {
    }
    //返回 ServletConfig 对象，该对象包含了 Servlet 的初始化参数
    @Override
    public ServletConfig getServletConfig() {
        return null;
    }
    //每次请求，都会调用一次 service() 方法
    @Override
    public void service(ServletRequest servletRequest, ServletResponse servletResponse) throws ServletException, IOException {
        //设置字符集
        servletResponse.setContentType("text/html;charset=UTF-8");
        //使用PrintWriter.write()方法向前台页面输出内容
        PrintWriter writer = servletResponse.getWriter();
        writer.write("编程帮欢迎您的到来，网址: www.biancheng.net");
        writer.close();
    }
    //返回关于 Servlet 的信息，例如作者、版本、版权等
    @Override
    public String getServletInfo() {
        return null;
    }
    //Servelet 被销毁时调用
    @Override
    public void destroy() {
    }
}
```

### 3.3 GenericServlet 抽象类

javax.servlet.GenericServlet 实现了 Servlet 接口，并提供了除 service() 方法以外的其他四个方法的简单实现。通过继承 GenericServlet 类创建 Servlet ，只需要重写 service() 方法即可，大大减少了创建 Servlet 的工作量。

GenericServlet 类中还提供了以下方法，用来获取 Servlet 的配置信息。



| 返回值              | 方法                          | 备注                                                         |
| ------------------- | ----------------------------- | ------------------------------------------------------------ |
| String              | getInitParameter(String name) | 返回名字为 name 的初始化参数的值，初始化参数在 web.xml 中进行配置。如果参数不存在，则返回 null。 |
| Enumeration<String> | getInitParameterNames()       | 返回 Servlet 所有初始化参数的名字的枚举集合，若 Servlet 没有初始化参数，返回一个空的枚举集合。 |
| ServletContext      | getServletContext()           | 返回 Servlet 上下文对象的引用。                              |
| String              | getServletName()              | 返回此 Servlet 实例的名称。                                  |

* 示例 2

通过继承 GenericServlet 抽象类创建 Servlet，示例代码如下。

```java
package net.biancheng.www;
import javax.servlet.*;
import java.io.IOException;
import java.io.PrintWriter;
public class MyServlet extends GenericServlet {
    @Override
    public void service(ServletRequest servletRequest, ServletResponse servletResponse) throws ServletException, IOException {
        //设置字符集
        servletResponse.setContentType("text/html;charset=UTF-8");
        //使用PrintWriter.write()方法向前台页面输出内容
        PrintWriter writer = servletResponse.getWriter();
        writer.write("编程帮欢迎您的到来，网址: www.biancheng.net");
        writer.close();
    }
}
```

### 3.4 HttpServlet 抽象类

`javax.servlet.http.HttpServlet `继承了` GenericServlet `抽象类，用于开发基于 HTTP 协议的 Servlet 程序。由于 Servlet 主要用来处理 HTTP 的请求和响应，所以通常情况下，编写的 Servlet 类都继承自 HttpServlet。

在 HTTP/1.1 协议中共定义了 7 种请求方式，即 GET、POST、HEAD、PUT、DELETE、TRACE 和 OPTIONS。

`HttpServlet` 针对这 7 种请求方式分别定义了 7 种方法，即` doGet()`、`doPost()`、`doHead()`、`doPut()`、`doDelete()`、`doTrace() `和` doOptions()`。

`HttpServlet `重写了 `service() `方法，该方法会先获取客户端的请求方式，然后根据请求方式调用对应 doXxx 方法。

* 示例 3

由于我们使用的请求方式主要是 GET 和 POST，所以通过继承 `HttpServlet `类创建 Servlet 时，只需要重写 doGet 或者 doPost 方法，代码如下。

```java
package net.biancheng.www;
import javax.servlet.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
public class MyServlet extends HttpServlet {
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //使用PrintWriter.write()方法向前台页面输出内容
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter writer = resp.getWriter();
        writer.write("编程帮欢迎您的到来，网址: www.biancheng.net");
        writer.close();
    }
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //使用PrintWriter.write()方法gaifang向前台页面输出内容
        PrintWriter writer = resp.getWriter();
        writer.write("编程帮欢迎您的到来，网址: www.biancheng.net");
        writer.close();
        doGet(req, resp);
    }
}
```

### 3.5 总结

上面演示了三种创建 Servlet 的方式，那么在实际开发中，我们究竟该选择哪一种呢？下面我们就来分析和对比一下。

**1) Servlet 接口**

通过实现 Servlet 接口创建 Servlet 类，需要重写其全部的方法，比较繁琐，所以我们很少使用该方法创建 Servlet。

**2)GenericServlet 类**

`GenericServlet `抽象类实现了 Servlet 接口，并对 Servlet 接口中除 `service()` 方法外的其它四个方法进行了简单实现。通过继承` GenericServlet `创建 Servlet，只需要重写` service() `方法即可，大大减少了创建 Servlet 的工作量。

Generic 是“通用”的意思，正如其名，`GenericServlet` 是一个通用的 Servlet 类，并没有针对某种场景进行特殊处理，尤其是 HTTP 协议，我们必须手动分析和封装 HTTP 协议的请求信息和响应信息。

**3) HttpServlet 类**

`HttpServlet` 是 `GenericServlet `的子类，它在 `GenericServlet` 的基础上专门针对 HTPP 协议进行了处理。`HttpServlet `为 HTTP 协议的每种请求方式都提供了对应的方法，名字为 doXxx()，例如：

- 处理 GET 请求的方法为 `doGet()`
- 处理 POST 请求的方法为` doPost()`

正如其名，`HttpServlet `就是专为 HTTP 协议而量身打造的 Servlet 类。

在互联网上，人们都是通过 HTTP 协议来访问动态网页的，其中使用最频繁的就是 GET 方式和 POST 方式，因此，我们通常基于 `HttpServlet `来创建 Servlet 类，这样就省去了处理 HTTP 请求的过程。