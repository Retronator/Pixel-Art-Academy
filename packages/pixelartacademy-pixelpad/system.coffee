AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.System extends LOI.Adventure.Item
  constructor: (@os) ->
    super arguments...
    
  allowsShortcutsTable: ->
    # Override to display shortcuts table in the app.
    false
