AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Journal'

  onCreated: ->
    super

    @autorun =>
      Meteor.subscribe 'characterCheckIns', LOI.characterId()

  # Helpers

  checkIns: ->
    characterId = LOI.characterId()

    PAA.Practice.CheckIn.documents.find
      'character._id': characterId
    ,
      sort:
        time: -1

  dateText: ->
    date = @currentData().time
    languagePreference = AB.userLanguagePreference()
    date.toLocaleDateString languagePreference,
      day: 'numeric'
      month: 'long'
      year: 'numeric'

  # Events

  events: ->
    super.concat
      'click button.check-in': @onClickCheckIn
      'click button.import-check-ins': @onClickImportCheckIns
      'click .check-in .delete': @onClickDeleteCheckIn

  onClickCheckIn: (event) ->
    FlowRouter.go 'journalCheckIn'

  onClickImportCheckIns: (event) ->
    Meteor.call "PixelArtAcademy.Practice.CheckIn.import", LOI.characterId()

  onClickDeleteCheckIn: (event) ->
    Meteor.call "practiceCheckInRemove", @currentData()._id

  # Components
  
  class @CheckInText extends AM.DataInputComponent
    @register 'PixelArtAcademy.Apps.Journal.CheckInText'

    constructor: ->
      super
      @type = 'textarea'
      @autoSelect = false
      @autoResizeTextarea = true

    load: -> @currentData()?.text

    save: (value) -> Meteor.call "practiceCheckInChangeText", @currentData()._id, value

    placeholder: ->
      'Enter journal text here.'
