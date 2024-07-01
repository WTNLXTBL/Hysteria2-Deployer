## singbox-start

### 项目特点
* 一键使用sing-box搭建hysteria2代理

### TODO

> 更方便使用

### 部署

#### 准备工作
前提：你的服务器上必须先安装好sing-box

下载一键启动脚本：
```bash
wget https://raw.githubusercontent.com/WTNLXTBL/singbox-start/main/start.sh
```
或
```bash
curl -L -o start.sh https://raw.githubusercontent.com/WTNLXTBL/singbox-start/main/start.sh
```

添加执行权限
```bash
chmod +x start.sh
```

修改`start.sh`中的环境变量：
|变量名|是否必须|备注|
|-|-|-|
|HY2_PORT|是|Hysteria2 协议监听端口|
|IP|是|服务器IP地址|
|HY2_PASSWORD|是|连接到 Hysteria2 代理时使用的密码|

#### 启动并获取配置

执行
```bash
./start.sh
```
即可启动

等待程序执行完成，会在 Terminal 中直接打印出 Hysteria2 的配置链接。

### 自动启动

打开`crontab`编辑器：
```bash
crontab -e
```
添加以下条目：
```plaintext
@reboot ${HOME}/singbox-start/start.sh
```
完成上述步骤即可实现自动启动
