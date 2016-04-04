AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Apps.Journal.CheckIn extends AM.Component
  @register 'PixelArtAcademy.Apps.Journal.CheckIn'

  onCreated: ->
    super
    
    @submitting = new ReactiveField false

  # Helpers

  # Events

  events: ->
    super.concat
      'submit .check-in-form': @onSubmitCheckInForm

  onSubmitCheckInForm: (event) ->
    event.preventDefault()
    
    @submitting true
    
    text = $('.text').val()
    imageFile = $('.image-file')[0]?.files[0]
    imageUrl = $('.image-url').val()

    if imageUrl
      @_finishSubmitting text, imageUrl

    else
      PAA.Practice.upload imageFile, (imageUrl) =>
        @_finishSubmitting text, imageUrl

  _finishSubmitting: (text, imageUrl) ->
    console.log "submit", text, imageUrl

    Meteor.call 'practiceCheckIn', LOI.characterId(), text, imageUrl, (error) =>
      @submitting false

      if error
        console.log error.message

      else
        FlowRouter.go 'journal'
