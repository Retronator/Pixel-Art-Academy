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

      # Get the dummy SYNC until the end of Immersion and the real one afterwards.
      C2.Items.Sync if C2.Immersion.state('syncGiven') and not C2.Immersion.finished()
      LOI.Items.Sync if C2.Immersion.state('syncGiven') and C2.Immersion.finished()

      HQ.Items.OperatorLink if C2.Immersion.Room.scriptState 'SyncSetupProcedure'
      SanFrancisco.Soma.Items.Map if SanFrancisco.Soma.Items.Map.state 'inInventory'
    ]
    
    for itemClassName in ['Account', 'Receipt', 'Keycard']
      hasItem = HQ.Items[itemClassName].state 'inInventory'
      items.push HQ.Items[itemClassName] if hasItem

    items
