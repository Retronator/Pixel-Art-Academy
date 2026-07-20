AE = Artificial.Everywhere
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class InterfaceTheme extends Chess.Interface.Actions.Action
  @interfaceTheme: -> throw new AE.NotImplementedException "Interface theme action must provide the theme it activates."

  active: ->
    return unless interfaceManager = @chess.interfaceManager()
    interfaceManager.interfaceTheme() is @constructor.interfaceTheme()

  execute: ->
    projectId = Chess.currentProjectId()
    
    PAA.Practice.Project.documents.update projectId,
      $set:
        interfaceTheme: @constructor.interfaceTheme()
        lastEditTime: new Date

class Chess.Interface.Actions.LightInterface extends InterfaceTheme
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.LightInterface'
  @displayName: -> "Light Interface"

  @interfaceTheme: -> Chess.InterfaceThemes.Light

  @initialize()

class Chess.Interface.Actions.DarkInterface extends InterfaceTheme
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.Actions.DarkInterface'
  @displayName: -> "Dark Interface"

  @interfaceTheme: -> Chess.InterfaceThemes.Dark

  @initialize()
