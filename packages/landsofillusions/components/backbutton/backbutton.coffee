AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.BackButton extends AM.Component
  @register 'LandsOfIllusions.Components.BackButton'

  constructor: (@onClickCallback) ->
    super

    @closing = new ReactiveField false

  onRendered: ->
    super
    
    @$backButton = @$('.lands-of-illusions-components-back-button')

    # Positioning depends on whether this is inside an overlaid (2nd layer) item or not (1st layer).
    overlaid = @$backButton.closest('.overlaid').length

    # Resize elements.
    @autorun (computation) =>
      scale = LOI.adventure.interface.display.scale()
      viewport = LOI.adventure.interface.display.viewport()

      if overlaid
        # Place back button inside viewport bounds.
        @$backButton.css
          top: viewport.safeArea.top()
          left: viewport.safeArea.left()

      else
        @$backButton.css
          top: viewport.viewportBounds.top() + 10 * scale
          left: viewport.viewportBounds.left() + 10 * scale

  closingClass: ->
    'closing' if @closing()

  events: ->
    super.concat
      'click .lands-of-illusions-components-back-button': @onClick

  onClick: (event) ->
    if @onClickCallback
      result = @onClickCallback event

      @closing true unless result?.cancel

    else
      @closing true

      # By default the back button deactivates the component it appears in.
      deactivatableParent = @ancestorComponentWith 'deactivate'

      # If the component is also the main active item, deactivate it at the adventure level (which changes the url).
      if LOI.adventure.activeItemId() is deactivatableParent.id?()
        LOI.adventure.deactivateCurrentItem()

      else
        deactivatableParent?.callFirstWith null, 'deactivate'
