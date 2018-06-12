AB = Artificial.Base
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Projects.Snake extends PAA.Practice.Project.Thing
  # READONLY
  # activeProjectId: ID of the project that is currently active
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Projects.Snake'
    
  @fullName: -> "Snake game"

  @initialize()

  # Methods
  
  @start: new AB.Method name: "#{@id()}.start"
  @end: new AB.Method name: "#{@id()}.end"

  constructor: ->
    super

    @assets = new ComputedField =>
      [
        new @constructor.Body @
        new @constructor.Food @
      ]
    ,
      true

  destroy: ->
    @assets.stop()

  # Assets

  class @Body extends PAA.Practice.Project.Asset.Sprite
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Projects.Snake.Body'
      
    @displayName: -> "Snake body"

    @description: -> """
      One unit of the snake body. Each food piece the snake eats will add one of these units to the snake to make it longer.
    """

    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0

    @initialize()

  class @Food extends PAA.Practice.Project.Asset.Sprite
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Projects.Snake.Food'

    @displayName: -> "Food"

    @description: -> """
      A food piece that the snake eats to grow longer.
    """

    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0

    @initialize()
