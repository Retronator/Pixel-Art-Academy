AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.BackButton extends AM.Component
  @register 'LandsOfIllusions.Components.BackButton'

  constructor: (@onClickCallback) ->

  onRendered: ->
    # Resize elements.
    @autorun (computation) =>
      adventure = @ancestorComponent LOI.Adventure

      scale = adventure.interface.display.scale()
      viewport = adventure.interface.display.viewport()

      # Place back button inside viewport bounds.
      @$('.lands-of-illusions-components-back-button').css
        top: viewport.viewportBounds.top() + 10 * scale
        left: viewport.viewportBounds.left() + 10 * scale

  events: ->
    super.concat
      'click .lands-of-illusions-components-back-button': @onClick

  onClick: (event) ->
    if @onClickCallback
      @onClickCallback event

    else
      # By default the back button deactivates the item it appears in.
      item = @ancestorComponentWith (component) => component instanceof LOI.Adventure.Item

      # If the item is also the main active item, deactivate it at the adventure level (which changes the url).
      if item.options.adventure.activeItemId() is item.id()
        item.options.adventure.deactivateCurrentItem()

      else
        item.deactivate()
