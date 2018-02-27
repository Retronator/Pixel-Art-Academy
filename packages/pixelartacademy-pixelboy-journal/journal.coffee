AB = Artificial.Babel
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
    super

    @setDefaultPixelBoySize()

  onCreated: ->
    super

    @autorun =>
      PAA.Practice.Journal.forCharacterId.subscribe @, LOI.characterId()

  # Helpers

  activeJournals: ->
    @_journals false

  archivedJournals: ->
    @_journals false

  _journals: (archived) ->
    PAA.Practice.Journal.documents.find
      'character._id': LOI.characterId()
      archived: archived

  # Events

  events: ->
    super.concat
      'click .new-journal-button': @onClickNewJournalButton

  onClickNewJournalButton: (event) ->
    PAA.Practice.Journal.insert LOI.characterId(),
      type: PAA.Practice.Journal.Design.Type.Traditional
      size: PAA.Practice.Journal.Design.Size.Small
      orientation: PAA.Practice.Journal.Design.Orientation.Portrait
      bindingPosition: PAA.Practice.Journal.Design.BindingPosition.Left
      paper:
        type: PAA.Practice.Journal.Design.PaperType.QuadDense
        color:
          hue: LOI.Assets.Palette.Atari2600.hues.brown
          shade: 7
      cover:
        color:
          hue: LOI.Assets.Palette.Atari2600.hues.grey
          shade: 1

  onClickImportCheckIns: (event) ->
    Meteor.call 'PixelArtAcademy.Practice.CheckIn.import', LOI.characterId()

  onClickDeleteCheckIn: (event) ->
    Meteor.call 'PixelArtAcademy.Practice.CheckIn.remove', @currentData()._id

  # Components
  
  class @CheckInText extends AM.DataInputComponent
    @register 'PixelArtAcademy.Apps.Journal.CheckInText'

    constructor: ->
      super
      @type = 'textarea'
      @autoSelect = false
      @autoResizeTextarea = true

    load: -> @currentData()?.text

    save: (value) -> Meteor.call 'PixelArtAcademy.Practice.CheckIn.changeText', @currentData()._id, value

    placeholder: ->
      'Enter journal text here.'
