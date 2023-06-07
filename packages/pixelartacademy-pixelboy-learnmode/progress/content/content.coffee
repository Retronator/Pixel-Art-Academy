AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

LearnModeApp = PAA.PixelBoy.Apps.LearnMode

class PAA.PixelBoy.Apps.LearnMode.Progress.Content extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress.Content'
  @register @id()

  onCreated: ->
    super arguments...

    @learnMode = @ancestorComponentOfType LearnModeApp

    @contentsDisplayed = new ReactiveField @_defaultContentsDisplayed()

  onRendered: ->
    super arguments...

    # Automatically update whether the contents are displayed when completion display type changes until changed manually.
    @_automaticContentDisplayedUpdateAutorun = @autorun (computation) =>
      content = @data()
      return unless content.contents().length

      # Depend on completion display type.
      @learnMode.completionDisplayType()

      Tracker.nonreactive =>
        @_setContentsDisplayed @_defaultContentsDisplayed(), 1

  _defaultContentsDisplayed: ->
    content = @data()

    switch @learnMode.completionDisplayType()
      when LearnModeApp.CompletionDisplayTypes.RequiredUnits
        content.unlocked() and not content.completed()

      when LearnModeApp.CompletionDisplayTypes.TotalPercentage
        content.unlocked() and content.completedRatio() < 1

  _setContentsDisplayed: (newContentsDisplayed, durationFactor) ->
    currentContentsDisplayed = @contentsDisplayed()
    return if newContentsDisplayed is currentContentsDisplayed

    $contents = @$('.contents').eq(0)
    $contents.velocity('stop', true)

    scale = LOI.adventure.interface.display.scale()

    fullHeight = $contents[0].scrollHeight
    fullVisibleHeight = Math.min 230 * scale, fullHeight

    currentHeight = $contents.outerHeight()
    currentVisibleHeight = Math.min 230 * scale, currentHeight

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
    content = @data()
    'unavailable' unless content.available()

  lockedClass: ->
    content = @data()
    'locked' unless content.unlocked()

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
    contentDiv = @$('.pixelartacademy-pixelboy-apps-learnmode-progress-content')[0]
    targetContentDiv = @$(event.target).closest('.pixelartacademy-pixelboy-apps-learnmode-progress-content')[0]
    return unless contentDiv is targetContentDiv

    # Only react if there if we have any contents.
    content = @data()
    return unless content.contents().length

    # Prevent automatic changes from now on.
    @_automaticContentDisplayedUpdateAutorun.stop()

    # Toggle whether the contents are displayed.
    @_setContentsDisplayed not @contentsDisplayed(), 1
