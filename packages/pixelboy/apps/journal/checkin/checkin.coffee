AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.CheckIn extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Journal.CheckIn'

  onCreated: ->
    super

    @submitting = new ReactiveField false

    @imagePreviewUrl = new ReactiveField null
    @errorMessage = new ReactiveField null
    
  onRendered: ->
    $('body').addClass('disable-scrolling')

  onDestroyed: ->
    $('body').removeClass('disable-scrolling')

  # Helpers

  # Events

  events: ->
    super.concat
      'click': @onClick
      'submit .check-in-form': @onSubmitCheckInForm
      'input .external-url': @onInputExternalUrl
      'change .image-file': @onChangeImageFile

  onClick: (event) ->
    # If click happened outside the dialog, return to journal.
    FlowRouter.go 'pixelboy', app: 'journal' unless $(event.target).closest('.dialog').length

  onSubmitCheckInForm: (event) ->
    event.preventDefault()

    @submitting true

    text = @$('.text').val()
    imageFile = @$('.image-file')[0]?.files[0]
    externalUrl = @$('.external-url').val()

    console.log "text is", text

    if externalUrl
      # We are doing a check-in using an external url.
      @_finishSubmitting text, externalUrl

    else if imageFile
      # We are checking-in by uploading a local image file.
      PAA.Practice.upload imageFile, (imageUrl) =>
        @_finishSubmitting text, imageUrl

    else
      # This is a text-only check-in.
      @_finishSubmitting text

  _finishSubmitting: (text, url) ->
    Meteor.call 'PixelArtAcademy.Practice.CheckIn.insert', LOI.characterId(), text, url, (error) =>
      @submitting false

      if error
        @errorMessage error.reason
        return

      # Check-in succeeded, so return back to the journal.
      FlowRouter.go 'pixelboy', app: 'journal'

  onInputExternalUrl: (event) ->
    @updatePreviewImage()

  onChangeImageFile: (event) ->
    @updatePreviewImage()

  updatePreviewImage: ->
    # Clear the image and error.
    @errorMessage null
    @imagePreviewUrl null

    externalUrl = @$('.external-url').val()

    if externalUrl
      Meteor.call 'PixelArtAcademy.Practice.CheckIn.getExternalUrlImage', externalUrl, (error, result) =>
        if error
          @errorMessage error.reason
          return

        @imagePreviewUrl result

      return

    # There is no external url, so fall back to the uploaded image.
    imageFile = @$('.image-file')[0]?.files[0]

    # Generate local image preview.
    return unless imageFile

    reader = new FileReader()

    reader.onload = (event) =>
      @imagePreviewUrl event.target.result

    reader.readAsDataURL imageFile


