RA = Retronator.Accounts
PADB = PixelArtDatabase

Webshot = require 'webshot'
Uploader = require('s3-streaming-upload').Uploader
PassThrough = require('stream').PassThrough

PADB.Website.renderRetronatorDailyFeaturePreview.method (id) ->
  check id, Match.DocumentId
  RA.authorizeAdmin()

  website = PADB.Website.documents.findOne id
  throw new AE.ArgumentException "Website can't be found." unless website

  # Get image url.
  imageUrl = website.retronatorDailyFeature?.preview?.imageUrl

  if imageUrl
    filename = imageUrl.match(/.*\/(websites.*)/)[1]

  else
    filename = "websites/#{Random.id()}.png"

  console.log "Rendering website", website.url, "…"

  renderStream = Webshot website.url, null,
    defaultWhiteBackground: true
    customCSS: website.retronatorDailyFeature?.preview?.customCss
    windowSize:
      width: website.retronatorDailyFeature?.preview?.width or 1024
      height: website.retronatorDailyFeature?.preview?.height or 1024

  uploadingStarted = false

  renderStream.on 'data', (chunk) ->
    return if uploadingStarted
    uploadingStarted = true

    console.log "Website", website.url, "rendered. Uploading to", filename, "…"

  passthrough = new PassThrough()
  renderStream.pipe passthrough

  uploader = new Uploader
    accessKey: Meteor.settings.amazonWebServices.accessKey
    secretKey: Meteor.settings.amazonWebServices.secret
    bucket: 'pixelartacademy'
    objectName: filename
    stream: renderStream
    objectParams:
      ACL: 'public-read'
      Body: passthrough
      ContentType: 'image/png'

  # Wrap in fiber so we can update the document on successful upload.
  send = Meteor.wrapAsync uploader.send.bind uploader

  send (error) ->
    if error
      console.error "Website preview render for", website.url, "encountered an error on upload.", error
      return

    console.log "Upload complete for", website.url

    # Update the url if needed.
    unless imageUrl
      PADB.Website.documents.update id,
        $set: 'retronatorDailyFeature.preview.imageUrl': "https://pixelartacademy.s3.amazonaws.com/#{filename}"
