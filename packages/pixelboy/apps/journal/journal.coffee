AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.Journal'

  displayName: ->
    "Practice Journal"

  keyName: ->
    'journal'

  onCreated: ->
    super

    @useConsoleTheme = true

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

  disableScrollingClass: ->
    'disable-scrolling' if @showCheckInForm()

  showCheckInForm: ->
    @os.currentAppPath() is 'check-in'

  # Events

  events: ->
    super.concat
      'click button.check-in': @onClickCheckIn
      'click button.import-check-ins': @onClickImportCheckIns
      'click .check-in .delete': @onClickDeleteCheckIn

  onClickCheckIn: (event) ->
    @os.go 'journal', 'check-in'

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
