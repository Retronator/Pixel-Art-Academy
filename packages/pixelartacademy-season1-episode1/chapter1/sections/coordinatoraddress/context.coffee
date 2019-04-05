LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.CoordinatorAddress.Context extends LOI.Adventure.Context
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.CoordinatorAddress.Context'

  @initialize()

  # Listener
  
  onCommand: (commandResponse) ->
    # We override the parent implementation (and not call super) 
    # since we don't want the back command to exit the context.
