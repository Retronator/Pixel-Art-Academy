LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion extends PAA.Pico8.Cartridge
  # highScore: the top result the player has achieved
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion'
  
  @gameSlug: -> 'invasion'
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
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Body'
    
    @displayName: -> "Invasion body"
    
    @description: -> """
      One unit of the invasion body. Each food piece increases the invaders' strength.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0
    
    @initialize()
  
  class @Food extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Food'
    
    @displayName: -> "Food"
    
    @description: -> """
      A food piece that the invaders collect to grow stronger.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 10
        shade: 0
    
    @initialize()
