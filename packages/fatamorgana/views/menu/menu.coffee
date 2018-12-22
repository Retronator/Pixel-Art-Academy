AM = Artificial.Mirage
FM = FataMorgana

class FM.Menu extends FM.View
  # items: array of top-level entries in the menu
  #   caption: text for the item
  #   items: an array of entries that show up in a dropdown
  #     ...
  @id: -> 'FataMorgana.Menu'
  @register @id()
  
  events: ->
    super(arguments...).concat
      'click .item': @onClickItem

  onClickItem: (event) ->
    dropdownData = @currentData()

    $item = $(event.target)
    position = $item.position()

    display = @callAncestorWith 'display'
    scale = display.scale()

    dialog = _.extend
      type: FM.Menu.Dropdown.id()
      left: position.left / scale
      top: (position.top + $item.outerHeight()) / scale
      canDismiss: true
    ,
      dropdownData

    @interface.displayDialog dialog
