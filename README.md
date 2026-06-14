# AD_Fastlane | iOS Fastlane CI/CD Tutorial

One-command iOS deployment guide: build, archive, screenshot, XCTest, and submit to App Store / Pgyer using [Fastlane](https://fastlane.tools).

Keywords: fastlane ios, app store upload, ios ci cd, fastlane tutorial, pgyer upload, xcode automation, continuous deployment

## Quick Start

```bash
sudo gem install fastlane
cd your-ios-project && fastlane init
fastlane release   # your configured lane
```

---

## Fastlane 入门实战教程

>有关神器 Fastlane 持续集成\部署的文章网上挺多,本文定位是入门教程,针对 iOS 应用的持续部署,**只需一条命令就可实现从 Xcode 项目到 编译\打包\构建\提交审核**
>
>文章稍微有点长,涵盖内容为:fastlane 简介\安装\配置 + Snapshot 截图 + XCTest + 一键上传App Store
>
>说明:本文将 Apple Dev Center 简称为 ADC; iTunes Connect 简称为 ITC 
>

先放图看 fastlane 实现自动上传功能:

提交进度:

![](https://ooo.0o0.ooo/2017/02/08/589a9ef7823dc.png)

提交成功,等待审核
![](https://ooo.0o0.ooo/2017/02/08/589aaed07d991.png)


## Fastlane 简介

fastlane 是一个完全开源的项目,包含一组 Ruby 实现的工具集,能完成 iOS 和 Android 工程 的自动化构建\测试和发布等功能,[现被Twitter收购,是Fabric的一部分](https://krausefx.com/blog/fastlane-is-now-part-of-fabric).fastlane 强大之处就在于其提供的工具全,基本可以覆盖打包测试发布的所有流程,如下图:

![](https://ooo.0o0.ooo/2017/02/08/589ace59a6210.png)


fastlane 的每一个工具都对应一个 Ruby 脚本,用来执行某一特定的任务,而最妙的是可以通过配置文件将不同的工具灵活的结合在一起,从而形成一个完整的自动化流程,实现一键上传 ITC,从而缩短用于构建发布的时间.


##### 1.主要使用场:

- 提交时执行测试（包括单元测试和集成测试）
- 构建并分发内部测试\公开测试版本
- 构建生产版本并上传至 ITC（包括更新配置文件,创建新的屏幕截图,上传应用并提交审核）
- ...

##### 2.工具集

fastlane 将如下的工具套件有机地结合起来,从管理证书到单元测试,从编译打包到上传发布,都能通过命令行轻松完成.该套件支持与 Jenkins 和 CocoaPods,xctools 等其他第三方工具的集成,并且能够定义多个通道（lanes）以支持不同的部署目标.

- deliver: 将应用在 ITC 上所需数据提交至 ITC (包括:截图,配置文件,ipa包)
- snapshot: 依靠 UI Test 完成截图
- frameit: 快速地把应用截图放入设备框里
- pem: 可以自动化地生成和更新应用推送通知描述文件
- sigh: 创建\更新\下载和修复 provisioning profiles,支持App Store, Ad Hoc, Development和企业profiles
- gym: 编译\打包iOS app,生成签名的ipa文件
- ...

##### 3.常见命令

fastlane 命令中,个人觉得下面两个较为常用:

- 列出所有的 fastlane 的 actions:

```
$ fastlane actions
```

- fastlane action [action_name]: 显示某一个 action 的详细配置

```
$  fastlane action match
```


## fastlane 入门实战


### 1.安装 fastlane

##### 1.1 创建App ID\描述文件

- 本教程目标是上传 ITC ,因此需要提前在 ADC 和 ITC 中创建 App ID\描述文件\App
- 这里使用的项目是 AD Demo,代码见 [GitHub](https://github.com/mythkiven/AD_Fastlane)

![](https://ooo.0o0.ooo/2017/02/06/589845eaa299d.png)
![](https://ooo.0o0.ooo/2017/02/06/589847204b77a.png)

##### 1.2 安装 

查看 Ruby 版本,低于2.0最好升级

``` 
$ ruby -v
```

检查 Xcode CLT 是否安装

``` 
$ xcode-select --install
```

安装 fastlane

``` 
$ sudo gem install -n /usr/local/bin fastlane
```

检查版本 fastlane

``` 
$ fastlane --version
fastlane installation at path:
/Library/Ruby/Gems/2.0.0/gems/fastlane-2.14.2/bin/fastlane
-----------------------------
fastlane 2.14.2
```

OK,安装完成

##### 1.3 为项目配置 fastlane

``` 
$ cd 项目目录
$ fastlane init
```

如果期间报错 `Connection reset by peer - SSL_Connect`,就需要执行:

``` 
$ brew update && brew install ruby
// 重装
$ sudo gem install -n /usr/local/bin fastlane
```

然后重新执行 
```
$ fastlane init
```

- 期间会让你输入 Apple ID 账号密码(这个信息会存在钥匙串中,后续使用无需再输入密码)
- 会检测当前的 app identifier 是否在  ADC 中
- 会检测当前 app 是否在 ITC 中 
- 如果已经在 ADC 和 ITC 中创建相应的信息,那么过程会很顺利,如下图:

![](https://ooo.0o0.ooo/2017/02/07/58992aea708c6.png)

并在 Xcode 项目目录中生成如下文件:

![](https://ooo.0o0.ooo/2017/02/07/58992b1016443.png)

注意:如果没有在 ITC 中创建 App ,也就不会创建上述两个文件夹;当然也可以后续创建,执行如下操作即可:

``` 
$ fastlane produce init
```

### 2.fastlane 文件配置

fastlane 的各文件解释如下:

- Appfile:用于存储应用程序标识符和Apple ID 等信息
- Fastfile:配置管理 lane
- Deliverfile:将应用在 ITC 中的信息,统一配置在一个Deliverfile文件中，详见2.1
- metadata:功能同上也是配置应用在ITC中的信息,只不过是独立文本的形式配置的
- screenshots:包含截图数据

需要注意的是,metadata 和 Deliverfile,都可以配置 ITC 的数据,但后者优先级高.正如下图:

![](https://ooo.0o0.ooo/2017/02/08/589aba7c0b998.png)

![](https://ooo.0o0.ooo/2017/02/08/589aba7c1d252.png)

下文先在 metadata 文件夹中进行配置用于演示,在文末会删除 metadata 中的配置文本,全部配置在 Deliverfile 中.

##### 2.1 配置 metadata 文件夹

修改 App 描述:

``` 
$ cd metadata 
$ cd zh-Hans
$ vim description.txt
```

修改关键字:

``` 
$ vim keywords.txt
```

修改 support_url:

``` 
$ vim support_url.txt
```

修改 copyright:

``` 
$ vim copyright.txt
```

等等,其他信息的修改类似.

然后创建分级文件:itunes_rating_config.json

``` json
{"CARTOON_FANTASY_VIOLENCE": 0,
"REALISTIC_VIOLENCE": 0, 
"PROLONGED_GRAPHIC_SADISTIC_REALISTIC_VIOLENCE": 0,
"PROFANITY_CRUDE_HUMOR": 0,
"MATURE_SUGGESTIVE": 0, 
"HORROR": 2,
"MEDICAL_TREATMENT_INFO": 0,
"ALCOHOL_TOBACCO_DRUGS": 0, 
"GAMBLING": 0, 
"SEXUAL_CONTENT_NUDITY": 0,
"GRAPHIC_SEXUAL_CONTENT_NUDITY": 0, 
"UNRESTRICTED_WEB_ACCESS": 0,
"GAMBLING_CONTESTS": 0
}
```

此处配置参见[官方文档](https://github.com/fastlane/fastlane/blob/master/deliver/Reference.md)

然后将 App 图标添加至文件夹中,接下来要创建证书:

##### 2.2 配置证书

修改 Fastfile:

``` 
$ vim Fastfile
```

修改内容如下:

```
fastlane_version "2.14.2"

default_platform :ios

platform :ios do
 
  # 当前任务的描述
  desc "Creating a code signing certificate and provisioning profile"
  # 任务名称
  lane :provision do
    # 创建 ITC 中的 App 信息
    produce(
      app_name: 'AD_Demo',
      language: 'zh-Hans',
      app_version: '1.0',
      sku: 'com.3code.ADDemo.Test'
    )
    # 使用证书创建私钥及签名
    cert
    # 每次运行时创建新的配置文件
    sigh(force: true)
  end
 
  error do |lane, exception|
  
  end
  
end
```

如果想创建 ad hoc 配置文件,需要指定sigh(adhoc: true).更多的信息参见:

- [官方文档](https://github.com/fastlane/fastlane/tree/master/fastlane/docs)
- [fastlane actions](https://docs.fastlane.tools/actions/)

##### 2.3 将 fastlane 本地配置上传至 ITC 

重新进入项目目录,执行如下操作:

```  
$ fastlane provision
```

等待一小会儿,终端提示成功创建证书配置:

```
fastlane.tools finished successfully 🎉
```

打开 ITC 网页,会发现本地的配置,已经成功上传.

### 3.Xcode 配置

xcode 配置也简单,只需要将项目修改至生产状态即可(描述文件).其它像构建版本号之类的不用理会, fastlane 会处理的. 

### 4.Snapshot 截图和 XCTest 

snapshot 需要和 XCTest 配合使用,关于 XCTest,我的博客中[有一篇文章](www.3code.info/2017/01/23/AD-XCTest/)做了简单介绍.

``` 
$ fastlane snapshot init
```

目录中会生成一个 Snapfile 文件,用于配置截图信息,修改内容如下:

``` 
# 图片尺寸
devices([
  "iPhone 5",
  "iPhone 6",
  "iPhone 6 Plus"
])
 
# 支持语言
languages([
  'zh-Hans'
])
 
# 储存位置
output_directory "./fastlane/screenshots"
 
# 删除之前图片
clear_previous_screenshots true
```

然后打开 Xcode 工程,添加截图设置(需要增加 UI Test, 因为截图是在 UI Test 时截取的):

``` 
\\ 1）在项目添加UI测试,已经添加略过
\\ 2）将./fastlane/SnapshotHelper.swift 添加到UI测试中
\\ 3）打开 AD_DemoUITests.swift ,删除setUp和tearDown方法，然后在其中添加以下代码testExample：
 
  let app = XCUIApplication()
  setupSnapshot(app)
  app.launch()
  
  app.buttons["next"].tap()
  snapshot("01firstPage") // 此处截图
  
  app.buttons["back"].tap()
  snapshot("02secondPage") // 此处截图

```

打开 Fastfile ,并添加如下信息,用于配置截图

```
  desc "Take screenshots"
  lane :screenshot do
    snapshot
  end
```

执行 `$ fastlane screenshot`, fastlane 会自动调用模拟器,执行测试并生成快照,可能会由于模拟器启动慢而导致时间稍微有点长.

成功截图的提示:

![](https://ooo.0o0.ooo/2017/02/07/58995745a83cd.png)

### 5.创建 IPA 文件

打开 fastfile,加入如下代码,配置创建 ipa 

``` 
desc "Create ipa"
  lane :build do
    increment_build_number
    gym
  end
```

保存并执行如下操作,将自动创建 IPA 包

``` 
$ fastlane build
```


如果出现错误: `There does not seem to be a CURRENT_PROJECT_VERSION key set for this project.  Add this key to your target's expert build settings.`
[请查阅此处](https://developer.apple.com/library/content/qa/qa1827/_index.html)

这是一个自动增加构建版本号的设置,需要手动修改.

### 6.上传 IPA 文件到 ITC 

打开 Fastfile ,添加如下代码:

``` 
desc "Upload to App Store"
  lane :upload do
    deliver
  end
```

然后执行命令,上传到 ITC :

``` 
$ fastlane upload
```

期间,会创建一个 html 形式的预览文件,确认没问题输入 y;

当然最有可能的错误就是网络链接的问题: `Please use diagnostic mode to check connectivity. You need to have outbound access to TCP port 443.` 重新配置代理即可.

### 7.配置 Deliverfile

其实上传 ITC 最主要的文件是 Deliverfile,配置好 Deliverfile 后,可以删除 metadata 文件夹中的文本配置.最终配置如下图:

![](https://ooo.0o0.ooo/2017/02/08/589ac0ac8d172.png)

以下是主要的配置,更多更详细的[请戳文件](https://github.com/mythkiven/AD_Fastlane/blob/master/AD_Demo/fastlane/Deliverfile),里面有详细的注释,拿来即可使用

``` 

# 1 app_identifier
app_identifier "com.3code.ADDemo"

# 2 用户名,Apple ID电子邮件地址
username "Apple ID电子邮件地址"  

# 3 支持语言
supportedLanguages = {
  "cmn-Hans" => "zh-Hans"
}

# 4 app 名称
name({
'zh-Hans' => "ADDemo"
})

# 5 描述
description({
  'zh-Hans' => "简体中文版"
})

# 6 提交审核信息
submission_information({    
    export_compliance_encryption_updated: false,
    export_compliance_uses_encryption: false,
    content_rights_contains_third_party_content: false,
    add_id_info_uses_idfa: false
})

# 7 应用审核小组的联系信息 app 审核信息
app_review_information(
  first_name: "name",
  last_name: "name",
  phone_number: "手机号",
  email_address: "email",
  demo_user: "测试账号用户名",
  demo_password: "测试账号密码",
  notes: "noting"
)

# 8 copyright 
copyright "#{Time.now.year} 3code"

# 
```


### 8.提交 AppStore 审核

继续打开 Fastfile,修改如下代码:

``` 
desc "Upload to App Store and submit for review"
  lane :upload do
    deliver(
      submit_for_review: true
    )
  end
```

然后执行命令,提交审核 :

``` 
$ fastlane upload
```


### 9.使用一键命令

添加如下的代码,可以一步搞定所有的操作:

``` 
desc "Provision, take screenshots, build and upload to App Store"
  lane :do_everything do
    provision
    screenshot
    build
    upload
  end
```

对应的命令是:

``` 
$ fastlane do_everything
```

- 代码下载之后是不能直接执行一键上传 ITC ,需要自行在 ADC 配置 App ID\证书\描述文件,ITC 增加 App, 然后方可一键上传 App

- 本文只是简单的介绍了 fastlane 的使用,更多的资料还请参考文末的链接

- 如果你对 ITC 不了解,或者很少发布 App ,建议看看官方文档,要知道发布 App 也有[官方指南哦](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide_SCh/Appendices/Properties.html)

- 本文是系列文章,后续文章会陆续在这里以及我的[博客](http://3code.info)中发布,喜欢请给个✨吧

### 10.参考


- [官网](https://fastlane.tools/)
- [github](https://github.com/fastlane/fastlane)
- [文档](https://docs.fastlane.tools/getting-started/ios/setup/)

最后给点小建议:如果遇到错误首选就是查 issues,你遇到的问题,基本前人都遇到过了.我能在2天里快速入门 fastlane 全靠看 issues 😁😁



