[toc]

# java的JDBC编程

## JDBC介绍

JDBC（Java DataBaseConnectivity）是Java和数据库之间的一个桥梁，是一个规范而不是一个实现，能够执行[SQL语句](https://so.csdn.net/so/search?q=SQL语句&spm=1001.2101.3001.7020)。它由一组用[Java语言](https://baike.baidu.com/item/Java语言)编写的类和接口组成。各种不同类型的数据库都有相应的实现。

![img](D:\Notes\javaWeb\image\未命名绘图-第 3 页.drawio.png)

## JDBC编程

### 1.下载驱动包

去[Maven官方仓库](https://mvnrepository.com/)下载Mysql驱动，选择跟自己Myqsl版本相同或较高的驱动版本

![image-20220724132516775](D:\Notes\javaWeb\image\image-20220724132516775.png)

我这里选择了8.0.29版本的驱动包

复制到Maven标签页下到代码到Maven项目下的pom.xml文件

![image-20220724132149393](D:\Notes\javaWeb\image\image-20220724132149393-165864647778614.png)

点击右侧Maven标签选择刷新即可完成自动下载

![image-20220724132245578](D:\Notes\javaWeb\image\image-20220724132245578-165864647588812.png)

### 2.使用JDBC连接数据库

jdbc使用的四个步骤

1. 注册驱动 - 加载Driver类
2. 获取连接 - 获得Connection对象
3. 执行增删改查 - 发送SQL给Mysql执行
4. 释放资源

使用JDBC连接数据库有五种方法，这里只详列其中三种

* 第一种

  ```java
  public class jdbc01 {
  
      public static void main(String[] args) throws SQLException {
          //1.注册驱动
          Driver driver = new Driver();
          //2.得到连接
          //JDBC的本质就是socket连接
          String url = "jdbc:mysql://localhost:3306/educ";
          //将用户名和密码放入到properties对象中
          Properties properties = new Properties();
          properties.setProperty("user","root");
          properties.setProperty("password","z1093964909");
          Connection connection = driver.connect(url,properties);
          //3.执行SQL
          String sql = "insert into student values('9494949','卢本伟','男',20,'CS')";
          //statement用于执行静态SQL语句，并返回其生成的结果的对象
          Statement statement = connection.createStatement();
          //rows若大于0则代表影响的行数
          int rows = statement.executeUpdate(sql);
          System.out.println(rows > 0?"执行成功":"执行失败");
          //4.关闭连接资源
          //先关闭statement再关闭connection
          statement.close();
          connection.close();
      }
  }
  ```

  > 第一种方法直接使用com.mysql.jc.jdbc.Driver()属于懒性加载，灵活性差，依赖性强，可以使用反射实现动态加载

* 第二种

  ```java
  public class jdbc02 {
  
      public static void main(String[] args) throws SQLException {
          Class.forName("com.mysql.cj.jdbc.Driver");
          //这里可以省略注册，mysql驱动版本大于5.1.6不需要显形调用反射注册驱动而是自动调动驱动注册
          //Driver类要使用com.mysql.cj.jdbc.Driver而不是com.mysql.jdbc.Driver，因为该包已被弃用
          //写上可以更加明确
          String url= "jdbc:mysql://localhost:3306/educ";
          String user = "root";
          String password = "z1093964909";
          Connection connection = DriverManager.getConnection(url,user,password);
      }
  }
  ```

* 第三种，最常用的一种

  在第二种的基础上使用配置文件使连接myqsl更加灵活

mysql.properties

```properties
user=root
password=z1093964909
url=jdbc:mysql://localhost:3306/educ
driver=com.mysql.cj.jdbc.Driver
```



```java
public class jdbc03 {
    public static void main(String[] args) throws IOException, ClassNotFoundException, SQLException {
        //通过properties对象获取配置信息
        Properties properties = new Properties();
        properties.load(new FileInputStream("src\\mysql.properties"));
        //获取相关的值
        String user = properties.getProperty("user");
        String password = properties.getProperty("password");
        String url = properties.getProperty("url");
        String driver = properties.getProperty("driver");

        Class.forName(driver);
        Connection connection = DriverManager.getConnection(url,user,password);
    }
}
```

### 3.ResultSet对象

`ResultSet`对象它被称为结果集，它代表符合SQL语句条件的所有行，并且它通过一套getXXX方法提供了对这些行中数据的访问。

`ResultSet`里的数据一行一行排列，每行有多个字段，并且有一个记录指针，指针所指的数据行叫做当前数据行，我们只能来操作当前的数据行。 我们如果想要取得某一条记录，就要使用`ResultSet`的`next()`方法 ,如果我们想要得到`ResultSet`里的所有记录，就应该使用`while循环`。

```java
public void connection() throws IOException, ClassNotFoundException, SQLException {
    //获取配置信息
    Properties properties = new Properties();
    properties.load(new FileReader("src//mysql.properties"));
    String user = properties.getProperty("user");
    String password = properties.getProperty("password");
    String driver = properties.getProperty("driver");
    String url = properties.getProperty("url");
    //注册驱动，获取连接
    Class.forName(driver);
    Connection connection = DriverManager.getConnection(url, user, password);

    //操作
    Statement statement = connection.createStatement();
    String sql = "select * from sutdent";
    
    ResultSet resultSet = statement.executeQuery(sql);//dml语句执行executeUpdate()方法，查询执行executeQuery()方法
    
    while (resultSet.next()){
            String sno = resultSet.getString(1);
            String sname = resultSet.getString(2);
            String ssex = resultSet.getString(3);
            int sage = resultSet.getInt(4);
            String sdept = resultSet.getString(5);
            System.out.println(sno+" "+sname+" "+ssex+" "+sage+" "+sdept);
        }

    //关闭连接
    resultSet.close();
    statement.close();
    connection.close();
}
```

- **当语句 Connection connection = DriverManager.getConnection(url, user, password) 执行后**，`Connection`接口类型的变量connection得到的是它的实现类 `JDBC4Connection`（ConnectionImpl的子类）。其中实现类是由mysql的jar包提供的
- ResultSet是接口。因为引入了mysql的jar包（该数据库公司提供的），里面实现了该接口。
- **java.sql**：是java公司包，接口为主，不实现。 **com.mysql.jdbc:** 是mysql厂商提供的具体实现。

**成功运行**

![image-20220724144219849](D:\Notes\javaWeb\image\image-20220724144219849-165864647053310.png)

### 4.Statentment对象

`Statement`对象主要是将SQL语句发送到数据库中。 JDBC API中主要提供了三种`Statement`对象**(Statement,PreparedStatement,CallableStatement)**。

![image-20220725112326221](D:\Notes\javaWeb\image\image-20220725112326221.png)

**主要掌握两种执行SQL的方法：**

- `executeQuery()`方法执行后返回单个结果集的，通常用于`select`语句
- `executeUpdate()`方法返回值是一个整数，指示受影响的行数，通常用于`update、 insert、 delete`语句

**Statement和PreparedStatement的异同及优缺点**

* 两者都是用来执`SQL`语句的

* `PreparedStatement`需要根据SQL语句来创建，它能够通过设置参数，指定相应的值，不是像`Statement`那样使用字符串拼接的方式

**PreparedStatement的优点**

* 其使用参数设置(占位符赋值?)，可读性好，不易记错。在`statement`中使用字符串拼接，可读性和维护性比较差
* 其具有预编译机制，性能比`statement`更快
* 其能够有效防止`SQL`注入攻击

### 5.JDBC API

<img src="D:\Notes\javaWeb\image\JDBC API.png" alt="JDBC API"  />

### 6.JDBCUtils

JDBC工具类实现

```java
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;

public class JDBCUtils {
    private static String user;
    private static String password;
    private static String url;
    private static String driver;

    static {
        Properties properties = new Properties();
        try {
            properties.load(new FileInputStream("mysql.properties"));
            user = properties.getProperty(user);
            password = properties.getProperty(password);
            url = properties.getProperty(url);
            driver = properties.getProperty(driver);
            Class.forName(driver);
        } catch (IOException | ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    public static Connection getConnection() {
        try {
            return DriverManager.getConnection(url, user, password);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static void close(ResultSet set, Statement statement, Connection connection) {
        try {
            if (set != null) {
                set.close();
            }
            if (statement != null){
                statement.close();
            }
            if (connection != null){
                connection.close();
            }
        }catch (SQLException e){
            throw new RuntimeException(e);
        }
    }
}
```

使用JDBCUtils实现`DML`操作,包括`update,insert,delete`

```java
public void testDML(){
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        String sql = "insert into student values(?,?,?,?,?)";
        try {
            connection = JDBCUtils.getConnection();
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setString(1,"54654");
            preparedStatement.setString(2,"谷爱凌");
            preparedStatement.setString(3,"女");
            preparedStatement.setInt(4,18);
            preparedStatement.setString(5,"CS");
            preparedStatement.executeUpdate();
        }
        catch (SQLException e){
            throw new RuntimeException(e);
        }finally {
            JDBCUtils.close(null,preparedStatement,connection);
        }
    }
```

使用JDBUtils实现`select`操作

```java
public void testSelect(){
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet set = null;
        String sql = "select * from student";
        try {
            connection = JDBCUtils.getConnection();
            preparedStatement = connection.prepareStatement(sql);
            set = preparedStatement.executeQuery();
            while (set.next()){
                String sno = set.getString(1);
                String sname = set.getString(2);
                String ssex = set.getString(3);
                int sage = set.getInt(4);
                String sdept = set.getString(5);
                System.out.println(sno+"|"+sname+"|"+ssex+"|"+sage+"|"+sdept);
            }
        }
        catch (SQLException e){
            throw new RuntimeException(e);
        }finally {
            JDBCUtils.close(set,preparedStatement,connection);
        }
    }
```

### 7.事务 批处理 连接池

#### 7.1事务

* 基本介绍

1. JDBC程序中当一个`Connection`对象创建时，默认情况下是自动提交事务:每。次执行一个`SQL`语句时，如果执行成功，就会向数据库自动提交，而不能回滚。

2. JDBC程序中为了让多个`SQL`语句作为一个整体执行，需要使用事务
3. 调用`Connection`的`setAutoCommit(false)`可以取消自动提交事务
4. 在所有的`SQL`语句都成功执行后，调用`commit()`方法提交事务
5. 在其中某个操作失败或出现异常时，调用`rollback()`方法回滚事务

事务示例

```java
public void testShiwu() {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        String sql1 = "update student set Sname = '李白' where Sname = '卢本伟'";
        String sql2 = "update student set Sname = '杜甫' where Sname = '谷爱凌'";
        try {
            connection = JDBCUtils.getConnection();
            //将connection设置为不自动提交
            connection.setAutoCommit(false);
            preparedStatement = connection.prepareStatement(sql1);
            preparedStatement.executeUpdate();
            //抛出异常
            //int i = 1/0;
            preparedStatement = connection.prepareStatement(sql2);
            preparedStatement.executeUpdate();
            //提交事务
            connection.commit();
        } catch (SQLException e) {
            //进行回滚，默认回滚到事务初始的状态
            System.out.println("执行发生异常，进行回滚");
            try {
                connection.rollback();
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
            throw new RuntimeException(e);

        } finally {
            JDBCUtils.close(null, preparedStatement, connection);
        }
    }
```



#### 7.2批处理

* 基本介绍
  1. 当需要成批插入或者更新记录时。可以采用Java的批量更新机制，这一机制允许多条语句一次性提交给数据库批量处理。通常情况下比单独提交处理更有效率。
  2. JDBC的批量处理语句包括下面方法:
     `addBatch()`添加需要批量处理的`SQL`语句,参数`executeBatch()`执行批量处理语句;
     `clearBatch()`清空批处理包的语句
  3. JDBC连接`MySQL`时，如果要使用批处理功能,请再url中加参
     数`?rewriteBatchedStatements=true`
  4. 批处理往往和`PreparedStatement`一起搭配使用，可以既减少编译次数，又减
     少运行次数，效率大大提高

* 实际使用

  ```java
  public void batch() throws Exception {
          Connection connection = JDBCUtils.getConnection();
          String sql = "insert into test1 values(?,?)";
          PreparedStatement preparedStatement = connection.prepareStatement(sql);
          System.out.println("开始执行");
          //开始时间
          long start = System.currentTimeMillis();
          //5000执行
          for (int i = 0; i < 5000; i++) {
              preparedStatement.setString(1, "jack" + i);
              preparedStatement.setString(2, "666");
              //将sql语句加入到批处理包中 ->看源码
              preparedStatement.addBatch();
              //当有1000条记录时，在批量执行
              if((i + 1) % 1000 == 0) {
                  //满1000条清空一把
                  preparedStatement.executeBatch();
                  preparedStatement.clearBatch();
              }
          }
          long end = System.currentTimeMillis();
          System.out.println("耗时"+(end-start));
      }
  ```

  



#### 7.3连接池

* **传统获取Connection问题分析**
  
  1. 传统的JDBC数据库连接使用`DriverManager`来获取，每次向数据库建立连接的时候都要`Connection`加载到内存中，再验证IP地址，用户名和密码(0.05s~1s时间)。需要数据库连接的时候，就向数据库要求一个频繁的进行数据库连接操作将占用很多的系统资源，容易造成服务器崩溃
  2. 每一次数据库连接，使用完后都得断开，如果程序出现异常而未能关闭，将导致数据库内存泄漏，最终将导致重启数据库。
  3. 传统获取连接的方式，不能控制创建的连接数量,如连接过多，也可能导致内存泄漏，MySQL崩溃。
  4. 解决传统开发中的数据库连接问题，可以采用`数据库连接池技术`(connection pool) 。
  
* **数据库连接池基本介绍**
  1. 预先在**缓冲池**中放入一定数量的连接,当需要建立数据库连接时，只需从“**缓冲池**”中取出一个，使用完毕之后再放回去。数据库连接池负责分配、管理和释放数据库
  2. 连接,它允许应用程序重复使用一个现有的数据库连接,而不是重新建立一个。
  3. 当应用程序向连接池请求的连接数超过最大连接数量时，这些请求将被加入到等待队列中

* **数据库连接池种类**
  1. JDBC的数据库连接池吏用` javax.sql.DataSource`来表示，`DataSource`只是一个接口，该接口通常由第三方提供实现
  2. `C3P0`数据库连接池，速度相对**较慢**，**稳定性**不错(hibernate, spring)
  3. `3DBCP`数据库连接池，速度相对`c3p0`**较快**，但**不稳定**
  4. `Proxool`数据库连接池，有监控连接池状念的功能，稳点性较`c3p0`差一点
  5. `BoneCP` 数据库连接池，**速度快**
  6. `Druid(德鲁伊)`是阿里提供的数据库连接池，集`DBCP`、`C3P0`、`Proxool`
     优点于一身的数据库连接池

* **数据库连接池工作原理**![img](D:\Notes\javaWeb\image\src=http%3A%2F%2Fguardwhy.oss-cn-beijing.aliyuncs.com%2Fimg%2FjavaWEB%2Fimage03%2F23-mysql.png&refer=http%3A%2F%2Fguardwhy.oss-cn-beijing.aliyuncs.png)

* **数据库连接池技术的优点**
  1. `资源重用`
     由于数据库连接得以重用，避免了频繁创建，释放连接引起的大量性能开销。在减少系统消耗的基础上，另一方面也增加了系统运行环境的平稳性。
  2. `更快的系统反应速度`
     数据库连接池在初始化过程中，往往已经创建了若干数据库连接置于连接池中备用。此时连接的初始化工作均已完成。对于业务请求处理而言，直接利用现有可用连接，避免了数据库连接初始化和释放过程的时间开销，从而减少了系统的响应时间
  3. `新的资源分配手段`
     对于多应用共享同一数据库的系统而言，可在应用层通过数据库连接池的配置，实现某一应用最大可用数据库连接数的限制，避免某一应用独占所有的数据库资源
  4. `统一的连接管理，避免数据库连接泄漏`
     在较为完善的数据库连接池实现中，可根据预先的占用超时设定，强制回收被占用连接，从而避免了常规数据库连接操作中可能出现的资源泄露

* **C3P0连接池的使用**

  **无Xml方式**

  ```java
  public void C3P0_01() throws IOException, PropertyVetoException, SQLException {
          //1. 创建一个数据源对象
          ComboPooledDataSource comboPooledDataSource = new ComboPooledDataSource();
          //2. 通过配置文件获得相关连接信息
          Properties properties = new Properties();
          properties.load(new FileInputStream("src\\main\\resources\\mysql.properties"));
          String user = properties.getProperty("user");
          String password = properties.getProperty("password");
          String url = properties.getProperty("url");
          String driver = properties.getProperty("driver");
          //给数据源ComboPooledDataSource设置相关参数
          //连接管理是由ComboPooledDataSource来管理而不是DriverMannger
          comboPooledDataSource.setUser(user);
          comboPooledDataSource.setPassword(password);
          comboPooledDataSource.setJdbcUrl(url);
          comboPooledDataSource.setDriverClass(driver);
          //设置初始化连接数
          comboPooledDataSource.setInitialPoolSize(10);
          //设置最大连接数
          comboPooledDataSource.setMaxPoolSize(50);
          //测试C3P0连接数据库5000次所用的时间
          long start = System.currentTimeMillis();
          for (int i = 0; i < 5000; i++) {
              Connection connection = comboPooledDataSource.getConnection();
              connection.close();
          }
          long end = System.currentTimeMillis();
          System.out.println("共耗时"+(end-start)+"ms");
      }
  ```

  **有Xml配置文件**

  ```java
  public void C3P0_02() throws SQLException {
          ComboPooledDataSource mySource = new ComboPooledDataSource("mySource");
      //下面的代码用来计算连接 5000 次数据库所需的时间
          long start = System.currentTimeMillis();
          for (int i = 0; i < 5000; i++) {
              Connection connection = mySource.getConnection();
              connection.close();
          }
          long end = System.currentTimeMillis();
          System.out.println("配置文件连接用时："+(end-start));
      }
  ```

  > c3p0-config.xml文件应该放在target目录下的classes文件夹内

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  
  <c3p0-config>
      <default-config>
          <property name="driverClass">com.mysql.cj.jdbc.Driver</property>
          <property name="jdbcUrl">jdbc:mysql://localhost:3306/jdbc</property>
          <property name="user">root</property>
          <property name="password">java</property>
  
          <property name="initialPoolSize">10</property>
          <property name="maxIdleTime">30</property>
          <property name="maxPoolSize">100</property>
          <property name="minPoolSize">10</property>
      </default-config>
  <!--    数据源名称，代表连接池-->
      <named-config name="mySource">
          <property name="driverClass">com.mysql.jdbc.Driver</property>
          <property name="jdbcUrl">jdbc:mysql://localhost:3306/educ</property>
          <property name="user">root</property>
          <property name="password">z1093964909</property>
  
          <property name="initialPoolSize">10</property>
          <property name="maxIdleTime">30</property>
          <property name="maxPoolSize">50</property>
          <property name="minPoolSize">10</property>
          <property name="maxStatements">5</property>
          <property name="maxStatementsPerConnection">2</property>
      </named-config>
  </c3p0-config>
  ```

* **使用的Druid(德鲁伊)**

  **使用配置文件**

  ```java
  public void druid() throws Exception {
          Properties properties = new Properties();
          properties.load(new  FileInputStream("src\\druid.properties"));
          DataSource dataSource = DruidDataSourceFactory.createDataSource(properties);
          //下面的代码用来计算连接 5000 次数据库所需的时间
          long start = System.currentTimeMillis();
          for (int i = 0; i < 500000; i++) {
              Connection connection = dataSource.getConnection();
              connection.close();
          }
          long end = System.currentTimeMillis();
          System.out.println("配置文件连接用时："+(end-start));
      }
  ```

  **druid.properties**

  ```properties
  driverClassName=com.mysql.cj.jdbc.Driver
  url=jdbc:mysql://localhost:3306/educ
  # 注意这里是username
  username=root
  password=z1093964909
  # 初始化申请的连接数量
  initialSize=10
  # 最大的连接数量
  maxActive=10
  # 超时时间3000
  maxWait=3000
  ```

  
  
  ![在这里插入图片描述](D:\Notes\javaWeb\image\watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzUyMDQ1MA==,size_16,color_FFFFFF,t_70.png)**Druid工具类**
  
  ```java
  public class JdbcUtilByDruid {
  
      private static DataSource dataSource;
  	//初始化
      static {
          Properties properties = new Properties();
          try {
              properties.load(new FileReader("src//druid.properties"));
              dataSource = DruidDataSourceFactory.createDataSource(properties);
          } catch (Exception e) {
              e.printStackTrace();
          }
      }
  	//连接
      public static Connection getConnection() throws SQLException {
          return dataSource.getConnection();
      }
  	//关闭。此处close方法不是真的关闭连接，只是把连接返回数据库连接池
      public static void close(ResultSet resultSet, Statement statement, Connection connection){
          try {
              if(resultSet!=null){
                  resultSet.close();
              }
              if(statement!=null){
                  statement.close();
              }
              if(connection!=null){
                  connection.close();
              }
          } catch (SQLException e) {
              throw new RuntimeException(e);
          }
      }
  }
  ```
  
  

### 8.APDBUtils

* **问题**

1. 关闭connection后，resultSet结果集无法使用

2. resultSet不利于数据的管理

3. 示意图
   ![image-20220725143249399](D:\Notes\javaWeb\image\image-20220725143249399.png)

   

* **解决办法**

  把数据库数据映射成java里的类，采用`集合`来存储（java存储resultSet）。封装的java类也称：`JavaBean`，`PoJo`，`Domain`

  引出DBUtil工具，该工具提供了一整套简洁的方法。

* **Apache—DBUtils**

  ![image-20220725143737072](D:\Notes\javaWeb\image\image-20220725143737072.png)

* **使用APDBUtils实现select**

  ```java
  //使用apache-DBUtils 工具类+druid 完成对表的crud操作
      //返回结果是多行的情况
      public void testQueryMany() throws SQLException {
          //1。得到连接(druid)
          Connection connection = JDBCUtils.getConnection();
          //2．使用DBUtils 类和接口，先引入DBUtils相关的jar,加入到本Project
          // 3．创建QueryRunner
          QueryRunner queryRunner = new QueryRunner();
          //4。就可以执行相关的方法，返回ArrayList结果集
          String sql = "select * from student";
          //(1) query 方法就是执行sql 语句，得到resultset ---封装到-->ArrayList集合中
          //(2) 返回集合
          //(3) connection:连接
          //(4) sql :执行的sql语句
          //(5) new BeanListHandLer<>(Actor.class):在将resultset -> Actor对象 -> 封装到 ArrayListl
          //底层使用反射机制去获取Actor 类的属性，然后进行封装
          //(6) 1 就是给sql 语句中的?赋值，可以有多个值，因为是可变参数0bject..·params
          //(7) 底层得到的resultSet，会在query 关闭，关闭PreparedStatment
          List<Student> list = queryRunner.query(connection, sql, new BeanListHandler<>(Student.class));
          System.out.println("输出集合的信息");
          for (Student student : list) {
              System.out.println(student);
          }
          //释放资源
          JDBCUtils.close(null,null,connection);
      }
  ```

  > Student中，即JavaBean中一定要给一个无参构造用于反射，字段必须写getter和setter方法

**使用APDBUtils实现DML**

```java
//使用apache-DBUtils 工具类+druid 完成对表的crud操作
    //返回结果是多行的情况
    public void testQueryMany() throws SQLException {
        //1。得到连接(druid)
        Connection connection = JDBCUtils.getConnection();
        //2．使用DBUtils 类和接口，先引入DBUtils相关的jar,加入到本Project
        //3．创建QueryRunner
        QueryRunner queryRunner = new QueryRunner();
        //4. 这里组织sql完成update,insert,delete
        String sql = "update student set sname = ? where sname = '李白';
        //(1) 执行dml语句是queryRunner.update()
        //(2) 返回的值是受影响的行数
        int affectedRows = queryRunner.update(connection,sql,"白居易")
        System.out.println(affectedRows > 0 ? "执行成功":"没有影响到表
");
        //释放资源
        JDBCUtils.close(null,null,connection);
    }
```

### 9.BasicDao

* **前言**

![image-20220725155044578](D:\Notes\javaWeb\image\image-20220725155044578.png)

![image-20220725160522146](D:\Notes\javaWeb\image\image-20220725160522146.png)

* **BasicDao类**

  ```java
  public class BasicDao<T> {
  
      private QueryRunner queryRunner = new QueryRunner();
  	//dml操作
      public int update(String sql, Object... parameters) {
          Connection connection = null;
          try {
              connection = JdbcUtilByDruid.getConnection();
              int rows = queryRunner.update(connection, sql, parameters);
              return rows;
          } catch (SQLException e) {
              throw new RuntimeException(e);
          }finally {
              JdbcUtilByDruid.close(null,null,connection);
          }
  
      }
  	//查询返回多行
      public List<T> queryMulti(String sql，Class clazz, Object... parameters)  {
          Connection connection = null;
          try {
              connection = JdbcUtilByDruid.getConnection();
              return queryRunner.query(connection, sql, new BeanListHandler<T>(clazz), parameters);
          } catch (SQLException e) {
              throw new RuntimeException(e);
          }finally {
              JdbcUtilByDruid.close(null,null,connection);
          }
      }
      //返回单行
      public List<T> querySingle(String sql，Class clazz, Object... parameters)  {
          Connection connection = null;
          try {
              connection = JdbcUtilByDruid.getConnection();
              return queryRunner.query(connection, sql, new BeanHandler<T>(clazz), parameters);
          } catch (SQLException e) {
              throw new RuntimeException(e);
          }finally {
              JdbcUtilByDruid.close(null,null,connection);
          }
      }
      //返回单值
      public Object queryScalar(String sql, Object... parameters)  {
          Connection connection = null;
          try {
              connection = JdbcUtilByDruid.getConnection();
              return queryRunner.query(connection, sql, new ScalarHandler()), parameters);
          } catch (SQLException e) {
              throw new RuntimeException(e);
          }finally {
              JdbcUtilByDruid.close(null,null,connection);
          }
      }
  }
  ```

  

* **XxxDao类**

  例如`AdminDao`类，继承BasicDao类

  ```java
  public class AdminDao extends BasicDao<Admin>{
  
  	//继承所有BasicDao的方法
  	//在此编写自己的特有方法
  
  }
  ```

* **实际开发**

  由上到下。

  **AppView界面层**

  {显示界面}

  **Service业务层**（ActorService，GoodsService... 一张表一个Service）

  {组织sql，并调用XxxDao。因为需要操作好几张表，调用好几个不同的Dao}

  **XxxDao层** （继承于BasciDao）

  {对数据的增删改查。可有特有操作}

  **domain层**

  {对应数据库表的 类}

  **Test测试层**

