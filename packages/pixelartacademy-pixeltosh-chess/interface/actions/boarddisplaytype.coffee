AE = Artificial.Everywhere
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class BoardDisplayType extends Chess.Interface.Actions.Action
  @boardDisplayType: -> throw new AE.NotImplementedException "Board display type action must provide the display type it activates."
  
  active: -> Chess.state('boardDisplayType') is @constructor.boardDisplayType()
  
  execute: ->
    Chess.state 'boardDisplayType', @constructor.boardDisplayType()

class Chess.Interface.Actions.BoardDisplay2D extends BoardDisplayType
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.BoardDisplay2D'
  @displayName: -> "2D"
  
  @boardDisplayType: -> Chess.BoardDisplayTypes.TwoDimensional
  
  @initialize()

class Chess.Interface.Actions.BoardDisplay3D extends BoardDisplayType
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.BoardDisplay3D'
  @displayName: -> "3D"

  @boardDisplayType: -> Chess.BoardDisplayTypes.ThreeDimensional

  @initialize()

  enabled: -> false
