AE = Artificial.Everywhere
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class BoardDisplayType extends Chess.Interface.Actions.Action
  @boardDisplayType: -> throw new AE.NotImplementedException "Board display type action must provide the display type it activates."
  
  active: -> @chess.interfaceManager()?.boardDisplayType() is @constructor.boardDisplayType()
  
  execute: ->
    @chess.interfaceManager().boardDisplayType @constructor.boardDisplayType()

class Chess.Interface.Actions.BoardDisplay2D extends BoardDisplayType
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.BoardDisplay2D'
  @displayName: -> "2D"
  
  @boardDisplayType: -> Chess.InterfaceManager.BoardDisplayTypes.TwoDimensional
  
  @initialize()

class Chess.Interface.Actions.BoardDisplay3D extends BoardDisplayType
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.BoardDisplay3D'
  @displayName: -> "3D"

  @boardDisplayType: -> Chess.InterfaceManager.BoardDisplayTypes.ThreeDimensional

  @initialize()

  enabled: -> false
