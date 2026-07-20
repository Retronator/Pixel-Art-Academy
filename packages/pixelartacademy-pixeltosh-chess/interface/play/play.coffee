AM = Artificial.Mirage
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.Play extends AM.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Play'
  @register @id()
  
  @PlayerPositions =
    Top: 'top'
    Bottom: 'bottom'

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess

  topPlayerPosition: -> @constructor.PlayerPositions.Top
  bottomPlayerPosition: -> @constructor.PlayerPositions.Bottom
