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

    @checkInsLimit = new ReactiveField 10
    @checkInIndex = new ReactiveField 0
    @checkInPageIndex = new ReactiveField 0

    @autorun =>
      PAA.Practice.CheckIn.forCharacterId.subscribe @, LOI.characterId(), @checkInsLimit()

    @checkIn = new ComputedField =>
      @checkIns().fetch()[@checkInIndex()]

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