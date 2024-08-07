LOI = LandsOfIllusions

class LOI.Assets.Upload.Context
  @CacheControl:
    PreventCaching: 'no-store'
    RequireRevalidation: 'no-cache, max-age=0'
    StaticAsset: 'public, max-age=604800, immutable'

  @FileTypes:
    Images: [
      'image/png'
      'image/apng'
      'image/jpeg'
      'image/gif'
    ]

  constructor: (@options) ->
    # Set upload limits on both server and client.
    Slingshot.fileRestrictions @options.name,
      maxSize: @options.maxSize
      allowedFileTypes: @options.fileTypes
