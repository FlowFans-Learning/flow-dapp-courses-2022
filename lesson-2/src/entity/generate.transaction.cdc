import Entity from "./entity.contract.cdc"

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