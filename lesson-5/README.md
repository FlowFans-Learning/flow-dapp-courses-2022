# 第五讲 实战：使用FCL进行链上交互

这节课我们讲继续通过实战案例来学习 Flow Client Library（FCL）。

## 回顾与补充

> FCL 官方文档：<https://docs.onflow.org/fcl/>

上节课我们通过 CryptoDappy 的实战课程完成了 FCL 的基础使用。  
由于主要是基于测试网环境，这里补充一下模拟器环境的初始化方法，当然具体依然可以在官方文档中找到。

### 如何用 FCL 完成模拟器环境的登录授权

> 【参考】模拟器开发钱包：<https://github.com/onflow/fcl-dev-wallet>

如果使用模拟器环境的话，配置部分需要修改为：

```ts
import * as fcl from "@onflow/fcl"

fcl.config()
  .put("accessNode.api", "http://localhost:8080") 
  .put("discovery.wallet", "http://localhost:8701/fcl/authn") 
```

关于模拟器环境开发钱包的使用，可以参考 `fcl-dev-wallet` 的相关文档。

## 实战课程：CryptoDappy

> CryptoDappy 原版教程参考：
>
> - [Mission#3 任务3](https://www.cryptodappy.com/missions/mission-3)
> - [Mission#4 任务4](https://www.cryptodappy.com/missions/mission-4)

本节课继续播出由第二期 Flow 技术大使制作 CryptoDappy 课程中文版。

> **视频内使用到的代码模板，可以从作业链接中获取到**

本期实战课程为：

1. CryptoDappy 实战 3 - 使用 Transactions 与智能合约进行交互 by WhiteMatrix
2. CryptoDappy 实战 4 - 将 FUSD 运用到 Dappy 的支付当中 by Fou

### 如何获取测试网上的测试币

视频中有介绍如何获取测试币，这里放上需要的链接地址：

**获取 $FLOW** - <https://testnet-faucet.onflow.org/>  
**获取 $FUSD** - <https://swap-testnet.blocto.app/>

## 课后作业

习题问卷表单将通过我们的社交群组向学员推送。

**注：** 本次编程题将通过 <https://classroom.github.com/> 进行作业递交

### 问答题

请描述 fcl 与钱包服务之间的通信与签名授权的流程和步骤。

### 编程题

根据视频内容完成下列操作：

- 添加 create-collection 的交易代码
- 添加 delete-colleciton 的交易代码
- 添加 check-collection 的查询脚本
- 修改 hooks/use-collection.hook.js 实现collection的基础操作
- 在配置中添加 FUSD 和 FungibleToken 合约
- 添加 create-fusd-vault 的交易代码
- 添加 get-fusd-balance 的查询脚本
- 修改 hooks/use-fusd.hook.js 实现fusd
- 修改 providers/UserProvider.js 完成所有操作

### 挑战题

在截止日期前完成本节课的编程题即可。
