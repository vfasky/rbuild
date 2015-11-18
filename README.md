前端自动化工具 F2E build tool
============================

- 使用 gulp
- 使用 webpack

### 安装

```js
npm install -g node-rbuild
```

### 快速开发

#### init
```
cd [project]
rbuild init
```

#### install vendor packages

```
# 使用 cdnjs 上的 jQuery 
rbuild install jquery@2.1.4 
# 或者下载最新版的 jQuery 到本地目录
rbuild install jquery --download
```

#### watch file auto build
```
rbuild watch
```

#### deploy
```
rbuild watch --config rbuild.deploy.js
```

### 配置文件

`rbuild.config.js` - 开发时使用的配置文件
`rbuild.deploy.js` - 部署时使用的配置文件

