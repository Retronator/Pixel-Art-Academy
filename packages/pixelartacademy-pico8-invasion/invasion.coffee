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
  
  class @Defender extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Defender'
    
    @displayName: -> "Defender"
    
    @description: -> """
      Player unit tasked to defend from the incoming invasion. It will shoot projectiles from the top-most pixel you draw.
    """
    
    @fixedDimensions: -> width: 16, height: 16
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    @backgroundColor: ->
      paletteColor:
        ramp: 0
        shade: 0
    
    @initialize()
