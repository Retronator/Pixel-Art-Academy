AE = Artificial.Everywhere
AM = Artificial.Mirage

# Enables scrolling in fullscreen via mouse wheel events.
class Artificial.Mirage.FullscreenScrollingMixin extends BlazeComponent
  onCreated: ->
    super

    @$html = $('html')
    @$window = $('window')

    @$container = $('body')
    @$content = $('.retronator-app')

    wasFullscreen = false
    
    @autorun (computation) =>
      isFullscreen = AM.Window.isFullscreen()
      
      if isFullscreen and not wasFullscreen
        # Switch to fullscreen.
        @$html.addClass('artificial-mirage-fullscreen-scrolling-mixin')
        @$html.on 'wheel.artificial-mirage-fullscreen-scrolling-mixin', (event) => @onWheel event

      else if not isFullscreen and wasFullscreen
        @$html.removeClass('artificial-mirage-fullscreen-scrolling-mixin')
        @$html.off 'wheel.artificial-mirage-fullscreen-scrolling-mixin'

        # Transfer translation to scroll top.
        scrollTop = -parseInt $.Velocity.hook(@$content, 'translateY') or 0
        @$window.scrollTop scrollTop

        # Remove translation.
        $.Velocity.hook @$content, 'translateY', 0

      wasFullscreen = isFullscreen

  onWheel: (event) ->
    delta = event.originalEvent.deltaY
    top = parseInt $.Velocity.hook(@$content, 'translateY') or 0
    newTop = top - delta

    # Limit scrolling to the amount of content.
    amountHidden = Math.max 0, @$content.height() - @$container.height()
    newTop = _.clamp newTop, -amountHidden, 0

    # See if we need to do anything at all.
    return if newTop is top

    event.preventDefault()

    $.Velocity.hook @$content, 'translateY', "#{newTop}px"
