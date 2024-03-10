FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.Actions.Action extends FM.Action
  constructor: ->
    super arguments...
    
    @os = @interface.parent
