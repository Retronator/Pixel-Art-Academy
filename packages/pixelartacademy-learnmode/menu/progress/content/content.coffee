AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Menu.Progress.Content extends AM.Component
  @id: -> 'PixelArtAcademy.LearnMode.Menu.Progress.Content'
  @register @id()

  onCreated: ->
    super arguments...
    
    @progress = @ancestorComponentOfType LM.Menu.Progress

    @contentsDisplayed = new ReactiveField @_defaultContentsDisplayed()

  onRendered: ->
    super arguments...

    # Automatically update whether the contents are displayed when completion display type changes until changed manually.
    @_automaticContentDisplayedUpdateAutorun = @autorun (computation) =>
      content = @data()
      return unless content.contents().length

      # Depend on completion display type.
      LM.Menu.Progress.completionDisplayType()

      Tracker.nonreactive =>
        @_setContentsDisplayed @_defaultContentsDisplayed(), 1

  _defaultContentsDisplayed: ->
    # Never automatically show content in preview mode.
    return if @progress.inPreview()
    
    # Don't automatically show future content.
    content = @data()
    return if LM.Content.Tags.Future in content.tags()

    switch LM.Menu.Progress.completionDisplayType()
      when LM.Menu.Progress.CompletionDisplayTypes.RequiredUnits
        content.unlocked() and not content.completed()

      when LM.Menu.Progress.CompletionDisplayTypes.TotalPercentage
        content.unlocked() and content.completedRatio() < 1

  _setContentsDisplayed: (newContentsDisplayed, durationFactor) ->
    currentContentsDisplayed = @contentsDisplayed()
    return if newContentsDisplayed is currentContentsDisplayed

    $contents = @$('.contents').eq(0)
    $contents.velocity('stop', true)

    display = LOI.adventure.interface.display
    scale = display.scale()
    
    viewportHeight = LOI.adventure.interface.display.viewport().viewportBounds.height()

    fullHeight = $contents[0].scrollHeight
    fullVisibleHeight = Math.min viewportHeight, fullHeight

    currentHeight = $contents.outerHeight()
    currentVisibleHeight = Math.min viewportHeight, currentHeight

    if currentContentsDisplayed
      targetHeight = 0

    else
      targetHeight = fullVisibleHeight

    $contents.velocity
      height: [targetHeight, currentVisibleHeight]
    ,
      duration: durationFactor * Math.min 500, Math.abs(targetHeight - currentVisibleHeight) / scale * 4
      complete: => $contents.css height: 'auto' if targetHeight > 0

    @contentsDisplayed newContentsDisplayed

  unavailableClass: ->
    # Only show unavailable status when in game.
    return unless @progress.inGame()
    
    content = @data()
    'unavailable' unless content.available()

  lockedClass: ->
    # Only show locked status when in game.
    return unless @progress.inGame()
    
    content = @data()
    'locked' if content.locked()

  contentDepthClass: ->
    content = @data()
    "depth-#{content.depth()}"

  completedClass: ->
    content = @data()
    'completed' if content.completed()

  contentsDisplayedClass: ->
    'displayed' if @contentsDisplayed()

  events: ->
    super(arguments...).concat
      'click .title-area': @onClickTitleArea

  onClickTitleArea: (event) ->
    # Only react to the immediate title.
    contentDiv = @$('.pixelartacademy-learnmode-menu-progress-content')[0]
    targetContentDiv = @$(event.target).closest('.pixelartacademy-learnmode-menu-progress-content')[0]
    return unless contentDiv is targetContentDiv

    # Only react if there if we have any contents.
    content = @data()
    return unless content.contents().length

    # Prevent automatic changes from now on.
    @_automaticContentDisplayedUpdateAutorun.stop()

    # Toggle whether the contents are displayed.
    @_setContentsDisplayed not @contentsDisplayed(), 1
