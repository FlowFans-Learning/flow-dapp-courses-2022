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
pub fun main() {
  createAndLog(raw: "Hello World")
}
