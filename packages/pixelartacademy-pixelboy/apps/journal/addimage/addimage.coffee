AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.AddImage extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Journal.AddImage'

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
      'click .cancel': @onClickCancel

  onClick: (event) ->
    # If click happened outside the dialog, return to journal.
    @_closeDialog() unless $(event.target).closest('.dialog').length

  onClickCancel: (event) ->
    @_closeDialog()

  _closeDialog: ->
    checkInComponent = @ancestorComponentOfType PAA.PixelBoy.Apps.Journal.CheckIn
    checkInComponent?.showAddImage false

  onSubmitCheckInForm: (event) ->
    event.preventDefault()

    @submitting true
    
    imageFile = @$('.image-file')[0]?.files[0]
    externalUrl = @$('.external-url').val()

    if externalUrl
      # We are doing a check-in using an external url.
      @_finishSubmitting externalUrl

    else if imageFile
      # We are checking-in by uploading a local image file.
      PAA.Practice.upload imageFile, (imageUrl) =>
        @_finishSubmitting imageUrl

  _finishSubmitting: (url) ->
    checkIn = @data()

    PAA.Practice.CheckIn.updateUrl checkIn._id, url, (error) =>
      @submitting false

      if error
        @errorMessage error.reason
        return

      @_closeDialog()

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
      PAA.Practice.CheckIn.getExternalUrlImage externalUrl, (error, result) =>
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
