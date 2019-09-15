# Goweb编程

web项目结构:

```
goweb
	controller
		controllerHandler.go	// 处理客户端请求
		controllerResponse.go	// 响应客户端
		domain.go
	html
		index.html
		login.html
		loginSucc.html
		temp.html
	static
		css
			style.css
		js
	main.go
```

##启动web

goweb/main.go

```
package main

import (
	"net/http"
	"fmt"
)

func Hello(w http.ResponseWriter, r *http.Request)  {
	fmt.Fprintf(w, "Hello GoWeb")
}

func main() {
     // 1. 测试goweb
	http.HandleFunc("/", Hello)	//设置访问的路由
	
	err := http.ListenAndServe(":9000", nil) //设置监听的端口
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}
```

在终端窗口进入项目目录中使用  `go build`  构建

在终端窗口中执行生成的文件  `goweb.exe`

使用浏览器访问  `http://localhost:9000`

##访问页面

goweb/main.go

```
package main

import (
	"net/http"
	"fmt"
)

func Hello(w http.ResponseWriter, r *http.Request)  {
	fmt.Fprintf(w, "Hello GoWeb")
}

func TempView(w http.ResponseWriter, r *http.Request)  {
	page := filepath.Join("html", "temp.html")

	result, err := template.ParseFiles(page)
	if err != nil {
		fmt.Println("创建模板实例错误: ", err)
	}

	err = result.Execute(w, nil)
	if err != nil {
		fmt.Println("融合模板数据时发生错误: ", err)
	}
}

func main() {    
    // 1. 测试goweb
	//http.HandleFunc("/", Hello)

	// 2. 指定web根目录
	// 指定当前文件所属目录(goweb)为项目Web根目录
	fs := http.FileServer(http.Dir("./"))
	http.Handle("/", http.StripPrefix("/", fs))
	
	http.HandleFunc("/temp", Hello)
	
	// 3.直接访问指定页面
	http.HandleFunc("/temp.html", TempView)
	
	err := http.ListenAndServe(":9000", nil) //设置监听的端口
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}
```

goweb/html/temp.html

```
<html>
<head>
    <title></title>
</head>
<body>
    <a href="/html/index.html">返回index</a>
</body>
</html>
```

goweb/html/index.html

```
<html>
<head>
    <title></title>
    <link href="/static/css/style.css" rel="stylesheet">
</head>
<body>
    index.html
    <div class="main">
        DIV区块
    </div>
</body>
</html>
```

goweb/static/css/style.css

```
.main{
    font-size: 18px;
    color: silver;
    margin: 20px 10px 20px 50px;
}
```

在终端窗口进入项目目录中使用  `go build`  构建

在终端窗口中执行生成的文件  `goweb.exe`

##访问虚拟路径

goweb/main.go

```
package main

import (
	"net/http"
	"fmt"
	"github.com/goweb/controller"
)

func main() {    
    // 1. 测试goweb
	//http.HandleFunc("/", controller.Hello)

	// 2. 指定web根目录
	// 指定当前文件所属目录(goweb)为项目Web根目录
	fs := http.FileServer(http.Dir("./"))
	http.Handle("/", http.StripPrefix("/", fs))
	
	// 3.直接访问指定页面
	http.HandleFunc("/temp.html", controller.TempView)
	
	// 4. 访问虚拟路径
	http.HandleFunc("/login", controller.Login)
	
	err := http.ListenAndServe(":9000", nil) //设置监听的端口
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}
```

goweb/controller/controllerHandler.go

```
[......]

func Login(w http.ResponseWriter, r *http.Request)  {

	userName := r.FormValue("userName")
	password := r.FormValue("password")
	fmt.Println("userName = ",userName, " password = ", password)

	// 指定页面
	page := filepath.Join("html", "login.html")

	// 创建模板实例
	templateResult, err := template.ParseFiles(page)
	if err != nil {
		fmt.Println("创建模板实例错误: ", err)
	}

	// 融合模板数据
	err = templateResult.Execute(w, nil)
	if err != nil {
		fmt.Println("融合模板数据时发生错误: ", err)
	}

}
```

goweb/html/login.html

```
<html>
<head>
    <title>用户登录</title>
    <link href="/static/css/style.css" rel="stylesheet"/>
</head>
<body>
    <div class="login">
        <form action="/login" method="post">
            用户名:<input type="text" name="userName" value="" placeholder="请输入用户名"/><br/>
            密码: <input type="password" name="password" placeholder="请输入密码"/><br/>
            <div class="btn">
                <span><input type="submit" value="登录"/></span>
                <span><input type="reset" value="重置"/></span>
            </div>
        </form>
    </div>
</body>
</html>
```

重新构建应用并启动

浏览器地址栏中输入以下内容测试:

http://localhost:9000/login?userName=jack&password=1234466

## template模板语法

goweb/html/index.html

```
<html>
<head>
    <title></title>
    <link href="/static/css/style.css" rel="stylesheet">
</head>
<body>
    index.html
    <div class="main">
        DIV区块
    </div>
    <a href="login.html">登录页面</a><br/><br/><!-- 直接转至当前目录下的指定页面, 不会解析template模板语法 -->
    <a href="/login.html">登录页面使用模板语法</a><br/><br/><!-- 通过GoWeb响应转至指定的页面, 解析template模板语法 -->
</body>
</html>
```

goweb/controller/domain.go

```
package controller

type Person struct {
	Pid string
	Name string
	Password string
	Age int
	Gender string
}

var Persons []Person

func init() {
	p := Person{Pid:"111", Name:"jack", Password:"123456", Age:21, Gender:"m"}
	p2 := Person{Pid:"111", Name:"Jerry", Password:"123", Age:23, Gender:"m"}
	p3 := Person{Pid:"111", Name:"alice", Password:"123456", Age:26, Gender:"f"}
	p4 := Person{Pid:"111", Name:"bob", Password:"qazx", Age:29, Gender:"m"}
	p5 := Person{Pid:"111", Name:"candy", Password:"123456", Age:22, Gender:"f"}

	Persons = append(Persons, p)
	Persons = append(Persons, p2)
	Persons = append(Persons, p3)
	Persons = append(Persons, p4)
	Persons = append(Persons, p5)
}
```

goweb/main.go

```
package main

import (
	"net/http"
	"fmt"
	"github.com/goweb/controller"
)



func main() {

	// 1. 测试goweb
	//http.HandleFunc("/", controller.Hello)

	// 2. 指定web根目录
	// 指定当前文件所属目录(goweb)为项目Web根目录
	fs := http.FileServer(http.Dir("./"))
	http.Handle("/", http.StripPrefix("/", fs))

	// 3.直接访问指定页面
	http.HandleFunc("/temp.html", controller.TempView)

	// 4. 访问虚拟路径
	http.HandleFunc("/login", controller.Login)

	// 5. template模板语法
	http.HandleFunc("/login.html", controller.LoginView)

	// 实现向loginSuc.html页面中填充数据, 验证数据正确性

	fmt.Println("启动Web服务, 监听端口号为 9000")
	err := http.ListenAndServe(":9000", nil)
	if err != nil {
		fmt.Println("启动Web服务失败: ", err)
	}
}
```

goweb/controller/controllerResponse.go

```
package controller

import (
	"path/filepath"
	"fmt"
	"net/http"
	"html/template"
)

func response(w http.ResponseWriter, r *http.Request, templateName string, data interface{})  {
	// 指定页面
	page := filepath.Join("html", templateName)

	// 创建模板实例
	templateResult, err := template.ParseFiles(page)
	if err != nil {
		fmt.Println("创建模板实例错误: ", err)
	}

	// 融合模板数据
	err = templateResult.Execute(w, data)
	if err != nil {
		fmt.Println("融合模板数据时发生错误: ", err)
	}
}
```

goweb/controller/controllerHandler.go

```
func Login(w http.ResponseWriter, r *http.Request)  {

	userName := r.FormValue("userName")
	password := r.FormValue("password")
	fmt.Println("userName = ",userName, " password = ", password)

	//  验证数据正确性, 如果正确跳转到成功页面且填充数据
	var templateName string
	if userName == "jack" && password == "123456" {
		data := &struct {
			PersonList []Person
		}{
			PersonList:Persons,
		}
		templateName = "loginSucc.html"
		response(w, r, templateName, data)
	}else {
		data := &struct {
			Flag bool
			Name string
		}{}
		templateName = "login.html"
		// 返回用户输入的用户名及错误信息显示标识
		data.Flag = true
		data.Name = userName
		response(w, r, templateName, data)
	}

	/*// 指定页面
	page := filepath.Join("html", templateName)

	// 创建模板实例
	templateResult, err := template.ParseFiles(page)
	if err != nil {
		fmt.Println("创建模板实例错误: ", err)
	}

	// 融合模板数据
	err = templateResult.Execute(w, nil)
	if err != nil {
		fmt.Println("融合模板数据时发生错误: ", err)
	}*/

}

func LoginView(w http.ResponseWriter, r *http.Request)  {
	response(w, r, "login.html", nil)
}
```

goweb/html/login.html

```
<html>
<head>
    <title>用户登录</title>
    <link href="/static/css/style.css" rel="stylesheet"/>
</head>
<body>
    {{if .Flag}}
        <div class="msg">
            用户名或密码错误, 请重新输入
        </div>
    {{end}}
    <div class="login">
        <form action="/login" method="post">
            用户名:<input type="text" name="userName" value="{{.Name}}" placeholder="请输入用户名"/><br/>
            密码: <input type="password" name="password" placeholder="请输入密码"/><br/>
            <div class="btn">
                <span><input type="submit" value="登录"/></span>
                <span><input type="reset" value="重置"/></span>
            </div>
        </form>
    </div>
</body>
</html>
```

goweb/html/loginSucc.html

```
<html>
<head>
    <title></title>
</head>
<body>
    登录成功页面<br/>
    <table>
        <tr>
            <th>ID</th>
            <th>名称</th>
            <th>密码</th>
            <th>年龄</th>
            <th>性别</th>
        </tr>
    {{range .PersonList}}
        <tr>
            <td>{{.Pid}}</td>
            <td>{{.Name}}</td>
            <td>{{.Password}}</td>
            <td>{{.Age}}</td>
            <td>{{.Gender}}</td>
        </tr>
    {{end}}
    </table>
</body>
</html>
```





