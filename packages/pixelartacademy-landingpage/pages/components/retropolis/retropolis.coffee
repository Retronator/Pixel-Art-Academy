AM = Artificial.Mirage

class PixelArtAcademy.LandingPage.Pages.Components.Retropolis extends AM.Component
  @register 'PixelArtAcademy.LandingPage.Pages.Components.Retropolis'

  @version: -> '0.0.1'

  sceneWidth = 360
  sceneScale = 2

  middleSceneHeight = 180
  middleSceneOffsetFactor = 0.5

  onCreated: ->
    super arguments...

    # Set the initializing flag for the first rendering pass, before we have time to initialize rendered elements.
    @initializingClass = new ReactiveField "initializing"

    # Add 2x scale class to html so we can scale cursors.
    $('html').addClass('scale-2')

  onRendered: ->
    super arguments...

    $(window).scrollTop(0)

    ### Parallax ###

    # Preprocess parallax elements to avoid trashing.
    parallaxElements = []
    sceneItems = {}

    @$('*[data-depth]').each ->
      $element = $(@)

      scaleFactor = 1 - $element.data('depth')

      parallaxInfo =
        $element: $element
        scaleFactor: scaleFactor
        left: $element.positionCss('left')
        right: $element.positionCss('right')
        top: $element.positionCss('top')
        bottom: $element.positionCss('bottom')

      for property in ['left', 'top', 'bottom', 'right']
        parallaxInfo[property] = if parallaxInfo[property] is 'auto' then null else parseInt(parallaxInfo[property])

      parallaxElements.push parallaxInfo

      sceneItems.quadrocopter = parallaxInfo if $element.hasClass('quadrocopter')
      sceneItems.airshipFar = parallaxInfo if $element.hasClass('airship-far')
      sceneItems.airshipNear = parallaxInfo if $element.hasClass('airship-near')
      sceneItems.frigates1 = parallaxInfo if $element.hasClass('frigates-1')
      sceneItems.frigates2 = parallaxInfo if $element.hasClass('frigates-2')
      sceneItems.frigates3 = parallaxInfo if $element.hasClass('frigates-3')
      sceneItems.frigates4 = parallaxInfo if $element.hasClass('frigates-4')

    @sceneItems = sceneItems

    ### Image scaling ###

    # Preprocess all the images.
    @$('.scene').find('img').each ->
      $image = $(@)
      $image.addClass('initializing')

      source = $image.attr('src')

      # Load a copy for measuring purposes.
      $('<img/>').attr(src: source).load ->
        loadedImage = @
        # Store size from loaded image to the original image.
        data =
          sourceWidth: loadedImage.width
          sourceHeight: loadedImage.height
          left: $image.positionCss('left')
          right: $image.positionCss('right')
          top: $image.positionCss('top')
          bottom: $image.positionCss('bottom')

        for property in ['left', 'top', 'bottom', 'right']
          data[property] = if data[property] is 'auto' then null else parseInt(data[property])

        $image.data data

        # Scale the original image for the first time.
        scale = sceneScale

        css =
          width: loadedImage.width * scale
          height: loadedImage.height * scale

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = data[property] * scale if data[property]

        $image.css css

        $image.removeClass('initializing')

    # Reposition parallax elements.
    @autorun (computation) =>
      scale = sceneScale

      for element in parallaxElements
        css = {}

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = element[property] * scale if element[property]

          spread = 300
          offset = -spread * element.scaleFactor + spread
          css.transform = "translate3d(0, #{offset}px, 0)"

        element.$element.css css

    # Scale the images.
    @autorun (computation) =>
      scale = sceneScale

      @$('.scene').find('img').each ->
        $image = $(@)

        css =
          width: $image.data('sourceWidth') * scale
          height: $image.data('sourceHeight') * scale

        for property in ['left', 'top', 'bottom', 'right']
          value = $image.data(property)
          css[property] = value * scale if value

        $image.css css

    @initializingClass ""

  onDestroyed: ->
    super arguments...

    $('html').removeClass('scale-2')
