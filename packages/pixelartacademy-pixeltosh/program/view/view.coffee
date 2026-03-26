AE = Artificial.Everywhere
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Program.View extends LOI.View
  # programId: ID of the program this view belongs to
  # activateBringsWindowToTop: boolean whether activating this view brings its window to top, true by default
  # activateProgramOnly: boolean whether interacting with this view only activates the program, not the window, false by default
  # contentArea: the component that is rendered in this view
  @id: -> 'PixelArtAcademy.Pixeltosh.Program.View'
  @register @id()
  
  @_lastDOMElementInsertedTime = Date.now()

  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    
  programId: ->
    return unless viewData = @data()
    viewData.get 'programId'
    
  program: ->
    return unless programId = @programId()
    @os.getProgram programId
  
  programClass: ->
    @program()?.constructor.slug()
  
  activateBringsWindowToTop: ->
    return unless viewData = @data()
    viewData.get('activateBringsWindowToTop') ? true
  
  activateProgramOnly: ->
    return unless viewData = @data()
    viewData.get('activateProgramOnly') ? false
    
  windowId: ->
    return unless viewData = @data()
    viewData.get 'id'
    
  window: ->
    return unless windowId = @windowId()
    @os.interface.getWindow windowId
  
  active: ->
    @windowId() is @os.activeWindowId()
    
  events: ->
    super(arguments...).concat
      'pointerdown': @onPointerDown
  
  onPointerDown: (event) ->
    # See if we need to only activate the program.
    if @activateProgramOnly()
      @os.activateProgram @program()
      return
    
    # Activate the window (and program).
    windowId = @windowId()
    return if @os.activeWindowId() is windowId
    @os.activateWindow windowId
