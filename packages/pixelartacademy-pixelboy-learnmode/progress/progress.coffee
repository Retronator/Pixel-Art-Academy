AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelBoy.Apps.LearnMode.Progress extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@learnMode) ->
    super arguments...

  onCreated: ->
    super arguments...

  courses: ->
    return unless LOI.adventureInitialized()
    _.flatten (chapter.courses for chapter in LOI.adventure.currentChapters())

  visibleClass: ->
    'visible' if @learnMode.state 'started'

  events: ->
    super(arguments...).concat
      'click .app-unlock-button': @onClickAppUnlockButton

  onClickAppUnlockButton: (event) ->
    app = @currentData()
    @learnMode.unlockApp app._id

  class @Content extends AM.Component
    @register 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress.Content'

    unavailableClass: ->
      content = @data()
      'unavailable' unless content.available()

    lockedClass: ->
      content = @data()
      'locked' unless content.unlocked()

    completedClass: ->
      content = @data()
      'completed' if content.completed()

    contentDepth: ->
      content = @data()

      # Count how many steps it takes till we get to the course parent.
      depth = 1

      while content not instanceof LM.Content.Course
        content = content.parent
        depth++

      depth

    percentageString: (ratio) ->
      "#{Math.round ratio * 100}%"
