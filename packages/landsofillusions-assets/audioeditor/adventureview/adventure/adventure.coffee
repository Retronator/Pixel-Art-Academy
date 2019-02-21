AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.AdventureView.Adventure extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.AdventureView.Adventure'
  @register @id()
  
  constructor: (@adventureView) ->
    super arguments...
  
  onCreated: ->
    super arguments...

    @world = new LOI.Engine.World
      adventure: @
      updateMode: LOI.Engine.World.UpdateModes.Hover
      isolatedAudio: true
  
    @interface =
      illustrationSize: new AE.Rectangle 0, 0, 0, 0

    @currentLocationId = new ComputedField =>
      @adventureView.activeFileData()?.get 'locationId'

    @_currentLocation = null
    @currentLocation = new ComputedField =>
      # React to location ID changes.
      currentLocationId = @currentLocationId()

      Tracker.nonreactive =>
        @_currentLocation?.destroy()

        return unless currentLocationClass = LOI.Adventure.Location.getClassForId currentLocationId

        # Create a non-reactive reference so we can refer to it later.
        @_currentLocation = new currentLocationClass

        @_currentLocation

    @currentSituation = =>
      illustration: =>
        @currentLocation()?.illustration()

    @currentLocationThings = => []
