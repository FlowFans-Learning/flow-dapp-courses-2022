# 第一讲 初识 Cadence - Cadence基础与Playground

## Flow 链和它的智能合约语言

Flow 是一个高效、快速、可靠且为数字藏品而生的区块链，在现实产品数字化、藏品化上有着其独到的优势。  
它充分尊重了开发者的开发体验，并提供了大量的工具和资源以帮助开发者流畅地进行 DApp 的开发。

Flow 具有非常创新的技术架构（分离共识和计算的流水线节点设计），可以访问 <https://onflow.org> 查看文档了解更多信息。  
但从应用开发角度来说，我们只需要了解如何与 Flow 区块链交互，因此，我们不会深入研究它的工作原理。

那么现在，我们就从 Flow 的开发环境搭建开始，逐步进入其智能合约语言 Cadence 的世界吧。

## 开发环境和命令行安装

> 官方文档：[安装flow-cli][1]

### Linux/macOS

执行单行命令

```sh
sh -ci "$(curl -fsSL https://storage.googleapis.com/flow-cli/install.sh)"
```

安装完成后，请确保在您的 `$PATH` 环境变量中包含 `flow`。

注意： 如果是 M1 芯片的 mac 只能通过 homebrew 进行安装，该脚本只支持 x86 芯片。

```sh
brew install flow-cli
```

### Windows

同样，按照 [安装flow-cli][1] 文档，确保您的 Windows 版本上有 **PowerShell**。  
搜索并在打开 *"PowerShell"* 后运行下面的命令。

```sh
iex "& { $(irm 'https://storage.googleapis.com/flow-cli/install.ps1') }"
```

### 运行测试

成功安装 `flow-cli` 后，可以尝试运行 version 命令。

```sh
flow version
// Version: v0.28.3
// Commit: ff1f8b186bf26e922ab6abe845849fb9e6e6d729
```

然后让我们执行我们的第一个 `Cadence` 命令。

```sh
flow cadence
```

首先会出现的是命令行提示符。

```
Welcome to Cadence v0.18.0!
Type '.help' for assistance.

1>
```

然后向 `Cadence` 世界问好吧！

```cadence
log("Hello, World!")
```

命令行的回复应该是：

```
"Hello, World!"
()
```

后续我们会使用 **VS Code** 进行开发，值得高兴的是 Flow 团队为 VS Code 制作了一款`Cadence`插件，它支持语法高亮、类型检查等。  
具体参见 [VS Code插件文档][2]，可以在 VS Code 扩展中搜索`Cadence`，或者在本地运行此命令安装它：

```sh
flow cadence install-vscode-extension
```

现在我们已经设置好了开发环境，我们可以更深入地研究`Cadence`，**Flow** 的智能合约编程语言。  

## Cadence 语言

> 官方文档：[Cadence语言][3]

**Cadence** 是一种面向资源的编程语言，您将使用它为 **Flow** 区块链编写智能合约 —— 在区块链上执行的应用程序。

由于`Cadence`是解释型语言，因此我们可以使用 Cadence 语言服务器（一个 REPL shell）开始执行 Cadence 代码，我们之前用它来打印过 `"Hello, World!"`。  
相同的命令也可用于执行整个程序文件，稍后会解释。

```sh
flow cadence [filename]
```

现在我们就从基本语法开始，对 `Cadence` 进行深入得了解吧。

### 基本语法

> 官方文档: <https://docs.onflow.org/cadence/language/values-and-types/>

```cadence
// 单行注释
/* 大块的 /* 嵌套的 */ 注释 */
```

与大多数其他编程语言一样，在命名变量时，可以用大写或小写字母“A-Z、a-z”或下划线“_”开头，后面才也可以包含数字“0-9”。

```cadence
test1234 // 正确
1234test // 错误
(-_-) // 错误
```

分号`;` 是可选的，除非你在同一行中放置了两个或多个声明时，必须用分号分割。

变量与常量

- 变量：用 `var` 声明。可以不初始化。
- 常量：用 `let` 声明。当声明一个变量时，你必须初始化它。

```cadence
// 变量的声明
var bad
var counter = 10
// 变量的赋值
counter = 11
// 常量的声明
let name = "Morgan"
```

`Cadence` 是一门强类型的语言，一切事物都有一个类型，推断得到或显式声明。

```cadence
var isGood: Bool = false
isGood = true
isGood = 42 // 炸!
```

### 基本类型

`Cadence` 有许多有用的基本类型。

#### 整型

```cadence
123
0b1111 // 二进制
0o17 // 八进制的 17
0xff // 十六进制
1_000_000_000 // 便于阅读的 十亿
```

所有这些整数都被推断为`Int`，它们可以表示任意大的有符号整数。  
如果你想更具体的表达，你可以使用`Int8`、`Int16`等。所有`Int`和`UInt`类型都有溢出检查。

```cadence
var tiny: Int8 = 126
tiny = tiny + 1 // 正常
tiny = tiny + 1 // 报错！
```

`Cadence` 不允许为整数分配超出其范围的值, 这可以保护开发者免受代价高昂的程序溢出错误。

同时, 整型还有一些有用的方法。

```cadence
let million = 1_000_000
million.toString() // "1000000"
million.toBigEndianBytes() // [15, 66, 64]
```

#### 定点数

`Cadence` 使用 `Fix64` 和 `UFix64` 来表示小数，但它们本质上是带有缩放因子的整数，其缩放因子为`8`。

```cadence
let fractional: Fix64 = 10.5
```

#### 地址

`Cadence` 中当需要用与账户进行交互时，可以使用“地址”类型引用它们。

```cadence
let myAddress: Address = 0x96462d76b0a776b1
```

#### 字符串

Unicode 字符的不可变集合。

```cadence
let name = "Hello"
```

字符串方法和字段。

```cadence
name.length // 5
name.utf8 // [72, 101, 108, 108, 111]
name.concat(" World") // "Hello World"
name.slice(from: 0, upTo: 1) // "H"
```

#### 可选类型

可以通过在类型后添加`?`表示可选，那么这些字段将可以被设置为`nil`以表示**空值**。

```cadence
var inbox: String? = nil
inbox = "Says hi!"
inbox = nil
```

#### 数组

`Cadence` 数组是可变的，可以有固定或可变的长度。  
数组元素必须是相同的类型`T`或属于`T`的子类型。

```cadence
let days = ["Monday", "Tuesday"]
days
days[0]
days[2]
```

数组类型拥有的方法和字段。

```candence
days.length // 2
days.concat(["Wednesday"]) // ["Monday", "Tuesday", "Wednesday"]
days.contains("Friday") // false
days.append("Wednesday")
days // ["Monday", "Tuesday", "Wednesday"]
days.appendAll(["Thursday", "Friday"])
days.remove(at: 0) // "Monday"
days // ["Tuesday", "Wednesday", "Thursday", "Friday"]
days.insert(at: 0, "Monday")
days // ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
days.removeFirst() // "Monday"
days.removeLast() // "Friday"
```

#### 字典

字典是可变的、无序的键值对集合。  
其键值必须是可散列和可比较大小的，大多数内置类型都符合这些要求。

```cadence
{} // 空字典
let capitals = {"Japan": "Tokyo", "France": "Paris"}
capitals["Japan"] // "Tokyo" of type String?
capitals["England"] = "London"
capitals
```

字典类型拥有的方法和字段。

```cadence
capitals.keys // ["Japan", "France", "England"]
capitals.values // ["Tokyo", "Paris", "London"]
capitals.containsKey("USA") // false
capitals.remove(key: "France") // "London"
```

### 函数与闭包

> 参考文档：[函数说明][3.1]

Cadence 的函数与其他语言中的函数非常相似，尤其是 Swift 语言。它们是值类型，这意味着您可以将它们分配给变量，并将它们作为参数传递给其他函数。

到目前为止，我们一直在使用 `flow cadence` 的 **REPL** 功能。为了学习函数，现在我们将通过向解释器发送程序文件的方式，来执行我们的代码。

```sh
flow cadence test.cdc
```

命令行通过 **REPL** 功能执行与 `.cdc` 文件的唯一区别是：通过文件来执行的方式中，你必须声明一个程序开始执行的入口点。  
您需要通过声明一个名为 `main()` 的函数来实现。

```cadence
pub fun main() {
  log("Hi!")
}
```

`fun` 之前的关键字 `pub` 是一个访问修饰符，它定义了对值的 *public* 访问。我们稍后会讨论它，现在，在声明 `main()` 函数之外的任何内容时，只需使用 `pub`。

```cadence
pub fun sayHi(to name: String) {
  log("Hi, ".concat(name))
}
pub fun main() {
  sayHi(to: "Cadence")
}
```

和具有闭包特性的其他语言一样，闭包可以在函数内定义，并可以读写闭包外部的一些变量。

```cadence
// 注意这个函数返回的结果同样是一个函数定义
fun makeCounter(): ((): Int) {
  var count = 0
  return fun (): Int {
      // 读写 count 变量
      count = count + 1
      return count
  }
}

let test = makeCounter()
test()  // is `1`
test()  // is `2`
```

### 控制循环

> 参考文档：[控制循环][3.2]

#### 条件

`Cadence`的条件语法和其他语言一样，以 `if..else..` 为基础。

```cadence
let a = 0
var b = 0

if a == 1 {
   b = 1
} else {
   b = 2
}
// `b` is `2`
```

值得一提的是在可选类型上，`Cadence`支持可选绑定的`if let`语法结构。

```cadence
let maybeNumber: Int? = 1

if let number = maybeNumber {
    // 因为 maybeNumber 目前有值所以走这条路线，并为 number 常量设置为 1 和 Int 类型
} else {
    // 这条分支将不会被走到，因为 maybeNumber 不是 nil
}
```

在 `switch` 语法的使用上鳄和其他类型的语言是比较类似，最大的不同是不可向下传递，每个 `case` 后必须跟着有效代码。

```cadence
fun words(_ n: Int): [String] {
    // 定义一个保存字符串的数组
    let result: [String] = []

    // 测试参数 n 的值
    switch n {
    case 1:
        // 如果 n 为 1 将 "one" 加入数组
        result.append("one")
    case 2:
        // 如果 n 为 2 将 "two" 加入数组
        result.append("two")
    default:
        // 如果 n 不是 1 或者 2 将 "other" 加入数组
        result.append("other")
    }
    return result
}

words(1)  // 返回 `["one"]`
words(2)  // 返回 `["two"]`
words(3)  // 返回 `["other"]`
words(4)  // 返回 `["other"]`
```

#### 循环

`while` 表述.

```cadence
var a = 0
while a < 5 {
  a = a + 1
}
// `a` is `5`
```

`for..in` 表述，用于常见的数组或者字典结构。

```cadence
let array = ["Hello", "World", "Foo", "Bar"]

for element in array {
  log(element)
}
// "Hello"
// "World"
// "Foo"
// "Bar"
```

循环支持 `continue`, `break` 等常见关键词。

### 组合类型

我们现在有了开始组装更复杂结构的知识基础。在 `Cadence` 中，您有两种复合类型。

1. 结构 `struct` - 值类型（可复制的）
2. 资源 `resource` - 线性类型（可移动的，不可复制的，只能存在一次）

#### 定义声明

声明结构和资源的方式几乎相同，每个都可以有字段、函数和初始化函数。  
每个字段都必须在 `init()` 函数中初始化。

```cadence
// 结构的关键词是 struct
pub struct Rectangle {
  pub let width: Int
  pub let height: Int

  init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }
}

// 资源的关键词是 resource
pub resource Wallet {
  pub var dollars: UInt

  init(dollars: UInt) {
    self.dollars = dollars
  }
}
```

#### 实例化

*结构*像常规类型一样进行初始化。同样的，它和其他常规类型一样，允许垃圾回收器隐式处理释放。

```cadence
let square = Rectangle(width: 10, height: 10)
```

*资源*是不同的，我们使用 `<-` 代替 `=` 来表示我们正在将资源从一个地方移动到另一个地方。  
而且我们**必须**显式使用 `create` 和 `destroy` 来明确标记我们的资源的初始化和释放的过程。**必须**将资源明确分配给位于给定范围之外的变量或字段，否则必须将其销毁。

```cadence
let myWallet <- create Wallet(dollars: 10)
destroy myWallet
```

我们也可以结合函数来进行*资源*的创建，要注意的是`<-`将始终用于资源对象的转移。

```cadence
pub fun createWallet (_ dollars: UInt): @Wallet {
  return <- create Wallet(dollars: dollars)
}

pub fun main() {
  let myWallet <- createWallet(10)
  destroy myWallet
}
```

这里有个注意点，为表示函数返回的类型是一个资源，我们需要在返回类型前增加`@`符号。
更多相关信息，可以查看 [复合类型][3.3] 文档

#### 代码实践

现在我们已经对 `Cadence` 有比较基础的了解，可以开始一定构建 DApp 了。  
首先我们从最基本的结构和功能开始，最终逐步构建成一个完整的应用程序，可以根据你输入的文本创造一个独特的元资产（Meta Asset）NFT。

我们的目标是构建一个有趣的元资产，它需要足够地简单方可被更多的其他NFT进行组合与赋能，那我们就先从最直接的 `bytes` 和可选的 `raw` 开始。  
我们可以创建一个 Cadence 结构来储存我们的元资产数据，目前只需要定义最少的元素。

```cadence
// 元特征定义
pub struct MetaFeature {
  pub let bytes: [UInt8]
  // 可选，原始数据
  pub let raw: String?

  init(bytes: [UInt8], raw: String?) {
    self.bytes = bytes
    self.raw = raw
  }
}
```

现在我们可以实例化一个简单的 MetaFeature 结构

```cadence
pub fun main() {
  let raw = "Hello World"
  let bytes = raw.utf8
  // 创建元特征结构
  let feature = MetaFeature(bytes: bytes, raw: raw)
}
```

现在我们将创建一个具有特定所有权的实体，这个实体必须要附属于某个特定实体，因此现在我们需要使用**资源**类型。  
为此，我们只需要将 `MetaFeature` 结构包装在一个 `Element` 资源中。

```cadence
// 元要素
pub resource Element {
  // 实体中的元要素特征
  pub let feature: MetaFeature
  
  init(feature: MetaFeature) {
    self.feature = feature
  }
}
```

现在，我们可以将这个 `Element` 资源与 `MetaFeature` 一起使用。

```cadence
// 创建资源并打印出来
pub fun createAndLog(raw: String) {
  let bytes = raw.utf8
  // 创建元特征结构
  let feature = MetaFeature(bytes: bytes, raw: raw)
  // 创建实体
  let entity <- create Element(feature: feature)
  log(entity.feature)
  // 必须销毁实体，否则会报错
  destroy entity
}

// 入口函数
pub fun main() {
  createAndLog(raw: "Hello World")
}
```

执行 `flow cadence metaElement.cdc`，我们便可以看到打印出来的结构信息。

## Playground

我们刚才使用 `flow cadence` 进行了第一次 Cadence 的代码实践，它是一个编程语言解释器，也是一个很好的入门方式。  
然而，DApp开发不仅仅是解释并执行代码，它们还需要与区块链的全局状态交互。

**Flow** 为我们提供了很多开发工具和入门的材料。

- 一个代码演练场(Playground)
- 一个独立的本地 Flow 模拟器
- 一个公共的测试网

现在我们将使用 **Playground** 继续完成基础的 `Cadence` 教学，另外两个部分将在下一节课进行介绍。

### 运行环境

启动浏览器并打开 <https://play.onflow.org/>

![代码演练场截图](https://github.com/decentology/fast-floward-1/blob/main/week1/day2/images/playground.jpg?raw=true)

Playground 界面有5个关键部分，让我们来逐一看看每一个。

### Cadence 编辑器

这是您存储 `Cadence` 代码的地方。由于 Playground 模拟了 Flow 区块链，因此 Playground 有一些 Cadence REPL 中不存在的特殊限制。

- 您只能在 **合约** 编辑器中定义 `contract`、`struct` 和 `resource` 类型，您可以通过从左侧窗格中选择任何 **account** 来打开该编辑器。
- 同样的限制适用于 Cadence `事件 event`类型。

准备好部署合约后，点击绿色的 **Deploy** 按钮。重新点击该按钮会再一次部署合约。

Flow Playground 允许您更新现有合约，但是有时更新可能会失败。  
如果您遇到了一些异常问题，请尝试打开一个新的 Playground 并在那里部署您的合约。

![Cadence 编辑器](https://github.com/decentology/fast-floward-1/blob/main/week1/day2/images/editor.jpg?raw=true)

### 账号

在 Flow 中一切都是在**帐户**内存储的，包括智能合约。因此无论做什么都需要访问一个或多个帐户，而 Playground 为我们提供了 5 个自动生成的帐户。

目前 Playground 的一个限制是每个账户只能部署一个合约，当然实际在 Flow 区块链上每个账户内是可以部署多个合约的。

![账户](https://github.com/decentology/fast-floward-1/blob/main/week1/day2/images/accounts.jpg?raw=true)

### 交易

**交易**是定义 Flow 交易的地方。交易通常用于改变区块链的状态，因此需要由涉及的每一个参与方签名。  
与其他区块链一样，Flow 交易必须使用私钥进行加密签名，以对交易数据进行编码。 当然 Playground 对此也进行了抽象，签署交易只需一键即可完成。

![交易](https://github.com/decentology/fast-floward-1/blob/main/week1/day2/images/transactions.jpg?raw=true)

### 脚本

**脚本** 面板是您定义 Flow 脚本的地方，这些脚本是不需要任何区块链改变状态的*只读*代码。  
因此与交易不同，它们不会产生 gas 费用（即使 Playground 没有任何手续费），并且它们不需要任何帐户的签名授权。

![脚本](https://github.com/decentology/fast-floward-1/blob/main/week1/day2/images/scripts.jpg?raw=true)

### 日志和存储

Cadence 为开发人员提供了非常方便的日志功能 - `log()`。您可以记录变量，查看程序执行时状态如何变化，我们已经通过 `flow cadence` 体验到了这一点。  
Playground 也有一个让你看到你的 `log()` 输出的地方。

一旦您开始使用帐户存储数据，您还会在底部窗格中找到帐户的存储信息。

![日志和存储](https://github.com/decentology/fast-floward-1/blob/main/week1/day2/images/logAndStorage.jpg?raw=true)

## Playgound实践

我们就用上面的例子，继续实践一下Playground。

### 合约部署

让我们创建我们的第一个 Cadence 智能合约！

1. 从 **账号(Accounts)** 窗格中选择 `0x01`。
2. 将我们刚才的例子代码，更新到合约代码中去（可以直接复制下面的代码）。

```cadence
pub contract Entity {
  // 元特征
  pub struct MetaFeature {
    // 哈希值
    pub let bytes: [UInt8]
    // 原始数据
    pub let raw: String?

    init(bytes: [UInt8], raw: String?) {
      self.bytes = bytes
      self.raw = raw
    }
  }

  // 元要素
  pub resource Element {
    // 实体中的元要素特征
    pub let feature: MetaFeature
    
    init(feature: MetaFeature) {
      self.feature = feature
    }
  }

  pub fun createAndLog(raw: String) {
    let bytes = raw.utf8
    // 创建元特征结构
    let feature = MetaFeature(bytes: bytes, raw: raw)
    // 创建实体
    let entity <- create Element(feature: feature)
    log(entity.feature)
    // 必须销毁实体，否则会报错
    destroy entity
  }
}
```

3. 点击 **Deploy**
4. 从日志中获取确认信息。

```
11:11:11 Deployment > [1] > Deployed Contract To: 0x01
```

此时在**帐户**窗格中的`0x01`帐户下看到您部署的合约的名称。在这种情况下，名称直接取自源代码，但在 Playground 之外，您可以使用 `name: String` 和合约源代码部署合约。 因此，每个帐户可以在不同名称下拥有同一合约的多个实例。 但如前所述，目前 Playground 帐户每个仅支持一份合约。

现在，我们已经成功部署了一个区块链程序，我们试着完成一次交互吧！

### 脚本查询

现在点击**Script**窗格，让我们编写一些代码。

我们从拥有合约的账户地址**导入**我们想要与之交互的合约，可以将这个视为从包管理器的库中导入类这样的情况。在 Flow 上所有内容都存储在账户之中，其中自然包括所有的合约。

```cadence
import Entity from 0x01

pub fun main() {
  Entity.createAndLog(raw: "Hello World")
}
```

单击 **Execute**，您将在 **Log** 窗格中看到如下的两行。

```
11:11:11 Script > [1] > A.0000000000000001.Entity.MetaFeature(bytes: [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100], raw: "Hello World")
11:11:11 Script > [2] Result > {"type":"Void"}
```

通常使用脚本获取有关公共状态的信息，因此预计它们会“返回”某种值。  
在我们的例子中，我们没有显式返回任何东西，类似于 JavaScript中，当函数返回 undefined 时，在没有显式 return 语句的 Cadence 函数中返回 Void 类型。

到现在为止，我们已经完成了一次将一个简单的合约部署到调用的全部实践！  
在下节课我们会更详细地介绍智能合约、交易事务，现在就尝试一下这些作业和任务吧。

## 课后作业

习题问卷表单将通过我们的社交群组向学员推送。

### 编程题

**注：** 请在表单中提交保存后的 Playground URL。

- `Q1` - 打印输出

在合约中编写一个输出元要素 特征的函数，将 bytes 的每两位作为一个特征代码进行输出。并在 Script 中使用该函数进行输出显示。

```cadence
pub fun display(feature: MetaFeature)
```

```
"Code[0]: 72, 101"
"Code[1]: 108, 108"
"Code[2]: 111, 32"
```

- `Q2` - 唯一特征

创建一个可以生成“特性”信息的资源，但对于每个独特的 `bytes` 只创建一次元素资源。

```cadence
pub resource Generator {
  pub fun generate(feature: MetaFeature): @Element?
}
```

### 问答题

现在你们已经对 Cadence 有了初步的了解。
Cadence 是一门面向资源编程范式的语言，说说你对“面向资源”的理解，简述其特点。

### 挑战题

**注：** 请在表单中提交保存后的 Playground URL。

根据描述，定义资源并编写脚本执行。

定义以下资源：

- `Book`, 带有 `title: String` 字段；
- `Bookshelf`, 带有 `books: @[Book]` 字段（私有）及以下函数：
  - `add(book: @Book)` 向 `books` 末尾添加一本 `Book`；
  - `getBooksCount(): UInt` 返回 `books` 中的元素个数；

编写脚本（Script）执行：

- 创建 2 个 `Book` 实例及 1 个 `Bookshelf` 实例，使得 `Bookshelf` 拥有 2 本 Book

## 参考致谢

本课程部分摘选自 <https://github.com/decentology/fast-floward-1>  
以及其中文翻译 <https://github.com/FlowFans/fast-floward-zh>

[1]: https://docs.onflow.org/flow-cli/install/
[2]: https://docs.onflow.org/vscode-extension/
[3]: https://docs.onflow.org/cadence/language/
[3.1]: https://docs.onflow.org/cadence/language/functions
[3.2]: https://docs.onflow.org/cadence/language/control-flow
[3.3]: https://docs.onflow.org/cadence/language/composite-types/
