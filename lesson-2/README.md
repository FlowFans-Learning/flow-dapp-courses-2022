# 第二讲 初识 Cadence - 账户、交易、模拟器与本地开发

本节课我们将继续补充 Cadence 的重要知识点，学习 Flow 账户存储模型，学习使用**交易**和**脚本**与智能合约进行交互。  
更重要的是，我们将进一步了解 Flow 模拟器、本地配置、本地密钥等，开启 Cadence 项目的工程化进程。

## 账户存储空间与资源保存

> 账户文档：<https://docs.onflow.org/cadence/language/accounts/>

我们先继续完善一下上节课的拓展任务，它是我们了解的第一个智能合约，现在我们将对它进行一定的补充。

```cadence
pub contract Entity {
  // 元特征
  pub struct MetaFeature {

    pub let bytes: [UInt8]
    pub let raw: String?

    init(bytes: [UInt8], raw: String?) {
      self.bytes = bytes
      self.raw = raw
    }
  }

  // 元要素
  pub resource Element {

    pub let feature: MetaFeature
    
    init(feature: MetaFeature) {
      self.feature = feature
    }
  }

  // 特征收集器
  pub resource Generator {

    pub let features: {String: MetaFeature}

    init() {
      self.features = {}
    }

    pub fun generate(feature: MetaFeature): @Element? {
      // 只收集唯一的 bytes
      let hex = String.encodeHex(feature.bytes)

      if self.features.containsKey(hex) == false {
        let element <- create Element(feature: feature)
        self.features[hex] = feature
        return <- element
      } else {
        return nil
      }
    }
  }

  init() {
    // 保存到存储空间
    self.account.save(
      <- create Generator(),
      to: /storage/ElementGenerator
    )
    // 链接到公有空间
    self.account.link<&Generator>(
      /public/ElementGenerator, // 共有空间
      target: /storage/ElementGenerator // 目标路径
    )
  }
}
```

大部分代码你应该很熟悉。我们额外添加了一些新内容。  
所有的代码都包含在 `contract` 的关键字中，在 Flow 里写智能合约时，您不能在 `contract` 关键字之外声明任何内容。  
根据我们上节课的拓展任务，我们实现了 `Generator` 资源和 `generate` 函数，我们使用字典 `features` 来记录特征。同时我们为合约增加了 `init()` 初始化方法，这是为合约设置一些初始化操作的地方。  
接下来我们来深入了解一下账户的存储和访问权限相关的知识点。

### 存储空间

想要在 Flow 区块链上持久化的资源，就必须用一个账户来存储。  
save 函数的作用就是将一个特定的资源，保存到一个唯一的存储位置。

```cadence
fun save<T>(_ value: T, to: StoragePath)
```

在上面的例子中，我们将 `Generator` 资源保存到了 `/storage/ElementGenerator`。

```cadence
// 保存到存储空间
self.account.save(
  <- create Generator(),
  to: /storage/ElementGenerator
)
```

账户中的存储空间存在三个可用的域。

1. storage - 资源和值的实际保存位置，只能通过 `save()` 进行保存。
2. public - 可以通过 `PublicAccount` 访问的作用域。
3. private - 必须通过 `AuthAccount` 方可进行授权访问的作用域。

### 资源链接

Cadence 采用基于能力`Capability`的访问控制，允许智能合约将其部分存储资源公开给其他账户。  
通过调用 `link` 方法，我们创建了一个 `Capability`。

```cadence
fun link<T: &Any>(_ newCapabilityPath: CapabilityPath, target: Path): Capability<T>?
```

我们在上文的例子中，将 `Generator` 放置到了 `/public/ElementGenerator` 位置。

```cadence
// 链接到公有空间
self.account.link<&Generator>(
  /public/ElementGenerator, // 共有空间
  target: /storage/ElementGenerator // 目标路径
)
```

这里我们需要额外说明一下 `&` 符号的用途，它代表的是对某个对象都是引用。

### 资源引用

> 引用文档：<https://docs.onflow.org/cadence/language/references/>

我们可以创建对资源和结构的引用，引用使我们能够访问所引用对象的字段和函数。

如下面的代码例子。

```cadence
let name = "Cadence"
let nameRef: &String = &name as &String
```

或者您可以从账户的链接域中借用它们。

```cadence
let generatorRef = getAccount(0x01)
  .getCapability<&Entity.Generator>(/public/ElementGenerator)
  .borrow()
  ?? panic("Couldn't borrow reference to Generator")
```

## 交易机制

> 交易模型文档： <https://docs.onflow.org/cadence/language/transactions/>

Cadence 的交易不同于其他的智能合约，它同样是一段代码片段。  
现在我们来看一个简单的交易示例。

```cadence
import Hello from 0x01

transaction {

  let name: String

  prepare(account: AuthAccount) {
    self.name = account.address.toString()
  }

  execute {
    log(Hello.sayHi(to: self.name))
  }
}
```

交易体需要包含在 `transaction` 的声明内，可以定义局部变量，同时有几个固定的交易阶段。

### 交易阶段

每个交易都有4个顺序执行的步骤，当然有些是可选的。

```cadence
transaction(parameter: String) {
  let localVariable: Int
  prepare(signer: AuthAccount) {}
  pre {}
  execute {}
  post {}
}
```

如果想要在4个阶段之间共享数据，可以在 `transaction` 主体中声明局部变量，不需要访问修饰符。  
其中 `pre` 和 `post` 阶段，与函数中作用相同，通常语言前置条件和后置条件的检测，在以后会有更多的介绍。  
现在，我们只需要 `prepare` 和 `execute` 阶段。

#### 准备阶段 prepare

`prepare` 准备阶段是能够访问到 `AuthAccount` 实例的唯一阶段，只有在该阶段可以访问到账户存储和其他私有功能。  
在上面的简单例子中，我们只是获取了一下 `address` 字段。

```cadence
prepare(account: AuthAccount) {
  self.name = account.address.toString()
}
```

因为只有这个阶段可以访问 `AuthAccount`，因此要将后续需要使用到的值（例如这里的 `account.address`）保存到临时变量，以供在 `execute` 阶段访问。

#### 执行阶段 execute

需要在这个阶段，执行交易的主要业务逻辑。而且此时也**不能**访问 `AuthAccount` 的私有对象。

在 `execute` 阶段，我们调用 `Hello` 合约的 `sayHi` 函数，使用签名账户地址作为 `name` 参数的值。

```cadence
execute {
  log(Hello.sayHi(to: self.name))
}
```

### 多账户交易 AuthAccount

我们注意到交易的prepare阶段， `AuthAccount` 是以参数的形式传入的。  
实际上，Cadence的交易是原生支持多个 `AuthAccount` 同时进行参与的。

```cadence
prepare(acc1: AuthAccount, acc2: AuthAccount) {
  self.message = acc1.address.toString().concat(" + ").concat(acc2.address.toString())
}
```

### 复杂交易

现在我们使用之前部署的合约 `Entity`，执行一个相对复杂的交易。  
注意：交易中是无法使用 `create` 关键字创建资源的，所有资源必须在合约中生成。

```cadence
import Entity from 0x02

transaction(entityAddress: Address) {

  let message: String
  let element: @Entity.Element?

  prepare(account: AuthAccount) {
    // use get PublicAccount instance by address
    let generatorRef = getAccount(entityAddress)
      .getCapability<&Entity.Generator>(/public/ElementGenerator)
      .borrow()
      ?? panic("Couldn't borrow printer reference.")
    
    self.message = "Hello World"
    let feature = Entity.MetaFeature(
      bytes: self.message.utf8,
      raw: self.message
    )

    // save resource
    self.element <- generatorRef.generate(feature: feature)
  }

  execute {
    if self.element == nil {
      log("Element of feature<".concat(self.message).concat("> already exists!"))
    } else {
      log("Element generated")
    }

    destroy self.element
  }
}
```

> 请注意，目前能使用的 entityAddress 变量，还只有 0x02，也就是目前合约部署的地址。 请思考一下为什么？
> 请思考一下，上面这个 transaction 中的 entityAddress 和 account 分别起到了什么作用？

该交易执行后，会生成一个具有特定特征码的元素，然后会将其销毁。  
如果我们执行该交易两次，将会得到下列日志：

```cadence
11:11:11 New Transaction > [1] > "Element generated!"
11:11:12 New Transaction > [2] > "Element of feature<Hello World> already exists!"
```

我们在 Playground 执行后，可以去账户的 Storage 窗格中查看变更。

## 工程项目初始化和环境配置

我们已经在浏览器中借助 Flow Playground 进行了合约部署、运行脚本、执行交易等操作。  
现在我们将回归 VS Code，在代码编辑器中，工程化得重新实现这些步骤。

### 工程初始化和配置

> 初始化文档：<https://docs.onflow.org/flow-cli/initialize-configuration/>

#### 项目配置

打开终端(terminal)并运行这个命令

```sh
flow init
```

它将会在当前的目录下创建一个配置文件，`flow.json`。  
它主要的目的是将你的本地环境与合约，账户的的别名(aliases)连接起来，以及组织你的合约部署。

#### 全局配置

Flow 也支持使用一个全局配置 `flow.json`，这样你可以将一些通用的配置内容设置在其中，但它相对于本地工程目录下的 `flow.json` 优先级更低。  
生成全局配置只需要添加一个 `--global` 标记。

```sh
flow init --global
```

全局配置文件保存的位置在：

- macOS: `~/flow.json`
- Linux: `~/flow.json`
- Windows: `C:\Users\$USER\flow.json`

### 环境配置

> 配置文档：<https://docs.onflow.org/flow-cli/configuration/>

现在我们一起来看一下 `flow.json` 中的几个部分。

#### networks 网络配置

这里是配置不同 Flow 链环境的节点地址。  
当发布交易或执行脚本时，需要使用 networks 下的环境名称，比如 `emulator` (模拟器), `testnet` (测试网), `mainnet` (主网)。  
**如果不作指定，那么默认是 `emulator` 环境。**

```json
{
  "networks": {
    "emulator": "127.0.0.1:3569",
    "mainnet": "access.mainnet.nodes.onflow.org:9000",
    "testnet": "access.devnet.nodes.onflow.org:9000"
  }
}
```

通常我们会先在模拟器环境中进行开发。

#### accounts 账户配置

在这里你可以给在开发过程中用到的不同的账户起个别名。  
每个 `flow.json` 配置文件的第一部分都是 `emulator-account` (模拟器账户)，或者可以理解成 `service account` (服务账户)。  
你可以添加其他账户用以模拟你的 DApp 中会遇到的各式情况，或者用来部署合约等等。

```json
{
  "accounts": {
    "emulator-account": {
      "address": "f8d6e0586b0a20c7",
      "key": "bcbd7e16179f286eeb805e06482ac45657d1dface4a775511abcaf8e4b6d4373"
    }
  }
}
```

#### contracts 合约配置

在使用 Flow Playground 的时候，已经体会过通过从其他账户地址 `import` 合约来与之交互。  
但是，如果你在Cadence脚本中明确账户地址的话，你将只能将合约部署到有这个地址的环境中。这是因为账户地址在模拟器，测试网，主网的不同环境中是不通用的。

为了解决这个问题，其实只需要在 `*.cdc` 文件中使用从文件引入`import Contract from "path/to/contract.cdc"` 这样的形式。  
之后，如果在 `flow.json` 中已经定义明确的别名，flow-cli 就会在后续过程中接手替换成对应的账户地址。

```json
{
  "contracts": {
    "Hello": "./hello/contract.cdc"
  }
}
```

#### deployments 部署配置

这部分就是对上述那些内容的合并使用了，即明确环境、账户、合约的相互关系。  
以 网络 network > 账户 account > 合约 contract 的方式表示：  
在什么网络环境中，再什么账户地址上，部署哪些个合约。

```json
{
  "deployments": {
    "emulator": {
      "emulator-account": [
        "Hello"
      ]
    }
  }
}
```

## 模拟器、密钥对和账户管理

Flow 模拟器的功能是 `flow-cli` 的一部分，安装后即可使用。

### Flow 模拟器

> 模拟器文档：<https://docs.onflow.org/emulator/>

如何启动一个Flow模拟器？非常简单，只需要一行命令：

```sh
flow emulator start
```

**注意** ： 如果你看到一个系统弹窗要求网络许可，请允许。

你将会看到 4 个 `INFO` 信息, 最后的两条是用来确认 `gRPC` 和 `HTTP` 服务器正常启动, 说明一切正常.  
只要这个进程一直运行，模拟器就也会一直运行。你可以通过使用 `SIGINT` 终端信号停止进程 (macOS的终端是 `CTRL + C`).

默认状态下，模拟器生成的数据将会在模拟器进程关闭后丢失。如果需要持久化的话，你可以通过添加 `--persist` 标记要求模拟器保留数据。

```sh
flow emulator start --persist
```

它会为模拟器创建一个 `flowdb` 文件夹来存储它的状态。当然，你可以随时删除这个 `flowdb` 文件夹进行状态重置。

### 密钥对

> 密钥文档：<https://docs.onflow.org/flow-cli/generate-keys/>

Flow 是账户地址模型而不是公钥地址模型，即地址关联到一个或多个公钥。  
`flow-cli` 提供了一个非常便捷的方法创建公钥，而且可以指定签名算法。下面这个命令设置的是使用 `ECDSA_secp256k1` 算法。

```sh
flow keys generate\
  --sig-algo=ECDSA_secp256k1
```

它将打印并返回一对公钥和私钥。

### Flow 账户

> 账户创建文档：<https://docs.onflow.org/flow-cli/create-accounts/>

创建账户需要在某个指定的环境中进行，如果是模拟器环境的话，需要确保 `flow emulator` 处于进程运行的状态。  
如果不明确指定网络环境 `--network` 的话，默认是使用模拟器环境。  
如果不明确算法 `--sig-algo` 的话，添加的账户公钥默认为 `ECDSA_P256` 。

同时由于Flow账户需要在区块链上进行注册，因此需要一个现有的账号发起一笔交易方可创建。  
因此在模拟器环境中，我们可以使用已经预设生成好的 `emulator-account`。

```sh
flow accounts create \
  --key "$PUBLIC_KEY" \
  --sig-algo "ECDSA_secp256k1" \
  --signer "emulator-account"
```

当上述命令执行成功后，你将得到一个新的账户地址。  
和公钥地址模型的区块链不同的是，该地址是区块链生成的，它可以对应多个不同的公钥，也意味着它也无法从公钥直接推导出来。

```console
Transaction ID: 1234...abcd

Address 0xabcd...0123
Balance 0.00100000
Keys 1
```

同时可以通过下列命令查看刚才的生成的账户信息。

```sh
flow accounts get 0xabcd...0123
```

最后，我们可以更新 `flow.json`，把刚才的新生成的账户添加进来。

```json
{
  "accounts": {
    "the-creator": {
      "address": "abcd...0123",
      "key": {
        "type": "hex",
        "index": 0,
        "signatureAlgorithm": "ECDSA_secp256k1",
        "hashAlgorithm": "SHA3_256",
        "privateKey": "$PRIVATE_KEY"
      }
    }
  }
}
```

## 使用模拟器进行合约开发

现在我们将要使用模拟器，对项目进行工程化的开发。在这部分我们使用 `hello` 文件夹中的简单合约为例子。

### 事件与合约部署

> 事件文档：<https://docs.onflow.org/cadence/language/events/>

现在先来看下我们的合约。

```cadence
pub contract Hello {
  pub event IssuedGreeting(greeting: String)

  pub fun sayHi(to name: String): String {
    let greeting = "Hi, ".concat(name)

    emit IssuedGreeting(greeting: greeting)

    return greeting
  }
}
```

这里要注意下，我们没有使用 `log()` 输出内容，因为这个日志一般只在 Flow Playground 和 Cadence REPL shell 中使用。  
所以我们也将引入事件 `Event` 机制，当与一个合约进行交互时，通过 `Event` 来显示什么时间发生了什么事是非常有帮助的。在模拟器中，交易不会返回值也不会打印日志，所以更加需要事件来确定具体的合约执行情况。

> 部署文档：<https://docs.onflow.org/flow-cli/deploy-project-contracts/>

部署合约时，先需要修改 `flow.json` 来个这个合约起一个名字，并且说明源文件的路径。

```json
{
  "contracts": {
    "Hello": "./hello/contract.cdc"
  }
}
```

然后我们定义合约部署的目标。

```json
{
  "deployments": {
    "emulator": {
      "the-creator": [
        "Hello"
      ]
    }
  }
}
```

然后下一步是部署这个合约。

```sh
flow project deploy
```

一切完成后，我们应该会看到下面这个输出。

```console
Deploying 1 contracts for accounts: the-creator
```

### 脚本查询

现在我们已经将第一个合约部署到了一个账户之中了。现在我们来执行一个简单的脚本。

注意：由于事件 `Event` 是不可以在脚本中执行的，所以需要注释掉 `emit event` 方法。

```cadence
import Hello from "./contract.cdc"

pub fun main(name: String): String {
  return Hello.sayHi(to: name)
}
```

然后我们使用 `flow scripts execute` 子命令运行脚本。

```sh
flow scripts execute hello/sayHi.script.cdc "Cadence"
```

我们也可以使用 `--args-json` 的方式引入多个变量。  
我们可以用`JSON`来编码所有的变量，且必须是一个数组`[]`。

```sh
flow scripts execute hello/sayHi.script.cdc \
  --args-json='[{"type": "String", "value": "Cadence"}]'
```

**注意：**如果你使用的是 `Windows PowerShell` 或者其他非 `Unix` 终端的话，只能使用 `--arg` 来设置变量。

### 交易签名与发送

> 交易文档：<https://docs.onflow.org/concepts/transaction-signing/>

然后来到了最重要的阶段，交易的签名与发送。  

Flow交易将经历这样的流程：

1. 构建：用 `RLP`(Recursive Length Prefix) 编码规则进行交易体编码。
2. 签名：对刚才编码过的交易体，根据交易需要的签名数量进行签名。
3. 发送：将签名结果和交易体发送到Flow节点上。

#### 分步发送

现在，我们命令行一步一步完成范例交易的签名发送过程。

```sh
flow transactions build ./hello/sayHi.transaction.cdc \
  --authorizer the-creator \
  --proposer the-creator \
  --payer the-creator \
  --filter payload \
  --save transaction.build.rlp
```

这里将生成一个 `transaction.build.rlp` 文件，它保存着待签名交易以及需要签名的信息。  
可以注意到，`authorizer`/`proposer`/`payer` 这里都设置为 `the-creator` 时，仅需要使用该账户签名一次。反之则需要根据实际情况进行多次签名。

```sh
flow transactions sign ./transaction.build.rlp \
  --signer the-creator \
  --filter payload \
  --save transaction.signed.rlp \
  -y
```

签名后将生成一个 `transaction.signed.rlp` 文件，此时我们就可以发送到模拟器让其执行。

```sh
flow transactions send-signed ./transaction.signed.rlp
```

如果一切顺利的话，我们应该会在返回中看到之前声明的事件。

#### 简易发送

当然，我们也有相对简易快捷的方式实现交易的发送过程。

```sh
flow transactions send ./hello/sayHi.transaction.cdc \
  --signer the-creator
```

## 课后作业

习题问卷表单将通过我们的社交群组向学员推送。

**注1：** 本次编程题将通过 <https://classroom.github.com/> 进行作业递交

**注2：** 以下所有编程题必须在模拟器中运行。

### 编程题

- Q1 事件添加

修改 `entity.contract.cdc` 合约，添加两个事件，并在合适的地方进行发送。

```text
pub event ElementGenerateSuccess(hex: String)
pub event ElementGenerateFailure(hex: String)
```

- Q2 收藏包

修改 `entity.contract.cdc` 为我们的 `Entity` 合约创建一个 `Collection` 资源，允许保存生成的 `Element` 资源。  
注意：必须在合约中创建资源。

```cadence
// 实现一个新的资源
pub resource Collection {
  pub fun deposit(element: @Element)
}
// 实现一个创建方法
pub fun createCollection(): @Collection
```

新增一个交易 `createCollection.transactions.cdc`，创建 `Collection` 资源并保存到指定的路径。

```cadence
import Entity from "./entity.contract.cdc"

// 为交易的发起者创建一个 Element 收藏包
transaction {}
```

- Q3 收集和展示

修改 `generate.transaction.cdc` 合约，需要实现以下功能：

- 检测交易发起人是否有 `Element` 的 `Collection`，若不存在则创建一个。
- 将生成的 `Element` 保存到交易发起人的收藏包中。
- 若无法生成 `Element`，交易正常结束。

创建 `displayCollection.script.cdc`, 需要实现以下功能：

- 返回特定账户地址收藏包中 `Element` 的列表
- 若没有收藏包，则返回 nil

### 问答题

Cadence中设计Storage的意义是什么？  
相比以太坊 Balance Sheet 的资产管理方式，Cadence的Storage有哪些优势？  
简述一下 `storage`, `private`, `public` 三类存储空间各自的作用。

### 挑战题

根据描述，补充资源定义并编写交易。

补充 `Collection` 资源定义：

- 在 `Collection` 资源中实现 `withdraw` 方法，传入参数 `hex: String`， 返回指定的 `Element`

实现交易：

- 实现 `transfer` 交易，从 A 账户的 `Collection` 中提取 `Element` 转移到 B 账户

## 参考致谢

本课程部分摘选自 <https://github.com/decentology/fast-floward-1>  
以及其中文翻译 <https://github.com/FlowFans/fast-floward-zh>
