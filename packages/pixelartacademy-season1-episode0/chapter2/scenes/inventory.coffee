LOI = LandsOfIllusions
PAA = PixelArtAcademy
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ

class C2.Inventory extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Inventory'

  @location: -> LOI.Adventure.Inventory

  @initialize()

  things: ->
    items = [
      HQ.Items.Prospectus
      HQ.Items.Sync if C2.Immersion.state 'syncGiven'
      HQ.Items.OperatorLink if C2.Immersion.state('operatorState') is C2.Immersion.OperatorStates.BackAtCounter
      SanFrancisco.Soma.Items.Map if SanFrancisco.Soma.Items.Map.state 'inInventory'
    ]
    
    for itemClassName in ['ShoppingCart', 'Account', 'Receipt', 'Keycard']
      hasItem = HQ.Items[itemClassName].state 'inInventory'
      items.push HQ.Items[itemClassName] if hasItem

    items
