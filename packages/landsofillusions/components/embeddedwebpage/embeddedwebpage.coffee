AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.Components.EmbeddedWebpage extends AM.Component
  onCreated: ->
    super
    
    adventure = @ancestorComponentOfType LandsOfIllusions.Adventure
    @embedded = true if adventure

    if @embedded
      @$root = $('.webpage-embed-root')

    else
      @display = new AM.Display
        safeAreaWidth: 320
        safeAreaHeight: 240
        minScale: 2

      @$root = $('html')

    @$root.addClass(@rootClass())

  onDestroyed: ->
    super

    @$root.removeClass(@rootClass())

  rootClass: ->
    # Override to style the root element.
    ''
