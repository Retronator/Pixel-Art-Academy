AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.System extends LOI.Adventure.Item
  constructor: (@os) ->
    super arguments...
    
  allowsShortcutsTable: ->
    # Override if the system interferes with displaying the shortcuts table.
    true
  
  dontRender: ->
    # Override if the system will be rendered manually.
    false
