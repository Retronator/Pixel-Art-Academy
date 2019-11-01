LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.CoordinatorAddress extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.CoordinatorAddress'

  @scenes: -> [
    @MeetingSpace
  ]

  @initialize()

  @started: ->
    # Coordinator gives an address after the mixer.
    @requireFinishedSections C1.Mixer

  @finished: ->
    # Section is over when the address script is finished.
    C1.CoordinatorAddress.MeetingSpace.scriptState('MeetingEnd') is true
