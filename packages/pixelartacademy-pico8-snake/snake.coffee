LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class PAA.Pico8.Cartridges.Snake extends PAA.Pico8.Cartridges.Cartridge
  # highScore: the top result the player has achieved
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Snake'
  
  @gameSlug: -> 'snake'
  @projectClass: -> C1.Projects.Snake

  @initialize()

  onInputOutput: (address, value) ->
    # Read score from address 1.
    return unless address is 1 and value?

    highScore = @state('highScore') or 0
    return unless value > highScore

    @state 'highScore', value
