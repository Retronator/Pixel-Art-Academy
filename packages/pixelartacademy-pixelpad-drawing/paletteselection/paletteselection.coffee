AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AC = Artificial.Control
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

depthCompression = 0.5
turnedAngle = 30

class PAA.PixelPad.Apps.Drawing.PaletteSelection extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.PaletteSelection'
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      open: AEc.ValueTypes.Trigger
      close: AEc.ValueTypes.Trigger
      slide: AEc.ValueTypes.Trigger
      
  @splitPaletteIntoColorRows: (palette) ->
    colors = []
    
    for ramp in palette.ramps
      for shade in ramp.shades
        colors.push THREE.Color.fromObject shade
        
    rowsCount = Math.ceil colors.length / 10
    colorsPerRow = Math.floor colors.length / rowsCount
    colorsRemainder = colors.length % rowsCount
    
    colorRows = []
    
    for rowIndex in [0...rowsCount]
      rowColors = []
      colorsCount = colorsPerRow
      colorsCount++ if rowIndex < colorsRemainder
      
      rowColors.push colors.shift() for colorIndex in [0...colorsCount]
      colorRows.push rowColors
    
    colorRows
      
  mixins: -> [@activatable]
  
  constructor: (@initialTargetPaletteName) ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable
    
    @visible = new ReactiveField false
    @currentPageIndex = new ReactiveField 0
    @targetPageIndex = new ReactiveField null
    @manualPageRotation = 0
    
    @_resetTargetPage()
    
  onCreated: ->
    super arguments...
    
    @app = @ancestorComponentOfType Artificial.Base.App
    
    @sections = new ComputedField =>
      return [] unless palette = LOI.palette()
      
      sections = [
        category: LOI.Assets.Palette.Categories.Basic
        color: palette.color LOI.Assets.Palette.Atari2600.hues.gray, 2
      ,
        category: LOI.Assets.Palette.Categories.Monoramp
        color: palette.color LOI.Assets.Palette.Atari2600.hues.purple, 3
      ,
        category: LOI.Assets.Palette.Categories.System
        color: palette.color LOI.Assets.Palette.Atari2600.hues.red, 3
      ,
        category: LOI.Assets.Palette.Categories.Modern
        color: palette.color LOI.Assets.Palette.Atari2600.hues.azure, 4
      ]
      
      separatorPageIndex = 1
      
      for section in sections
        section.palettes = LOI.Assets.Palette.documents.fetch
          category: section.category
        ,
          sort:
            name: 1
            
        section.separatorPageIndex = separatorPageIndex
        separatorPageIndex += section.palettes.length + 1
            
        # Sort palettes by number of colors except the systems palettes.
        continue if section.category is LOI.Assets.Palette.Categories.System
            
        section.palettes.sort (a, b) =>
          if a.ramps.length is b.ramps.length
            a.ramps[0].shades.length - b.ramps[0].shades.length
            
          else
            a.ramps.length - b.ramps.length
        
      sections
            
    @$pages = new ReactiveField []
    
    $(document).on 'keydown.pixelartacademy-pixelpad-apps-drawing-paletteselection', (event) => @onKeyDown event
  
  onRendered: ->
    super arguments...
    
    # When sections change, update the pages.
    @autorun (computation) =>
      @sections()
      
      Tracker.afterFlush =>
        $pages = @$('.page')
        @$pages $pages
        
        for page, index in $pages
          offset = Math.floor index * depthCompression
          
          $(page).css
            zIndex: $pages.length - index
            top: "#{offset - 25}rem"
        
        @$('.navigation').css zIndex: $pages.length + 1
        @$('.pin').css zIndex: $pages.length + 1
    
    @app.addComponent @
        
  onDestroyed: ->
    super arguments...
    
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-paletteselection'
    
    @app.removeComponent @
          
  onBackButton: ->
    @activatable.deactivate()
    
    # Inform that we've handled the back button.
    true
  
  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      return unless @activatable.activating()
      @visible true
    ,
      100

    Meteor.setTimeout =>
      return unless @activatable.activating()
      finishedActivatingCallback()
    ,
      1000
    
  onDeactivate: (finishedDeactivatingCallback) ->
    @_resetTargetPage()
    @visible false
    @$('.page').removeClass('turned').removeClass('manual-movement').css transform: ''
    
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      1000
    
  _getPaletteOnPage: (pageIndex) ->
    return null unless sections = @sections()
    
    for section in sections when section.separatorPageIndex < pageIndex <= section.separatorPageIndex + section.palettes.length
      paletteIndex = pageIndex - section.separatorPageIndex - 1
      return section.palettes[paletteIndex]
    
    null

  previousPage: ->
    @_resetManualMovement()
  
    $pages = @$pages()
    currentPageIndex = @currentPageIndex()
    return unless currentPageIndex
    
    currentPageIndex--
    @currentPageIndex currentPageIndex

    $pages.eq(currentPageIndex).removeClass('turned')
    
  nextPage: ->
    @_resetManualMovement()

    $pages = @$pages()
    currentPageIndex = @currentPageIndex()
    return if currentPageIndex >= $pages.length - 1
    
    $pages.eq(currentPageIndex).addClass('turned')
    
    currentPageIndex++
    @currentPageIndex currentPageIndex
    
  goToPage: (targetPageIndex) ->
    @targetPageIndex targetPageIndex
  
  _resetTargetPage: ->
    @targetPageIndex null
    @_pageTurnCooldownElapsed = 0
    @_pageTurnCooldownDuration = 0.1
  
  selectPalette: (palette) ->
    @selectedPalette = palette
    @activatable.deactivate()
  
  visibleClass: ->
    'visible' if @visible() and PAA.PixelPad.Apps.Drawing.PaletteSelection.Page.pageTemplateImageData()
  
  activeClass: ->
    'active' if @activatable.activated()
  
  showPreviousPageButton: ->
    @currentPageIndex()
    
  showNextPageButton: ->
    @currentPageIndex() < @$pages().length - 1
    
  previousPageButtonStyle: ->
    currentPageIndex = @currentPageIndex()
    
    bottom: "calc(50% + #{25 - currentPageIndex * depthCompression}rem)"
  
  nextPageButtonStyle: ->
    currentPageIndex = @currentPageIndex()
    
    top: "calc(50% + #{25 + currentPageIndex * depthCompression}rem)"
    
  update: (appTime) ->
    @_updateTargetPage appTime
    @_updatePaletteGlow appTime
    
  _updateTargetPage: (appTime) ->
    targetPageIndex = @targetPageIndex()
    return unless targetPageIndex?
    
    # Immediately after target is set and after the cooldown, move a page.
    if not @_pageTurnCooldownElapsed or @_pageTurnCooldownElapsed >= @_pageTurnCooldownDuration
      @_pageTurnCooldownElapsed = 0
      @_pageTurnCooldownDuration -= 0.01 if @_pageTurnCooldownDuration > 0.05

      # Note: We don't want to store current page index into a local variable
      # since it will get change with the call to next or previous page.
      if targetPageIndex > @currentPageIndex()
        @nextPage()

      else
        @previousPage()
      
      @_resetTargetPage() if @currentPageIndex() is targetPageIndex
      
    @_pageTurnCooldownElapsed += appTime.elapsedAppTime
  
  events: ->
    super(arguments...).concat
      'click .previous.page-button': @onPreviousPageButtonClick
      'click .next.page-button': @onNextPageButtonClick
      'wheel': @onWheel
      
  onPreviousPageButtonClick: (event) ->
    @previousPage()
    @_resetTargetPage()
  
  onNextPageButtonClick: (event) ->
    @nextPage()
    @_resetTargetPage()

  onWheel: (event) ->
    return unless @activatable.activated()
    
    @_resetTargetPage()
    
    $pages = @$pages()
    currentPageIndex = @currentPageIndex()
    
    atRest = not @manualPageRotation
    @manualPageRotation += event.originalEvent.deltaY
    
    # Prevent turning further on the first and last pages.
    if currentPageIndex is $pages.length - 1 and @manualPageRotation > 0 or currentPageIndex is 0 and @manualPageRotation < 0
      @_resetManualMovement()
      return
      
    # When moving backwards from rest, we need to activate the previous page.
    if atRest and @manualPageRotation < 0
      currentPageIndex--
      @currentPageIndex currentPageIndex
      @manualPageRotation += 90
    
    if 0 < @manualPageRotation < 90
      $pages.eq(currentPageIndex).addClass('manual-movement')
      $pages[currentPageIndex].style.transform = "rotateZ(-#{_.clamp @manualPageRotation, 0, 90}deg)"
      
    else
      @_resetManualMovement true
      
    if @manualPageRotation > turnedAngle
      $pages.eq(currentPageIndex).addClass('turned')
      
    else
      $pages.eq(currentPageIndex).removeClass('turned')
    
    if @manualPageRotation >= 90
      @manualPageRotation = 0

      currentPageIndex++
      @currentPageIndex currentPageIndex
      
    else if @manualPageRotation <= 0
      @manualPageRotation = 0
      
    # Also reset the current page angle after the user pauses scrolling.
    @_debouncedReset ?= _.debounce =>
      return unless @activatable.activated()
      return unless 0 < @manualPageRotation < 90
      
      @_resetManualMovement true
      
      currentPageIndex = @currentPageIndex()
      
      if @manualPageRotation > turnedAngle and currentPageIndex < $pages.length - 1
        currentPageIndex++
        @currentPageIndex currentPageIndex
        
      @manualPageRotation = 0
    ,
      1000
    
    @_debouncedReset()

  _resetManualMovement: (rememberAccumulatedPageRotation = false) ->
    currentPageIndex = @currentPageIndex()
    $pages = @$pages()
    
    $pages.eq(currentPageIndex).removeClass('manual-movement')
    $pages[currentPageIndex].style.transform = ''
    @manualPageRotation = 0 unless rememberAccumulatedPageRotation
  
  onKeyDown: (event) ->
    # Only capture events when the interface is active.
    return unless LOI.adventure.interface.active()
    
    keyCode = event.which
    switch keyCode
      when AC.Keys.up
        @_resetTargetPage()
        @previousPage()
      
      when AC.Keys.down
        @_resetTargetPage()
        @nextPage()
