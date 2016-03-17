---
layout: post
title: Nginx 配置 SSL 证书支持 Https
---

确保机器上安装了 openssl 和 openssl-devel

    yum install openssl
    yum install openssl-devel

确保 Nginx 只是 SSL 模块，编译时带 --with-http_ssl_module 参数，否则会报错

    [emerg] 10464#0: unknown directive "ssl" in /usr/local/nginx/conf/nginx.conf:74”

创建服务端私钥（第三方 SSL 证书签发机构都要求起码 2048 位的 RSA 加密的私钥）

    cd /usr/local/nginx/
    mkdir ssl && cd ssl
    openssl genrsa -des3 -out hicrew.key 2048

创建证书请求文件（CSR = SSL Certificate Signing Request）

    openssl req -new -nodes -sha256 -key hicrew.key -out hicrew.csr

依次输入密码、国家代码、省份城市、邮箱等信息即可。

    Country Name (2 letter code) [XX]:CN
    State or Province Name (full name) []:Shanghai
    Locality Name (eg, city) [Default City]:Shanghai
    Organization Name (eg, company) [Default Company Ltd]:Morecruit
    Organizational Unit Name (eg, section) []:RD
    Common Name (eg, your name or your server's hostname) []:api.hicrew.cn
    Email Address []:support@morecruit.cn        

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:hicrew
    An optional company name []:qa.api.hicrew.cn

### 特别注意

Common Name 和 An optional company name 是证书的生效域名。
如果只是同一个站点下面分出很多个子域名，那么可以直接申请通配证书，将证书的 Common Name 填写为 `*.hicrew.cn`，但 这种写法只能匹配二级域名，根域名 `hicrew.cn` 和三级域名 `qa.api.hicrew.cn` 都无法匹配，所以如果有更多的域名，可以填入“使用者可选名称”。参考[《SSL多域名绑定证书的解决方案》](http://codefine.co/2786.html)

去除私钥里的密码信息（否则以SSL启动Nginx时会提示必须输入密钥）

    openssl rsa -in hicrew.key -out hicrew_nopwd.key

使用刚生成的私钥和CSR进行证书签名（10年有效期）

或者到 StartSSL 上传 CSR 后获得经 CA 机构签名后的证书，如：1_study.hicrew.cn_bundle.crt

    openssl x509 -req -days 3650 -sha256 -in hicrew.csr -signkey hicrew_nopwd.key -out hicrew.crt
    
如果需要用 pfx 可以用以下命令生成

    openssl pkcs12 -export -inkey hicrew.key -in hicrew.crt -out hicrew.pfx

修改Nginx配置文件，让其包含新标记的证书和私钥：

    server
    {
        server_name api.hicrew.cn;
        listen 443;
        ssl on;
        ssl_certificate /usr/local/nginx/ssl/hicrew.crt;
        ssl_certificate_key /usr/local/nginx/ssl/hicrew_nopwd.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; 
        ssl_ciphers ALL:!DH:!EXPORT:!RC4:+HIGH:+MEDIUM:-LOW:!aNULL:!eNULL;
    }

Apache 配置为

    SSLProtocol  all -SSLv2 -SSLv3
    SSLCipherSuite ALL:!DH:!EXPORT:!RC4:+HIGH:+MEDIUM:!LOW:!aNULL:!eNULL

另外还可以加入如下代码实现80端口重定向到443

    server
    {
        listen 80;
        server_name api.hicrew.cn;
        rewrite ^(.*) https://$server_name$1 permanent;
    }

重启 nginx 就可以通过以下方式访问了

    https://api.hicrew.cn

## FAQ

问：如何让浏览器信任自己办法的证书，以IE为例：

答：

    IE：控制面板 -> Internet选项 -> 内容 -> 发行者 -> `受信任的根证书颁发机构` -> 导入 -> 选择 hicrew.crt
    Chrome：设置 -> 显示高级设置 -> HTTPS/SSL 管理证书 -> `受信任的根证书颁发机构` -> 导入 -> 选择 hicrew.crt

问：什么是针对企业的 EV SSL

答：EV SSL，是 Extended Validation 的简称，更注重于对企业网站的安全保护以及严格的认证。最明显的区别就是，通常 EV SSL 显示都是绿色的条

=-=====-=====-=====-====
参考文章：

- <https://www.centos.bz/2011/12/nginx-ssl-https-support/>
- <http://blog.weiliang.org/linux/632.html>
- (Nginx 配置 SSL 证书 + 搭建 HTTPS 网站教程)[http://www.open-open.com/lib/view/open1433390156947.html]
