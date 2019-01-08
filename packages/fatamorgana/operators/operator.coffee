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
    # Store action class by ID.
    @_operatorClassesById[@id()] = @
    
  constructor: (@interface) ->
    @data = @interface.getComponentData @
    
  currentShortcut: ->
    @interface.getShortcutForOperator @
