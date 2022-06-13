AE = Artificial.Everywhere
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.History extends FM.Helper
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.History'
  @initialize()
  
  constructor: ->
    super arguments...
    
    @actions = []
    @currentActionIndex = 0
    
    # TODO: Load history from deep storage.

  currentAction: ->
    if @currentActionIndex > 0 then @actions[@currentActionIndex - 1] else null

  lastAction: ->
    if @currentActionIndex < @actions.length then @actions[@currentActionIndex] else null
    
  addAction: (action) ->
    # Remove all subsequent actions.
    @actions.splice @currentActionIndex
    
    # Add action to our history.
    @actions.push action

    # Execute action.
    meshLoader = @interface.getLoaderForFile @fileId
    action.executeForward meshLoader.meshData()
    
    # Move forward in history.
    @currentActionIndex++

  undo: ->
    unless lastAction = @lastAction()
      throw new AE.InvalidOperationException "There is nothing to undo."
    
    # Run the last action backwards.
    meshLoader = @interface.getLoaderForFile @fileId
    lastAction.executeBackward meshLoader.meshData()
    
    # Move backward in history.
    @currentActionIndex--
  
  redo: ->
    unless currentAction = @currentAction()
      throw new AE.InvalidOperationException "There is nothing to redo."
  
    # Run the current action forwards.
    meshLoader = @interface.getLoaderForFile @fileId
    currentAction.executeForward meshLoader.meshData()
  
    # Move forward in history.
    @currentActionIndex++
