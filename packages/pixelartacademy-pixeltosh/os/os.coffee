AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS extends LOI.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.OS'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      startup: AEc.ValueTypes.Trigger

  onCreated: ->
    super arguments...
    
    @programLocation = new PAA.Pixeltosh.Programs
    
    if LOI.adventure
      # Prepare for loading available programs based on gameplay.
      @currentProgramsSituation = new ComputedField =>
        options =
          timelineId: LOI.adventure.currentTimelineId()
          location: @programLocation
  
        return unless options.timelineId and options.location
  
        new LOI.Adventure.Situation options
  
    # We use caches to avoid reconstruction.
    @_programs = {}

    # Instantiates and returns all programs that are available to listen to commands.
    @currentPrograms = new ComputedField =>
      # When running in the adventure interface, get programs from the situation.
      if LOI.adventure
        return unless currentProgramsSituation = @currentProgramsSituation()

        programClasses = _.clone currentProgramsSituation.things()
        
        # Finder is always available in adventure interface.
        programClasses.push PAA.Pixeltosh.Programs.Finder
        
      else
        # Only load the program referenced by the URL slug.
        programClasses = []

      @getProgram programClass for programClass in programClasses
      
    @loadedPrograms = new ReactiveField []
    
    @activeViewAddress = new ReactiveField null
    @activeProgram = new ReactiveField null, (a, b) => a is b
    
    @display = @callAncestorWith 'display'
    
    @interface = new @constructor.Interface @
    
    @cursor = new ComputedField =>
      @interface.getView PAA.Pixeltosh.OS.Interface.Cursor
      
    if LOI.adventure
      @fileSystem = new @constructor.FileSystem os: @
      
    # Note: We perform the rest of initialization on rendered when the interface is already created.
    
  onRendered: ->
    super arguments...

    # Start in Finder in the adventure interface.
    if LOI.adventure
      @loadProgram @getProgram PAA.Pixeltosh.Programs.Finder
      
    # Reactively load the menu of the active program.
    @autorun (computation) =>
      activeMenuItems = @activeProgram()?.menuItems()

      menuData = @interface.data.child 'layouts.main.windows.0'
      menuData.set 'height', if activeMenuItems then 14 else 0
      menuData.set 'items', activeMenuItems or []
      
  onDestroyed: ->
    super arguments...
    
    @fileSystem?.destroy()
  
  getProgram: (programClassOrId) ->
    [programId, programClass] = _.thingIdAndClass programClassOrId
    Tracker.nonreactive => @_programs[programId] ?= new programClass @
    @_programs[programId]
    
  loadProgram: (program) ->
    Tracker.nonreactive =>
      loadedPrograms = @loadedPrograms()
      loadedPrograms.push program
      @loadedPrograms loadedPrograms
      program.load()
    
  unloadProgram: (program) ->
    Tracker.nonreactive =>
      loadedPrograms = @loadedPrograms()
      loadedPrograms.pull program
      @loadedPrograms loadedPrograms
    
  addWindow: (window) ->
    windows = @interface.currentLayoutData().get 'windows'
    newWindowIndex = windows.length
    newWindowDataAddress = "layouts.main.windows.#{newWindowIndex}"
    
    @interface.addWindow _.extend {}, window,
      order: @_getMaxWindowOrder() + 1
      
    # Activate the view of the window after it is rendered.
    @autorun (computation) =>
      programViews = @allChildComponentsOfType PAA.Pixeltosh.Program.View
      
      windowView = _.find programViews, (programView) =>
        programView.data().options.address is newWindowDataAddress
      
      return unless windowView
      computation.stop()
      
      @activateView windowView
      
  activateView: (view) ->
    @activeProgram view.program()
    
    viewData = view.data()
    return if @activeViewAddress() is viewData.options.address
    @activeViewAddress viewData.options.address
    
    if viewData.get('activateBringsWindowToTop') ? true
      addressParts = view.data().options.address.split '.'
      windowIndex = addressParts[3]
      @interface.currentLayoutData().set "windows.#{windowIndex}.order", @_getMaxWindowOrder() + 1
  
  removeView: (view) ->
    viewData = view.data()
    addressParts = view.data().options.address.split '.'
    windowIndex = addressParts[3]
    
    @interface.removeWindow windowIndex
  
  isViewActive: (view) ->
    viewData = view.data()
    viewData.options.address is @activeViewAddress()
  
  _getMaxWindowOrder: ->
    windows = @interface.currentLayoutData().get 'windows'
    normalWindows = _.filter windows, (window) => not window.alwaysOnTop
    sortedWindows = _.sortBy normalWindows, 'order'
    _.last(sortedWindows)?.order or 0

  menuVisibleClass: ->
    'menu-visible' if @activeMenuItems()
    
  events: ->
    super(arguments...).concat
      'pointermove .pixelartacademy-pixeltosh-os': @onPointerMovePixeltoshOS
      'pointerleave .pixelartacademy-pixeltosh-os': @onPointerLeavePixeltoshOS
  
  onPointerMovePixeltoshOS: (event) ->
    @cursor().updateCoordinates event
    
  onPointerLeavePixeltoshOS: (event) ->
    @cursor().resetCoordinates()
