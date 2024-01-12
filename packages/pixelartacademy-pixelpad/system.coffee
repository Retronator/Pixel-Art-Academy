AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.System extends LOI.Adventure.Item
  constructor: (@os) ->
    super arguments...
    
  allowsShortcutsTable: ->
    # Override if the system interferes with displaying the shortcuts table.
    true
