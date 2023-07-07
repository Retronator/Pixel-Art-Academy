AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Journal extends PAA.PixelPad.App
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Journal'
  @url: -> 'journal'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Journal"
  @description: ->
    "
      You can write about your projects in it.
    "

  @initialize()

  constructor: ->
    super arguments...

    @setDefaultPixelPadSize()

    @journalsView = new ReactiveField null
    @journalView = new ReactiveField null

    @journalId = new ComputedField =>
      AB.Router.getParameter 'parameter3'

  onCreated: ->
    super arguments...

    @journalsView new @constructor.JournalsView @
    @journalView new @constructor.JournalView @

    @autorun (computation) =>
      if @journalView().tasks()?.visible()
        @setFixedPixelPadSize 171, 237

      else if journalDesign = @journalView().journalDesign()
        pixelPadSize = journalDesign.size()

        @setFixedPixelPadSize pixelPadSize.width, pixelPadSize.height

      else
        @setDefaultPixelPadSize()

  onBackButton: ->
    tasks = @journalView().tasks()
    
    if tasks.visible()
      tasks.hide()

      # Inform that we've handled the back button.
      true
