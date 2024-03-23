AM = Artificial.Mirage
FM = FataMorgana

class FM.Menu.Dropdown extends FM.View
  # items: array of entries in the dropdown
  #   [actionId]: string identifying the action to be performed
  #   [null]: a divider between items
  #   [{caption, items}]: an embedded dropdown of entries shown on hover
  @id: -> 'FataMorgana.Menu.Dropdown'
  @register @id()

  isDivider: ->
    item = @currentData()

    # Divider is represented by a null value.
    not item
  
  action: ->
    actionId = @currentData()
    @interface.getOperator actionId

  activeClass: ->
    action = @currentData()
    'active' if action?.active?()

  shortcut: ->
    action = @currentData()

    shortcut = action.currentShortcut()
    shortcut = shortcut[0] if _.isArray shortcut

    AM.ShortcutHelper.getShortcutString shortcut

  enabledClass: ->
    enabled = true
    itemOrAction = @currentData()
    
    if itemOrAction.enabled
      enabled = _.propertyValue itemOrAction, 'enabled'

    'enabled' if enabled

  events: ->
    super(arguments...).concat
      'click .item': @onClickItem

  onClickItem: (event) ->
    action = @currentData()
    return if action.enabled and not action.enabled()

    action.execute @

    dialog = @data()
    @interface.closeDialog dialog
