AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal extends PAA.PixelBoy.App
  @register 'PixelArtAcademy.PixelBoy.Apps.Journal'

  @displayName: ->
    "Practice Journal"

  @urlName: ->
    'journal'

  onCreated: ->
    super

    @checkInsLimit = new ReactiveField 10

    @autorun =>
      PAA.Practice.CheckIn.forCharacterId.subscribe @, LOI.characterId(), @checkInsLimit()

  # Helpers

  checkIns: ->
    characterId = LOI.characterId()

    PAA.Practice.CheckIn.documents.find
      'character._id': characterId
    ,
      sort:
        time: -1

  events: ->
    super.concat
      'click button.check-in': @onClickCheckIn
      'click button.import-check-ins': @onClickImportCheckIns
      'click .load-more-button': @onClickLoadMoreButton

  onClickCheckIn: (event) ->
    PAA.Practice.CheckIn.insert LOI.characterId()

  onClickImportCheckIns: (event) ->
    PAA.Practice.CheckIn.import LOI.characterId()

  onClickLoadMoreButton: (event) ->
    @checkInsLimit @checkInsLimit() + 20

  class @CheckIn extends PAA.PixelBoy.App
    @register 'PixelArtAcademy.PixelBoy.Apps.Journal.CheckIn'

    onCreated: ->
      super
  
      @showAddImage = new ReactiveField false
          
    dateText: ->
      date = @currentData().time
      languagePreference = AB.languagePreference()
      date.toLocaleDateString languagePreference,
        day: 'numeric'
        month: 'long'
        year: 'numeric'
  
    # Events
  
    events: ->
      super.concat
        'click .delete-check-in-button': @onClickDeleteCheckInButton
        'click .add-image-button': @onClickAddImageButton
        'click .remove-image-button': @onClickRemoveImageButton
        'click .load-more-button': @onClickLoadMoreButton
  
    onClickDeleteCheckInButton: (event) ->
      checkIn = @currentData()
      PAA.Practice.CheckIn.remove checkIn._id
  
    onClickAddImageButton: (event) ->
      @showAddImage not @showAddImage()
  
    onClickRemoveImageButton: (event) ->
      checkIn = @currentData()
      PAA.Practice.CheckIn.updateUrl checkIn._id, null
  
    # Components
    
    class @Text extends AM.DataInputComponent
      @register 'PixelArtAcademy.Apps.Journal.CheckIn.Text'
  
      constructor: ->
        super
        @type = 'textarea'
        @autoSelect = false
        @autoResizeTextarea = true

      load: ->
        checkIn = @currentData()
        checkIn?.text
  
      save: (value) ->
        checkIn = @currentData()
        PAA.Practice.CheckIn.updateText checkIn._id, value
  
      placeholder: ->
        'Enter journal text here.'
