AM = Artificial.Mirage
FM = FataMorgana

class FM.Menu.Dropdown extends FM.View
  # items: array of entries in the dropdown
  #   caption: text for the item
  #   items: an array of entries shown in a sub-menu on hover
  #     ...
  @id: -> 'FataMorgana.Menu.Dropdown'
  @register @id()

  isDivider: ->
    item = @currentData()

    # Divider is represented by a null value.
    not item
  
  action: ->
    actionId = @currentData()
    @interface.actions()[actionId]

  activeClass: ->
    action = @currentData()
    'active' if action.active?()

  shortcut: ->
    action = @currentData()
    AM.ShortcutHelper.getShortcutString action.shortcut

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

    action.execute()

    dialog = @data()
    @interface.closeDialog dialog
