LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Snake extends PAA.Pico8.Cartridges.Cartridge
  # highScore: the top result the player has achieved
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake'
  
  @gameSlug: -> 'snake'
  @projectClass: -> @Project

  @initialize()

  onInputOutput: (address, value) ->
    # Read score from address 1.
    return unless address is 1 and value?

    highScore = @state('highScore') or 0
    return unless value > highScore

    @state 'highScore', value
  
  # Assets
  
  class @Body extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake.Body'
    
    @displayName: -> "Snake body"
    
    @description: -> """
      One unit of the snake body. Each food piece the snake eats will add one of these units to the snake to make it longer.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0
    
    @initialize()
  
  class @Food extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake.Food'
    
    @displayName: -> "Food"
    
    @description: -> """
      A food piece that the snake eats to grow longer.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0
    
    @initialize()
