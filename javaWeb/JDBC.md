[toc]

# java的JDBC编程————以Mysql为例

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

ResultSet对象它被称为结果集，它代表符合SQL语句条件的所有行，并且它通过一套getXXX方法提供了对这些行中数据的访问。

ResultSet里的数据一行一行排列，每行有多个字段，并且有一个记录指针，指针所指的数据行叫做当前数据行，我们只能来操作当前的数据行。 我们如果想要取得某一条记录，就要使用`ResultSet`的`next()`方法 ,如果我们想要得到ResultSet里的所有记录，就应该使用while循环。

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

- **当语句 Connection connection = DriverManager.getConnection(url, user, password) 执行后**，Connection接口类型的变量connection得到的是它的实现类 JDBC4Connection（ConnectionImpl的子类）。[其中实现类是由mysql的jar包提供的
- ResultSet是接口。因为引入了mysql的jar包（该数据库公司提供的），里面实现了该接口。
- **java.sql**：是java公司包，接口为主，不实现。 **com.mysql.jdbc:** 是mysql厂商提供的具体实现。

**成功运行**

![image-20220724144219849](D:\Notes\javaWeb\image\image-20220724144219849-165864647053310.png)

### 4.Statentment对象

Statement对象主要是将SQL语句发送到数据库中。 JDBC API中主要提供了三种Statement对象(Statement,PreparedStatement,CallableStatement)。

![watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAd3d6enp6enp6enp6enp6,size_20,color_FFFFFF,t_70,g_se,x_16](D:\Notes\javaWeb\image\watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAd3d6enp6enp6enp6enp6,size_20,color_FFFFFF,t_70,g_se,x_16.png)

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

使用JDBCUtils实现`DML`操作

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

#### 7.3连接池

