AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.TestPaper extends FM.View
  # actions: array of action IDs to include on the paper (used for undo/redo)
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.TestPaper'
  @register @id()
  
  @template: -> @constructor.id()
  
  onCreated: ->
    super arguments...
  
    @desktop = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
  
  action: ->
    toolId = @currentData()
    @interface.getOperator toolId

  toolClass: ->
    actionId = @currentData()

    @interface.getOperatorForId actionId

  tooltip: ->
    action = @currentData()
    name = action.displayName()
    shortcut = action.currentShortcut()
    return name unless shortcut
  
    shortcut = shortcut[0] if _.isArray shortcut
    shortcut = AM.ShortcutHelper.getShortcutString shortcut
  
    "#{name} (#{shortcut})"

  actionClass: ->
    action = @currentData()
    
    _.kebabCase action.displayName()
    
  enabledClass: ->
    enabled = true
    action = @currentData()
    
    if action.enabled
      enabled = _.propertyValue action, 'enabled'
    
    'enabled' if enabled
    
  eraserEnabledClass: ->
    'eraser-enabled' if @desktop.toolIsAvailable PAA.Practice.Software.Tools.ToolKeys.Eraser

  events: ->
    super(arguments...).concat
      'click .action-button': @onClickActionButton

  onClickActionButton: (event) ->
    action = @currentData()
    return if action.enabled and not action.enabled()
  
    action.execute @
