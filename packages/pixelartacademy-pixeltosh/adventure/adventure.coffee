AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode
Persistence = Artificial.Mummification.Document.Persistence

class PAA.Pixeltosh.Adventure extends LOI.Adventure
  constructor: ->
    super arguments...
    
    # Set the global instance.
    LOI.adventure = @
    
    # Provides support for autorun and subscribe calls even when component is not created.
    @_autorunHandles = []
    
    @interface =
      listeners: => []
      reset: =>
    
    @_initializeAudio()
    
    @director = new LOI.Director
    
    @_initializeState()
    
    @_initializeMemories()
    
    @_initializeTimeline()
    @_initializeLocation()
    @_initializeContext()
    
    @_initializeActiveItem()
    @_initializeEpisodes()
    @_initializeInventory()
    @_initializeThings()
    @_initializeListeners()
    
    LOI.adventureInitialized true
  
  destroy: ->
    handle.stop() for handle in @_autorunHandles

  usesLocalState: -> true
  
  getLocalSyncedStorage: -> new Persistence.SyncedStorages.LocalStorage storageKey: "Retronator"

  startingPoint: ->
    locationId: LM.Locations.Play.id()
    timelineId: LOI.TimelineIds.RealLife
    
  # A variant of autorun that works even when the component isn't being rendered.
  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle
