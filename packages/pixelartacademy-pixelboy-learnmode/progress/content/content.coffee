AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelBoy.Apps.LearnMode.Progress.Content extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress.Content'
  @register @id()

  onCreated: ->
    super arguments...

    @learnMode = @ancestorComponentOfType PAA.PixelBoy.Apps.LearnMode

    content = @data()
    @contentsDisplayed = new ReactiveField content.unlocked() and not content.completed()

  unavailableClass: ->
    content = @data()
    'unavailable' unless content.available()

  lockedClass: ->
    content = @data()
    'locked' unless content.unlocked()

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

    # Toggle whether the contents are displayed.
    $contents = @$('.contents').eq(0)
    $contents.velocity('stop', true)

    scale = LOI.adventure.interface.display.scale()

    fullHeight = $contents[0].scrollHeight
    fullVisibleHeight = Math.min 230 * scale, fullHeight

    currentHeight = $contents.outerHeight()
    currentVisibleHeight = Math.min 230 * scale, currentHeight

    if contentsDisplayed = @contentsDisplayed()
      targetHeight = 0

    else
      targetHeight = fullVisibleHeight

    $contents.velocity
      height: [targetHeight, currentVisibleHeight]
    ,
      duration: Math.min 500, Math.abs(targetHeight - currentVisibleHeight) / scale * 4
      complete: => $contents.css height: 'auto' if targetHeight > 0

    @contentsDisplayed not contentsDisplayed
