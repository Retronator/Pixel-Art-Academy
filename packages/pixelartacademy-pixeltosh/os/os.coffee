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
      return unless currentProgramsSituation = @currentProgramsSituation()

      programClasses = _.clone currentProgramsSituation.things()
      
      # Finder is always available.
      programClasses.push PAA.Pixeltosh.Programs.Finder

      @getProgram programClass for programClass in programClasses
      
    @loadedPrograms = new ReactiveField []
    
    @autorun (computation) =>
      for program in @loadedPrograms()
        continue unless shortcuts = program.shortcuts()
        @interface.data.child('shortcuts').set _.snakeCase(program.id()),
          name: program.fullName()
          mapping: shortcuts
    
    @activeWindowId = new ReactiveField null
    @activeProgram = new ReactiveField null, (a, b) => a is b
    
    @display = @callAncestorWith 'display'
    
    @interface = new @constructor.Interface @
    
    @cursor = new ComputedField =>
      @interface.getView PAA.Pixeltosh.OS.Interface.Cursor
      
    @fileSystem = new @constructor.FileSystem os: @
    
    # Note: We perform the rest of initialization on rendered when the interface is already created.
    
  onRendered: ->
    super arguments...

    # Load the starting program.
    programSlug = AB.Router.getParameter('programSlug') or AB.Router.getParameter('parameter3') or PAA.Pixeltosh.Programs.Finder.slug()
    
    if programClass = PAA.Pixeltosh.Program.getClassForSlug programSlug
      @loadProgram @getProgram programClass
      
    # Reactively load the menu of the active program.
    @autorun (computation) =>
      activeMenuItems = @activeProgram()?.menuItems()

      menuData = @interface.data.child "layouts.main.windows.#{@constructor.Interface.menuId}"
      menuData.set 'height', if activeMenuItems then 14 else 0
      menuData.set 'items', activeMenuItems or []
      
  onDestroyed: ->
    super arguments...
    
    program.unload() for program in @loadedPrograms()
    program.destroy() for programId, program of @_programs
    
    @fileSystem?.destroy()
  
  getProgram: (programClassOrId) ->
    [programId, programClass] = _.thingIdAndClass programClassOrId
    Tracker.nonreactive => @_programs[programId] ?= new programClass @
    @_programs[programId]
    
  loadProgram: (program, file) ->
    Tracker.nonreactive =>
      loadedPrograms = @loadedPrograms()
      loadedPrograms.push program
      @loadedPrograms loadedPrograms

      program.load file
      @activateProgram program
    
  unloadProgram: (program) ->
    Tracker.nonreactive =>
      loadedPrograms = @loadedPrograms()
      _.pull loadedPrograms, program
      @loadedPrograms loadedPrograms

      if @activeProgram() is program and loadedPrograms.length
        @activateProgram _.last loadedPrograms
      
      # Remove all the windows that belonged to this program.
      programId = program.id()
      windows = @interface.currentLayoutData().get 'windows'
      @removeWindow windowId for windowId, window of windows when window.programId is programId
      
      program.unload()
  
  activateProgram: (program) ->
    @activeProgram program
    
    @interface.currentShortcutsMappingId _.snakeCase program.id()
  
  addWindow: (windowData) ->
    windowId = @interface.addWindow _.extend {}, windowData,
      order: @_getMaxWindowOrder() + 1
    
    @activateWindow windowId
    
    # Return the window ID.
    windowId
    
  removeWindow: (windowId) ->
    @interface.removeWindow windowId
    
    @activeWindowId null if @activeWindowId() is windowId
    
  activateWindow: (windowId) ->
    @activeWindowId windowId
    
    # Activating a window also activates its program.
    programView = await @getProgramViewForWindowIdAsync windowId
    
    # Make sure the data of this view is still there (or the program will be empty).
    @activateProgram program if program = programView.program()
    
    # See if we should also bring the window to top.
    @bringWindowToTop windowId if programView.activateBringsWindowToTop()
  
  bringWindowToTop: (windowId) ->
    @interface.currentLayoutData().set "windows.#{windowId}.order", @_getMaxWindowOrder() + 1
    
  getProgramViewForWindowId: (windowId) ->
    return unless window = @interface.getWindow windowId
    window.childComponentsOfType(PAA.Pixeltosh.Program.View)[0]
    
  getProgramViewForWindowIdAsync: (windowId) ->
    new Promise (resolve) =>
      Tracker.autorun (computation) =>
        return unless programView = @getProgramViewForWindowId windowId
        computation.stop()
        resolve programView
  
  _getMaxWindowOrder: ->
    windows = @interface.currentLayoutData().get 'windows'
    normalWindows = _.filter _.values(windows), (window) => not window.alwaysOnTop
    sortedWindows = _.sortBy normalWindows, 'order'
    _.last(sortedWindows)?.order or 0

  onBackButton: ->
    # Relay to the active program.
    return unless activeProgram = @activeProgram()
    return result if result = activeProgram.onBackButton?()
    
    # Allow Pixeltosh to close when we're in Finder.
    return if activeProgram instanceof PAA.Pixeltosh.Programs.Finder
    
    # Close the program otherwise.
    @unloadProgram activeProgram
    
    # Inform that we handled the back button.
    true
    
  menuVisibleClass: ->
    'menu-visible' if @activeMenuItems()
    
  events: ->
    super(arguments...).concat
      'pointermove .pixelartacademy-pixeltosh-os': @onPointerMovePixeltoshOS
      'pointerleave .pixelartacademy-pixeltosh-os': @onPointerLeavePixeltoshOS
      'pointerenter *[data-cursor]': @onPointerEnterDataCursor
      'pointerleave *[data-cursor]': @onPointerLeaveDataCursor
  
  onPointerMovePixeltoshOS: (event) ->
    @cursor().updateCoordinates event
    
  onPointerLeavePixeltoshOS: (event) ->
    @cursor().resetCoordinates()
  
  onPointerEnterDataCursor: (event) ->
    @cursor().setClass $(event.target).data('cursor')
  
  onPointerLeaveDataCursor: (event) ->
    @cursor().setClass null
