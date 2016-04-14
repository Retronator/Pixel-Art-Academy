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
      'input .external-url': @getExternalImgUrl
      'change .image-file': @generateLocalImagePreview

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

  getExternalImgUrl: (event) ->
    url = event.currentTarget.value
    externalImgUrl = null
    imgPreview = $('.image-preview')
    placeholder = 'http://placehold.it/350x150?text=your+art'
    errorIndicator = $('.preview-error')

    if /twitter\.com/.test(url)
      id = url.split('/status/')[1]
      Meteor.call 'getImgFromTweet', id, (error, data) =>
        if !error
          externalImgUrl = data.entities.media[0].media_url_https
          imgPreview.attr('src', externalImgUrl)
          errorIndicator.empty()
        else
          imgPreview.attr('src', placeholder)
          errorIndicator.html('There was an error communicating with the server. Either the tweet doesn\'t exist, or the server is down - try again later!')

    else
      imgPreview.attr('src', placeholder)
      errorIndicator.html('Error! Can\'t parse that URL - try again!')

  generateLocalImagePreview: (event) ->
    if event.currentTarget.files && event.currentTarget.files[0]
      reader = new FileReader();

      reader.onload = (e) ->
        $('.image-preview').attr('src', e.target.result)

      reader.readAsDataURL(event.currentTarget.files[0]);
