AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana

class FM.Operator
  @id: -> throw new AE.NotImplementedException "Operator must have an ID."
  id: -> @constructor.id()

  @displayName: -> # Override to provide a name that is used in the GUI.
  displayName: -> @constructor.displayName()

  @_operatorClassesById = {}
  
  @getClasses: ->
    _.values @_operatorClassesById
    
  @getIds: ->
    _.keys @_operatorClassesById

  @getClassForId: (id) ->
    @_operatorClassesById[id]

  @initialize: ->
    # Store operator class by ID.
    @_operatorClassesById[@id()] = @
    
  constructor: (@interface, @fileId) ->
    if @fileId
      @data = @interface.getComponentDataForFile @, @fileId

    else
      @data = @interface.getComponentData @

    # Provide support for autorun calls that stop when operator is destroyed.
    @_autorunHandles = []

  destroy: ->
    handle.stop() for handle in @_autorunHandles

  autorun: (handler) ->
    handle = Tracker.autorun handler
    @_autorunHandles.push handle

    handle
    
  currentShortcut: ->
    @interface.getShortcutForOperator @
