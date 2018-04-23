LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Scenes.Inventory extends LOI.Adventure.Scene
  @id: -> 'Retronator.HQ.Scenes.Inventory'

  @location: -> LOI.Adventure.Inventory

  @initialize()
  
  constructor: ->
    super

    @cart = new ComputedField =>
      # Instantiate new cart for user or character.
      if LOI.character()
        new HQ.Items.ShoppingCart.Character
  
      else
        new HQ.Items.ShoppingCart.User

  things: -> [
    @cart() if HQ.Items.ShoppingCart.state 'inInventory'
  ]
