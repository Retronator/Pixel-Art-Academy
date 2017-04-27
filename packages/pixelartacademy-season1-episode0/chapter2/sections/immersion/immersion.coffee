LOI = LandsOfIllusions
C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ

class C2.Immersion extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2.Immersion'

  @scenes: -> [
    @Basement
    @LandsOfIllusions
    @Room
  ]
    
  @OperatorStates:
    InLandsOfIllusions: 'InLandsOfIllusions'
    InRoom: 'InRoom'
    BackAtCounter: 'BackAtCounter'

  @initialize()

  @userProblemMessage = 'Retronator.HQ.LandsOfIllusions.userProblemMessage'

  active: ->
    @requireFinishedSections C2.Intro

  @finished: ->
    # Immersion section ends when you complete the immersion script. Make sure you don't return undefined.
    @state('completed') is true
