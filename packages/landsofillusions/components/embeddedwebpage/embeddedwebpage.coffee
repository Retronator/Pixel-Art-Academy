AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.Components.EmbeddedWebpage extends AM.Component
  onCreated: ->
    super arguments...
    
    adventure = @ancestorComponentOfType LandsOfIllusions.Adventure
    @embedded = true if adventure

    unless @embedded
      @display = new AM.Display
        safeAreaWidth: 320
        safeAreaHeight: 240
        minScale: 2

  onRendered: ->
    super arguments...

    if @embedded
      @$root = $('.webpage-embed-root')

    else
      @$root = $('html')

    @$root.addClass(@rootClass())

  onDestroyed: ->
    super arguments...

    @$root.removeClass(@rootClass())

  rootClass: ->
    # Override to style the root element.
    ''
