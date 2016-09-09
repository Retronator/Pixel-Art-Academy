AT = Artificial.Telepathy

class AT.RemoteDocument extends Document
  @Meta: (@options) ->
    if @options.server and (@options.collectionName or @options.name)
      # Create a plural name since that's how PeerDB names its collections.
      @options.collectionName ?= "#{@options.name}s"

      # Create the mongo collection with the remote connection.
      @options.collection = new Mongo.Collection @options.collectionName,
        connection: @options.server.connection

    super @options
