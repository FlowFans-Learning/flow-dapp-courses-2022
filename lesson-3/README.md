# 第三讲 初识 Cadence - Cadence 开发最佳实践

本节课上，我们将继续深入学习 Cadence 的语法，并学习 Cadence 中的一些最佳实践。  
除此之外，我们也将学习的 `Flow FT` 和 `Flow NFT` 的标准协议，以及最新 `NFT Metadata` 标准。

## 接口与 Capability 访问控制的实践

> 官方文档：
>
> - [基于capability的访问控制](https://docs.onflow.org/cadence/language/capability-based-access-control/)
> - [Interface接口文档](https://docs.onflow.org/cadence/language/interfaces/)

在上节课中，我们已经了解到了 `Capability` 机制和账户的 `link` 方法，例如：

```cadence
// 链接到公有空间
self.account.link<&Generator>(
  /public/ElementGenerator, // 共有空间
  target: /storage/ElementGenerator // 目标路径
)
```

当然，由于 `generator` 的方法是所有人都可以调用的，这样的写法无可厚非。  
但我们再看一下我们上节课作业中实现的 `Collection` 资源类。

```cadence
pub resource Collection {
  pub let elements: @[Element]

  pub fun deposit(element: @Element) {
    let hex = String.encodeHex(element.feature.bytes)
    self.elements.append(<- element)
    emit ElementDeposit(hex: hex)
  }

  pub fun withdraw(hex: String): @Element? {
    var index = 0
    while index < self.elements.length {
      let currentHex = String.encodeHex(self.elements[index].feature.bytes)
      if currentHex == hex {
        return <- self.elements.remove(at: index)
      }
      index = index + 1
    }

    return nil
  }

  pub fun getFeatures(): [MetaFeature] {
    var features: [MetaFeature] = []
    var index = 0
    while index < self.elements.length {
      features.append(
        self.elements[index].feature
      )
      index = index + 1
    }
    return features;
  }

  init() {
    self.elements <- []
  }

  destroy() {
    destroy self.elements
  }
}
```

在这里我们同样使用了 `link` 的方法公开了 `Capability`。

```cadence
self.account.link<&Collection>(
  /public/LocalEntityCollection,
  target: /storage/LocalEntityCollection
)
```

但如果这样写的话，会带来一个问题：所有人都可以通过调用 `withdraw` 方法，将 `Element` 从 `Collection` 中提取出来。  
所以我们就必须使用到 Capability 提供的一个功能：通过链接接口 `interface` 的方式自由选择开放哪些功能。

首先我们创建一个定义了一组字段和函数的资源接口（接口分为资源接口、结构接口和合约接口），然后修改我们的资源并实现接口。

```cadence
pub resource interface Receiver {
  pub fun deposit(element: @Element)
  pub fun getFeatures(): [MetaFeature]
}

pub resource Collection: Receiver {
  // ...
  pub fun deposit(element: @Element) { /* ... */ }
  pub fun getFeatures(): [MetaFeature] { /* ... */ }
  // ...
}
```

完成这个之后，我们就可以通过接口的方式（注意写法上的区别）创建我们的公共 `Capability` 并安全地使用 `Receiver` 的接口功能了。

```cadence
self.account.link<&{Receiver}>(
  /public/LocalEntityReceiver,
  target: /storage/LocalEntityCollection
)
```

现在获取到 `/public/LocalEntityReceiver` 的 `Capability` 后，就只能对 `deposit()` 和 `getFeatures()` 方法进行访问。从而我们就可以确保只有该账户的所有者才能从 Collection 中提取 element 了。

## 方法中的前置和后置条件

> 官方文档：
>
> - [接口中的前后置条件](https://docs.onflow.org/cadence/language/interfaces)
> - [方法中的前后置条件](https://docs.onflow.org/cadence/language/functions/#function-preconditions-and-postconditions)
> - [交易中的前后置条件](https://docs.onflow.org/cadence/language/transactions/#pre-phase)

`Cadence` 在语法层面上是不支持继承的，接口是描述复合数据结构功能的唯一手段。而接口也提供了通用性的实现内容，那就是前置后和后置条件。  
例如我们可以在 `Receiver` 的接口定义中设置 `feature.raw` 必须不为 `nil`。

```cadence
pub resource interface Receiver {
  pub fun deposit(element: @Element) {
    pre {
      element.feature.raw != nil:
        "RawData should not be nil"
    }
  }

  pub fun getFeatures(): [MetaFeature]
}
```

需要注意的是，interface 是不能包含实现代码的，因此只能包含 `pre` 和 `post` 的代码块，用于实现代码执行前和执行后的 assert 判断。  
代码块中格式为 `expression : "panic message"`（前者为验证为 `true` 的表达式，后者为报错信息）。  
当表达式的结果为 `false` 时，代码的执行将中断并以 `panic` 的形式输出报错信息。

当然除了在接口中，普通方法中、交易中都有可以设置前置和后置条件。

```cadence
// 交易脚本中的前后置条件
transaction {
    prepare(signer: AuthAccount) { /** 准备阶段 */ }

    pre { /** 前置条件，语法相同 */ }

    execute { /**  执行阶段 */ }

    post { /** 后置条件，语法相同 */ }
}
```

可以通过前后置条件的实现，在执行前后对参数进行更多更详细的判断和验证。

## 可升级合约的最佳实践

> 官方文档： [合约的可升级规范](https://docs.onflow.org/cadence/language/contract-updatability/)

`Cadence` 合约是可以进行更新代码的，但在更新时为了确保不会导致已存储的数据和运行时产生冲突，在更新中会有一系列的检查验证。  
验证会遵循一些规则，否则会更新失败。

- 更新验证可以确保
  - 更新合约时，存储的数据不会更改其含义。
  - 解码和使用存储的数据不会导致运行时崩溃。
- 但不能确保的事也是有的
  - 不能确保 `import` 合约的代码程序都能继续生效。

为了确保你的合约代码能在以后可以进行正常的更新，在初期设计时需要遵循一些规则。  
更详细的说明可以查看官方文档，这里主要列举一些最常见的规范：  

- 合约
  - 可以添加新合约/合约接口
  - 可以删除不含Enum定义的合约/合约接口，反之不可以。
- 字段（归属于合约、结构、资源、接口的任意字段）
  - 移除一个字段是**合法**的，现有存储数据中若存在这个字段的数据仅仅是无用而已，不会造成运行时崩溃。
  - 新增一个字段是**不合法**的，因为其一 `init` 函数只会运行一次无法进行再次初始化，其二是原存储数据不包含新字段，在解码时会造成运行时崩溃。
  - 修改权限修饰符(access modifier)是**合法**的。
  - 修改字段类型是**不合法**的。
- 结构、资源、接口
  - 新增结构、资源、接口的定义是**合法**的
  - 为结构、资源任意更换实现的接口是**合法**的，因为存储数据只保存实际的类型和值。
  - 删除或重命名一个现有的定义是**不合法**的，因为已经被存储数据使用了。
- 枚举类型
  - 添加新的枚举定义是**合法**的，而且必须加在最后，插入同样不合法。
  - 删改老的枚举定义是**不合法**的。
- 函数方法
  - 任意修改都是**合法**的，因为他们没有保存在存储数据中。
- Imports 导入合约
  - 这里需要注意，`Cadence` 只在开发时有代码检查。若被导入的合约有所更新，需要自行修改。

## 补充资料：Flow FT 和 Flow NFT标准

> 官方文档和工程：
>
> - Flow FT [合约信息](https://docs.onflow.org/core-contracts/fungible-token/) <https://github.com/onflow/flow-ft>
> - Flow NFT [合约信息](https://docs.onflow.org/core-contracts/non-fungible-token/) <https://github.com/onflow/flow-nft>

首先 Flow FT 和 Flow NFT 都有官方定义的接口在公链上，发行自己的 FT 或者 NFT 都必须实现相对应的接口。  
然后我们主要说一下他们与其他公链的最大区别。

Flow 的 Fungible Token 本质上依然是一个 Resource 资源。

```cadence
// Flow FT
pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {
  /// The total balance of this vault
  pub var balance: UFix64

  // initialize the balance at resource creation time
  init(balance: UFix64) {
      self.balance = balance
  }

  /// withdraw
  ///
  pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
      self.balance = self.balance - amount
      emit TokensWithdrawn(amount: amount, from: self.owner?.address)
      return <-create Vault(balance: amount)
  }

  /// deposit
  ///
  pub fun deposit(from: @FungibleToken.Vault) {
      let vault <- from as! @ExampleToken.Vault
      self.balance = self.balance + vault.balance
      emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
      vault.balance = 0.0
      destroy vault
  }

  destroy() {
      ExampleToken.totalSupply = ExampleToken.totalSupply - self.balance
  }
}
```

因此我们会发现他需要有一个空的 Vault，才能进行充值。

```cadence
// Flow FT
pub fun createEmptyVault(): @Vault {
    return <-create Vault(balance: 0.0)
}
```

同样的，在NFT上我们也存在 Collection 的机制，需要有一个空的 Collection，才能放入该类型的NFT。

```cadence
// Flow NFT
// public function that anyone can call to create a new empty collection
pub fun createEmptyCollection(): @NonFungibleToken.Collection {
    return <- create Collection()
}
```

因此我们在对 FT 以及 NFT 进行操作时，首先要保证的是在账户信息中已经存在相对应的资源对象。

此外更多细节，可以查看我们的官方文档。

## 补充资料：NFT Metadata标准的实现

> 官方文档：[NFT Metadata合约](https://docs.onflow.org/core-contracts/nft-metadata/)  
> FLIP提案：[NFT Metadata标准](https://github.com/onflow/flow/blob/master/flips/20210916-nft-metadata.md)

在 Flow NFT 的接口合约中，已经更新了 Flow 最新的 Metadata 实现标准。  
其核心理念即：通过强类型的方式更加结构化语义化，代码中获取元数据的信息。

抽象层上最为重要的是两个接口：

```cadence
// A Resolver provides access to a set of metadata views.
//
// A struct or resource (e.g. an NFT) can implement this interface
// to provide access to the views that it supports.
//
pub resource interface Resolver {
    pub fun getViews(): [Type]
    pub fun resolveView(_ view: Type): AnyStruct?
}

// A ResolverCollection is a group of view resolvers index by ID.
//
pub resource interface ResolverCollection {
    pub fun borrowViewResolver(id: UInt64): &{Resolver}
    pub fun getIDs(): [UInt64]
}
```

其中 `Resolver` 接口由 NFT 资源实现，而 `ResolverCollection` 接口由 Collection 资源实现。
`ResolverCollection` 很好理解，是获取到某个 NFT 的 `Resolver`，重点在于 `Resolver` 要实现的目的：

- `getViews` 获取到该 NFT 支持的 metadata 显示格式（或者说类型）。
- `resolveView` 则需要传入指定的类型，获取这个 NFT 的实际 metadata。

这样的设计好处在于，不仅以结构化的方式返回了 metadata 的信息，同时一个 NFT 还能兼容多种 metadata 的呈现方式。

更多细节可以参考，Flow 技术大使 Caos 为此专门写的文章：[Cadence NFT 新标准 MetadataViews 介绍](https://caos.me/cadence-nft-metadataviews)

## 课后作业

习题问卷表单将通过我们的社交群组向学员推送。

**注：** 本次编程题将通过 <https://classroom.github.com/> 进行作业递交

### 编程题

- Q: 使用标准 NFT 接口实现改造 entity

修改 `contracts/Entity.cdc` 合约，使 `Entity` 兼容并实现 Flow 标准 `NonFungibleToken` 接口。  
即 `Element` 实现为标准 NFT，`Collection` 实现为标准 NFT Collection。  
注：原 `withdraw` 方法可修改为 `withdrawByHex`

### 问答题

Playground 中有个 Marketplace <https://play.onflow.org/45ae690e-c527-409c-970e-57f03df92790>  
请问这个 Marketplace 能够服务于任何种类的NFT吗？同时尝试梳理并解答一下通用型 Marketplace 的工作流程。

### 挑战题

继续改造 `Entity` ：

1. 实现 `MetadataViews` 的 `Resolver` `ResolverCollection` 等相关接口。
2. 实现诸如 NFT 铸造、转移、销毁等交易脚本。
