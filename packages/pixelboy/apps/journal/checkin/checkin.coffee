AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.CheckIn extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Journal.CheckIn'

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
    externalUrl = $('.external-url').val()

    if externalUrl
      @_finishSubmitting text, externalUrl

    else if imageFile
      PAA.Practice.upload imageFile, (imageUrl) =>
        @_finishSubmitting text, imageUrl

    else
      @_finishSubmitting text

  _finishSubmitting: (text, url) ->
    Meteor.call 'practiceCheckIn', LOI.characterId(), text, url, (error) =>
      @submitting false

      if error
        console.log error.message

      else
        FlowRouter.go 'journal'
