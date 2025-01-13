## 使用方法
* 方法一 - 交互式输入配置文件

```shell
bash <(curl -sL https://raw.githubusercontent.com/xiaoyaohanyue/ppanel-docker-aio/refs/heads/main/init.sh) -i
```
根据提示输入关键配置内容

* 方法二 - 参数启动
  
```shell
bash <(curl -sL https://raw.githubusercontent.com/xiaoyaohanyue/ppanel-docker-aio/refs/heads/main/init.sh) && \
    bash /opt/dslr/install.sh --admin_email "管理员邮箱" \
    --admin_passwd "管理员密码" \
    --api_domain "服务端域名" \
    --admin_domain "管理端域名" \
    --user_domain "用户端域名" \
    --cloudflare_email "cf邮箱" \
    --cloudflare_token "cf Global token"
```

## BUG
* 目前仅支持Cloudflare解析的域名进行自动SSL申请
  
