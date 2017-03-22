AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Terrace extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Terrace'
  @url: -> ''

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.2'

  @fullName: -> "Retropolis International Spaceport terrace"
  @shortName: -> "terrace"
  @description: ->
    "
      You are on a terrace of the Retropolis International Spaceport.
      A magnificent view of the city lies before you. To the south you can return back
      inside the airport terminal.
    "
    
  @initialize()

  middleSceneHeight = 180
  middleSceneOffsetFactor = 0.5

  menuHeight = 120

  coatOfArmsHeight = 103
  coatOfArmsRealHeight = 180
  coatOfArmsOffset = -2

  constructor: ->
    super

    @_sceneBounds = new ReactiveField null

    @menuItems = new LOI.Components.Menu.Items
      landingPage: true

    @_lastAppTime =
      elapsedAppTime: 0
      totalAppTime: 0

  url: ->
    if @isLandingPage() then '' else 'spaceport/terrace'

  things: -> [
    @constructor.Retropolis
    @constructor.VendingMachine
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.South}": RS.AirportTerminal.Concourse
    "#{Vocabulary.Keys.Directions.In}": RS.AirportTerminal.Concourse

  isLandingPage: ->
    # We treat the terrace location as a landing page when the user still has a clear game state.
    LOI.adventure.isGameStateEmpty()

  topSectionVisibleClass: ->
    'visible' if @isLandingPage()

  titleSectionVisibleClass: ->
    'visible' if @isLandingPage()

  illustrationHeight: ->
    if @isLandingPage()
      illustrationHeight = @_sceneBounds()?.height() / @display?.scale()

      illustrationHeight or 0

    else
      middleSceneHeight

  onCreated: ->
    super

    # Set the initializing flag for the first rendering pass, before we have time to initialize rendered elements.
    @initializingClass = new ReactiveField "initializing"

    # Set things up if we're the landing page.
    @autorun (computation) =>
      if @isLandingPage()
        # Prevent default menu handling on escape.
        LOI.adventure.menu.customShowMenu =>
          # Simply scroll up to the menu.
          LOI.adventure.interface.scroll
            position: 0
            animate: true

      else
        LOI.adventure.menu.customShowMenu null

      # Also trigger resize, since the parallax offsets must change without the top section.
      @hasResized = true

  onRendered: ->
    super

    @app = @ancestorComponent Retronator.App
    @app.addComponent @

    @display = LOI.adventure.interface.display

    ### Parallax ###

    # Preprocess parallax elements to avoid trashing.
    parallaxElements = []
    topParallaxElements = []
    titleParallaxElements = []
    middleParallaxElements = []

    sceneItems =
      coatOfArms: []

    @$('.landing-page *[data-depth]').each ->
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

      if $element.closest('.top-section').length
        localArray = topParallaxElements

      else if $element.closest('.title-section').length
        localArray = titleParallaxElements

      else
        localArray = middleParallaxElements

      localArray.push parallaxInfo

      sceneItems.quadrocopter = parallaxInfo if $element.hasClass('quadrocopter')
      sceneItems.airshipFar = parallaxInfo if $element.hasClass('airship-far')
      sceneItems.airshipNear = parallaxInfo if $element.hasClass('airship-near')
      sceneItems.frigates1 = parallaxInfo if $element.hasClass('frigates-1')
      sceneItems.frigates2 = parallaxInfo if $element.hasClass('frigates-2')
      sceneItems.frigates3 = parallaxInfo if $element.hasClass('frigates-3')
      sceneItems.frigates4 = parallaxInfo if $element.hasClass('frigates-4')
      sceneItems.coatOfArms.push parallaxInfo if $element.hasClass('coat-of-arms')

    @sceneItems = sceneItems

    @topParallaxElements = topParallaxElements
    @titleParallaxElements = titleParallaxElements
    @middleParallaxElements = middleParallaxElements

    # Image scaling

    # Provide scale to the jQuery handlers, which don't have @.
    scaleField = @display.scale

    # Preprocess all the images.
    @$('.scene').add('.title-section').find('img').each ->
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
        scale = scaleField()

        css =
          width: loadedImage.width * scale
          height: loadedImage.height * scale

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = data[property] * scale if data[property]

        $image.css css

        $image.removeClass('initializing')

    # Reposition parallax elements.
    @autorun (computation) =>
      scale = @display.scale()

      for element in parallaxElements
        css = {}

        for property in ['left', 'top', 'bottom', 'right']
          css[property] = element[property] * scale if element[property]

        element.$element.css css

    # Scale the images.
    @autorun (computation) =>
      scale = @display.scale()

      $('.landing-page').find('img').each ->
        $image = $(@)

        css =
          width: $image.data('sourceWidth') * scale
          height: $image.data('sourceHeight') * scale

        for property in ['left', 'top', 'bottom', 'right']
          value = $image.data(property)
          css[property] = value * scale if value

        $image.css css

    # Cache elements.
    @$paralaxSections = @$('.landing-page .parallax-section')
    @$uiArea = $('.ui-area')

    # Enable magnification detection.
    @autorun =>
      # Register dependency on display scaling and viewport size.
      @display.scale()
      @display.viewport()
      @hasResized = true

    # Animation

    @airshipsMoving = false
    @airshipsMovingTimeStart = 0

    # We are finished with initialization.
    @initializingClass ""

  onDestroyed: ->
    super

    @app?.removeComponent @

    LOI.adventure.menu.customShowMenu null

  onScroll: ->
    @draw()

  draw: (appTime) ->
    return unless @isRendered()

    # Support for calls without app time. Just reuse last one.
    if appTime
      @_lastAppTime = appTime

    else
      appTime = @_lastAppTime

    scale = @display.scale()

    if @hasResized
      @hasResized = false

      # Also trigger parallax.
      forceScroll = true

      viewport = @display.viewport()

      topSectionBounds = new AE.Rectangle
        x: viewport.safeArea.x()
        y: viewport.viewportBounds.y()
        width: viewport.safeArea.width()
        height: viewport.viewportBounds.height()

      # If we're not on the landing page, we don't have the top section.
      unless @isLandingPage()
        topSectionBounds.height 0

      # Middle section is absolute inside the scene.
      middleSectionBounds = new AE.Rectangle
        x: 0
        y: topSectionBounds.bottom() * (1 + middleSceneOffsetFactor)
        width: viewport.maxBounds.width()
        height: middleSceneHeight * scale

      # Scene is the part with sky background.
      sceneBounds = new AE.Rectangle
        x: viewport.maxBounds.x() - viewport.viewportBounds.x()
        y: viewport.viewportBounds.y()
        width: viewport.maxBounds.width()
        height: middleSectionBounds.bottom()

      # Move the title section over the middle.
      titleSectionBounds = topSectionBounds.clone()
      titleSectionBounds.y middleSectionBounds.y() - (topSectionBounds.height() - middleSectionBounds.height()) * 0.5 + sceneBounds.y()

      @_sceneBounds sceneBounds

      # Apply changes.
      @$('.landing-page .scene').css sceneBounds.toDimensions()

      @$('.landing-page .top-section').css topSectionBounds.toDimensions()

      @$('.landing-page .title-section').css titleSectionBounds.toDimensions()

      topSectionRestHeight = topSectionBounds.height() * 0.5 - menuHeight * 0.5 * scale
      topSectionMiddleHeight = menuHeight * scale

      @$('.landing-page .top-section .top, .landing-page .top-section .bottom').css
        height: topSectionRestHeight
        lineHeight: "#{topSectionRestHeight}px"

      @$('.landing-page .top-section .middle').css
        top: topSectionRestHeight
        height: topSectionMiddleHeight
        lineHeight: "#{topSectionMiddleHeight}px"

      @$('.landing-page .title-section .top').css
        height: topSectionRestHeight
        lineHeight: "#{topSectionRestHeight}px"

      @$('.landing-page .title-section .middle').css
        top: titleSectionBounds.height() * 0.5 - coatOfArmsRealHeight * 0.5 * scale + coatOfArmsOffset * scale

      @$('.landing-page .middle-section').css middleSectionBounds.toDimensions()

      $('.landing-page').css
        height: sceneBounds.height()

      # Update parallax origins. They tells us at what scroll top the images are at the original setup.

      if @isLandingPage()
        # The top scene is correct simply as the page is rendered on top.
        @topParallaxOrigin = 0

        # It should be when the middle section is exactly in the middle of the screen.
        middleScenePillarboxBarHeight = (viewport.viewportBounds.height() - middleSectionBounds.height()) * 0.5
        @middleParallaxOrigin = middleSectionBounds.top() - middleScenePillarboxBarHeight

        @titleParallaxOrigin = @middleParallaxOrigin

      else
        # The middle scene is correct at 0 when we're not on the landing page.
        @middleParallaxOrigin = 0

    scrollTop = -parseInt $.Velocity.hook(@$uiArea, 'translateY') or 0

    if forceScroll or scrollTop isnt @_currentScrollTop
      @_currentScrollTop = scrollTop
      @hasScrolled = false

      @topScrollDelta = scrollTop - @topParallaxOrigin
      @titleScrollDelta = scrollTop - @titleParallaxOrigin
      @middleScrollDelta = scrollTop - @middleParallaxOrigin

      unless @airshipsMoving
        @airshipsMovingTimeStart = appTime.totalAppTime
        @airshipsMoving = true if scrollTop > 0 or not @isLandingPage()

      # Move sections.
      @$paralaxSections.css transform: "translate3d(0, #{-scrollTop}px, 0)"

      # Move elements.
      for element in @middleParallaxElements
        offset = @middleScrollDelta * element.scaleFactor
        element.$element.css transform: "translate3d(0, #{offset}px, 0)"

      for element in @topParallaxElements
        offset = @topScrollDelta * element.scaleFactor
        element.$element.css transform: "translate3d(0, #{offset}px, 0)"

      for element in @titleParallaxElements
        offset = @titleScrollDelta * element.scaleFactor
        element.$element.css transform: "translate3d(0, #{offset}px, 0)"

    for element in @sceneItems.coatOfArms
      tilt = Math.sin(appTime.totalAppTime + 2) * 10 * scale
      offset = (@titleScrollDelta + tilt) * element.scaleFactor + 0.6 * tilt
      element.$element.css transform: "translate3d(0, #{offset}px, 0)"

    x = Math.sin(appTime.totalAppTime / 2) * 5 * scale
    y = @middleScrollDelta * @sceneItems.quadrocopter.scaleFactor + Math.sin(appTime.totalAppTime) * 3 * scale
    @sceneItems.quadrocopter.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = (appTime.totalAppTime - @airshipsMovingTimeStart) * scale
    y = @middleScrollDelta * @sceneItems.airshipFar.scaleFactor
    @sceneItems.airshipFar.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = (appTime.totalAppTime - @airshipsMovingTimeStart) * scale * 5 - 100 * scale
    y = @middleScrollDelta * @sceneItems.airshipNear.scaleFactor
    @sceneItems.airshipNear.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5) * scale
    y = @middleScrollDelta * @sceneItems.frigates1.scaleFactor + Math.sin(appTime.totalAppTime / 2) * 2 * scale
    @sceneItems.frigates1.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5 + 1) * scale * 2
    y = @middleScrollDelta * @sceneItems.frigates2.scaleFactor + Math.sin(appTime.totalAppTime / 2 + 4) * scale
    @sceneItems.frigates2.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5 + 2) * 2 * scale
    y = @middleScrollDelta * @sceneItems.frigates3.scaleFactor + Math.sin(appTime.totalAppTime / 2 + 5) * 2 * scale
    @sceneItems.frigates3.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"

    x = Math.sin(appTime.totalAppTime / 5 + 3) * 2 * scale
    y = @middleScrollDelta * @sceneItems.frigates4.scaleFactor + Math.sin(appTime.totalAppTime / 2 + 6) * 3 * scale
    @sceneItems.frigates4.$element.css transform: "translate3d(#{x}px, #{y}px, 0)"
