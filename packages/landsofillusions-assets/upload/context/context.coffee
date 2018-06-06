LOI = LandsOfIllusions

class LOI.Assets.Upload.Context
  constructor: (@options) ->
    # Set upload limits on both server and client.
    Slingshot.fileRestrictions @options.name,
      maxSize: @options.maxSize
      allowedFileTypes: @options.fileTypes
