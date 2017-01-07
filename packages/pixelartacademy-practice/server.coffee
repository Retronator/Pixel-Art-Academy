PAA = PixelArtAcademy

class PAA.Practice extends PAA.Practice
  # Setup Amazon Web Services API.
  if Meteor.settings.amazonWebServices
    Slingshot.createDirective 'checkIns', Slingshot.S3Storage,
      bucket: 'pixelartacademy'
      acl: 'public-read'
      AWSAccessKeyId: Meteor.settings.amazonWebServices.accessKey
      AWSSecretAccessKey: Meteor.settings.amazonWebServices.secret
      authorize: ->
        # Only logged in users can upload artworks.
        throw new Meteor.Error 'unauthorized', 'Unauthorized.' unless Meteor.userId()

        true

      key: (file) ->
        nameParts = file.name.split '.'

        # Store the file into the check-ins folder with a random name.
        "check-ins/#{Random.id()}.#{nameParts[1]}"

  else
    console.warn "You need to specify amazon web services key and secret in the settings file and don't forget to run the server with the --settings flag pointing to it."
