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

  class @Completionist extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelBoy.Apps.LearnMode.Progress.Completionist'
    
    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Checkbox

    load: ->
      PAA.PixelBoy.Apps.LearnMode.state('completionDisplayType') is PAA.PixelBoy.Apps.LearnMode.CompletionDisplayTypes.TotalPercentage

    save: (value) ->
      PAA.PixelBoy.Apps.LearnMode.state 'completionDisplayType', if value then PAA.PixelBoy.Apps.LearnMode.CompletionDisplayTypes.TotalPercentage else PAA.PixelBoy.Apps.LearnMode.CompletionDisplayTypes.RequiredUnits
