# 第四讲 实战：上手FCL(Flow Client Library)

从这节课开始，我们已经完成了 `Cadence` 上主要内容的学习，现在我们需要通过实践案例来深入学习 Flow Client Library（FCL）了。

请放心，课程中不需要懂太多 JavaScript 的知识，客户端代码脚手架已经初始化完成。
在课程的学习时我们只需要关心 `Cadence`, `FCL`, `Flow 测试网` 这几个最主要的知识点。

## Flow Client Library - FCL

> FCL 官方文档：<https://docs.onflow.org/fcl/>

上节课中，我们学习了交易的发送，也知道需要使用私钥进行签名，作为开发者我们已经对这套流程非常熟悉了。  
我们开发过程中使用 `flow.json` 文件作为我们的钥匙串，保存着私钥并关联的账户，同时也能够使用 `flow-cli` 进行一系列操作。

但当其他普通用户使用你的 DApp 时，你不可能获得到别人的私钥，这时候我们就需要通过用户钱包的方式来进行交易的签名。  
我们将构建好的交易发送到用户钱包，它们确认交易的内容并由用户选择确认或者拒绝这笔交易。

为了让钱包供应商与应用供应商在Flow生态中能更方便得整合对接，FCL（Flow Client Library）应运而生。

可以参考这篇官方博客文章 [深入Flow: FCL 简洁的力量](https://www.onflow.org/post/inside-flow-the-power-of-simplicity-with-fcl)，这里对 FCL 做了一个非常不错的示例介绍。

## 测试网和部署

我们之前是通过模拟器进行本地实例的交互，今天我们打算使用测试网进行操作。  
部署的过程和部署到模拟器完全相同，唯一需要注意的是，我们不能在没有帐户的情况下创建帐户，因此我们需要使用一下水龙头。

### 测试网水龙头

> 水龙头：[Flow faucet](https://testnet-faucet.onflow.org/)

我们可以在测试网上使用水龙头来创建一个账户。因为我们在上节课中已经学会了使用 `flow keys generate` 创建密钥对，我们可以获取一个全新的密钥对，并前往水龙头创建一个账户，这个过程大概需要几分钟时间。

然后在 `flow.json` 中使用我们刚得到的所有相关信息更新它。

```json
{
  "contracts": {
    "Contract": "./contract.cdc"
  },
  "accounts": {
    "testnet-depolyer": {
      "address": "abcd...0123",
      "key": {
        "type": "hex",
        "index": 0,
        "signatureAlgorithm": "ECDSA_secp256k1",
        "hashAlgorithm": "SHA3_256",
        "privateKey": "$PRIVATE_KEY"
      }
    }
  },
  "deployments": {
    "testnet": {
      "testnet-depolyer": [
        "Contract"
      ]
    }
  }
}
```

### 测试网合约部署

> Flow 账户查询工具：[flow-view-source.com](https://flow-view-source.com/testnet/account/0xda65073324040264) ，需要手动修改地址。

好了，现在开始将合约 `Entity` 部署到测试网。

```sh
flow project deploy --network=testnet
```

部署后，我们可以通过 `flow-view-source.com` 对该账户的进行查询，可以在浏览器中直接看到已经完成部署的合约。

当然，在使用 FCL 之前我们也可以通过 `flow-cli` 对我们部署的合约进行测试。

## 实战课程：CryptoDappy

> CryptoDappy 原版教程参考：
>
> - [Onboarding上手简介](https://www.cryptodappy.com/missions/mission-0)
> - [Mission#1 任务1](https://www.cryptodappy.com/missions/mission-1)
> - [Mission#2 任务2](https://www.cryptodappy.com/missions/mission-2)

本节课开始将主要以实战视频为主。  
将陆续播出第二期 Flow 技术大使制作 CryptoDappy 课程中文版。  

> **视频内使用到的代码模板，可以从作业链接中获取到**

本期实战课程为：

1. CryptoDappy 实战 1 - FCL 入门介绍与授权认证 by Caos
2. CryptoDappy 实战 2 - 通过 FCL 使用 Script 查询链上数据 by Lsy

### 补充说明

这里引入了一个 JS 中对[模板字符串](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Template_literals#%E5%B8%A6%E6%A0%87%E7%AD%BE%E7%9A%84%E6%A8%A1%E6%9D%BF%E5%AD%97%E7%AC%A6%E4%B8%B2)的特殊用法：**用函数解析模板字符串**。  
函数名后直接跟着模版字符串，即代表通过函数对模版字符串以 `function(strings, ...keys)` 的方式进行解析。

在 FCL 中 `fcl.script` 和 `fcl.transaction` 等，即为这样的使用方式。

## 课后作业

习题问卷表单，将通过我们的社交群组向学员推送。

**注：** 本次编程题将通过 <https://classroom.github.com/> 进行作业递交

### 编程题

根据视频内容完成下列操作：

- 添加 fcl 库
- 初始化 fcl 配置
- 添加 fcl 的授权登陆
- 在配置中添加Dappy合约
- 添加 list-dappy-templates 查询脚本
- 执行该脚本的查询，并在页面上进行显示。

### 问答题

请尝试分析对比一下 fcl 的实现和 MetaMask 等插件钱包的优势和劣势。

### 挑战题

修改查询脚本，尝试使用 Scripts 实现一个分页查询的功能和与逻辑。

注：该题可以在作业工程中补充实现。
