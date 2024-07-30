AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @id: -> 'LandsOfIllusions.Adventure'

  @title: ->
    "Lands of Illusions // Alternate Reality World"
    
  @description: ->
    "Imagination is the limit with Retronator's alternate reality system. Try it today!"

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"
    
  @rootUrl: -> '/' # Override to provide a root URL where the adventure should start.
  
  @menuItemsClass: -> LOI.Components.Menu.Items # Override to provide alternative menu items.

  @interfaceClass: -> LOI.Interface.Text # Override to provide an alternative interface.

  titleSuffix: -> ' // Lands of Illusions'

  title: ->
    return @constructor.title() unless LOI.adventureInitialized()

    name = @activeItem()?.fullName() or @currentLocation()?.fullName()

    return @constructor.title() unless name

    "#{_.upperFirst name}#{@titleSuffix()}"

  usesLocalState: ->
    # Override to true to allow logged out users to play (they will store the state in local storage).
    false

  usesServerState: ->
    # Override to false to force logged in users to use the main adventure route.
    true

  startingPoint: ->
    # Override and return {locationId, timelineId} to set a starting point.
    null

  ready: ->
    currentTimelineId = @currentTimelineId()
    currentContext = @currentContext()
    currentLocation = @currentLocation()
    currentRegion = @currentRegion()

    conditions = [
      @interface.ready()
      currentTimelineId
      if currentContext? then currentContext.ready() else true
      if currentLocation? then currentLocation.ready() else false
      if currentRegion? then currentRegion.ready() else false
      if @currentMemoryId() then @currentMemory()? else true
      @thingsReady()
      LOI.palette()
      not @loadingStoredProfile()
    ]

    console.log "Adventure ready?", conditions if LOI.debug

    _.every conditions

  showLoading: ->
    # Show the loading screen when we're not ready, except when other dialogs are already present
    # (for example, the storyline title) and we want to prevent the black blink in that case.
    not @ready() and not @modalDialogs().length

  showDescription: (thing) ->
    @interface.showDescription thing
    
  update: ->
