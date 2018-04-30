AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
LOI = LandsOfIllusions

class LOI.Components.BackButton extends AM.Component
  @register 'LandsOfIllusions.Components.BackButton'

  constructor: (@onCloseCallback) ->
    super

    @closing = new ReactiveField false

  onRendered: ->
    super
    
    @$backButton = @$('.landsofillusions-components-back-button')

    # Positioning depends on whether this is inside an overlaid (2nd layer) item or not (1st layer).
    overlaid = @$backButton.closest('.overlaid').length

    # Resize elements.
    @autorun (computation) =>
      # We allow use outside of adventure as well, in which case we just find the parent that holds the display.
      display = LOI.adventure?.interface.display or @callAncestorWith 'display'
      scale = display.scale()
      viewport = display.viewport()

      if overlaid
        # Place back button inside viewport bounds.
        @$backButton.css
          top: viewport.safeArea.top()
          left: viewport.safeArea.left()

      else
        @$backButton.css
          top: viewport.viewportBounds.top() + 10 * scale
          left: viewport.viewportBounds.left() + 10 * scale

    $(document).on 'keydown.landsofillusions-components-backbutton', (event) =>
      return unless event.which is AC.Keys.escape

      @onClose event

  onDestroyed: ->
    super

    $(document).off '.landsofillusions-components-backbutton'

  closingClass: ->
    'closing' if @closing()

  events: ->
    super.concat
      'click .landsofillusions-components-back-button': @onClick

  onClick: (event) ->
    @onClose event

  onClose: (event) ->
    if @onCloseCallback
      result = @onCloseCallback event

      @closing true unless result?.cancel

    else
      @closing true

      # By default the back button deactivates the component it appears in.
      deactivatableParent = @ancestorComponentWith 'deactivate'

      # If the component is also the main active item, deactivate it at the adventure level (which changes the url).
      # We allow used outside of adventure interface so we check for presence of adventure first.
      if LOI.adventure and LOI.adventure.activeItemId() is deactivatableParent.id?()
        LOI.adventure.deactivateActiveItem()

      else
        deactivatableParent?.callFirstWith null, 'deactivate'
