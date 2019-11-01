AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# The adventure component that is served from pixelart.academy.
class PAA.Adventure extends LOI.Adventure
  @id: -> 'PixelArtAcademy.Adventure'
  @register @id()

  @title: ->
    "Pixel Art Academy // Adventure game for learning how to draw"

  @description: ->
    "Become a pixel art student in the text/point-and-click adventure game by Retronator."

  titleSuffix: -> ' // Pixel Art Academy'

  title: ->
    # On the landing page return the default title.
    return @constructor.title() if LOI.adventureInitialized() and @currentLocation()?.isLandingPage?()

    super arguments...

  template: -> 'LandsOfIllusions.Adventure'

  startingPoint: ->
    locationId: Retropolis.Spaceport.AirportTerminal.Terrace.id()
    timelineId: PAA.TimelineIds.DareToDream

  usesLocalState: -> true
