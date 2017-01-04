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
      adventure = @ancestorComponent LOI.Adventure

      scale = adventure.interface.display.scale()
      viewport = adventure.interface.display.viewport()

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
    @closing true

    if @onClickCallback
      @onClickCallback event

    else
      # By default the back button deactivates the component it appears in.
      deactivatableParent = @ancestorComponentWith 'deactivate'
      deactivatableParent?.callFirstWith null, 'deactivate'
