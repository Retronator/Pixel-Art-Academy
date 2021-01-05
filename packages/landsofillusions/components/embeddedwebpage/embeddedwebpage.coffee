AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.Components.EmbeddedWebpage extends AM.Component
  onCreated: ->
    super arguments...
    
    adventure = @ancestorComponentOfType LOI.Adventure
    @embedded = true if adventure

    if @embedded
      @display = new @constructor.Display @, adventure.interface.display,
        # Safe area size accommodates for embedded browser's header and scrollbar.
        safeAreaWidth: 310
        safeAreaHeight: 180

      ancestorWithUrl = @ancestorComponentWith 'url'
      @router = new @constructor.Router @, (value, options) => ancestorWithUrl.url value, options

    else
      @display = new AM.Display
        safeAreaWidth: 320
        safeAreaHeight: 240
        minScale: LOI.settings.graphics.minimumScale.value
        maxScale: LOI.settings.graphics.maximumScale.value

      @router = AB.Router

  onRendered: ->
    super arguments...

    if @embedded
      @$root = $('.webpage-embed-root')

    else
      @$root = $('html')

    @$root.addClass(@rootClass())

    @display.initialize() if @display instanceof @constructor.Display

  onDestroyed: ->
    super arguments...

    @$root.removeClass(@rootClass())

    @display.destroy() if @display instanceof @constructor.Display
    @router.destroy() if @router instanceof @constructor.Router

  rootClass: ->
    # Override to style the root element.
    ''
