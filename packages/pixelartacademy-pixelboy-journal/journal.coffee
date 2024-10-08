AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal'
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

    @setDefaultPixelBoySize()

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
        @setFixedPixelBoySize 171, 237

      else if journalDesign = @journalView().journalDesign()
        pixelBoySize = journalDesign.size()

        @setFixedPixelBoySize pixelBoySize.width, pixelBoySize.height

      else
        @setDefaultPixelBoySize()

  onBackButton: ->
    tasks = @journalView().tasks()
    
    if tasks.visible()
      tasks.hide()

      # Inform that we've handled the back button.
      true
