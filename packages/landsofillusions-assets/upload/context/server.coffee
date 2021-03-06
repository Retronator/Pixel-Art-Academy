AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Assets.Upload.Context extends LOI.Assets.Upload.Context
  constructor: ->
    super arguments...

    # Require Amazon Web Services credentials.
    unless Meteor.settings.amazonWebServices
      console.warn "Failed creating upload context #{@options.name}. You need to specify amazon web services key and secret in the settings file."
      return

    # On the server we create the upload directive.
    directiveOptions =
      bucket: 'pixelartacademy'
      acl: 'public-read'
      AWSAccessKeyId: Meteor.settings.amazonWebServices.accessKey
      AWSSecretAccessKey: Meteor.settings.amazonWebServices.secret
      authorize: =>
        # Only logged in users can upload artworks.
        throw new AE.UnauthorizedException "You need to be logged in to upload files." unless Meteor.userId()

        true

      key: (file) =>
        nameParts = file.name.split '.'
        extension = _.last nameParts

        # Store the file into the desired folder with a random name.
        "#{@options.folder}/#{Random.id()}.#{extension}"

    directiveOptions.cacheControl = @options.cacheControl if @options.cacheControl

    Slingshot.createDirective @options.name, Slingshot.S3Storage, directiveOptions
