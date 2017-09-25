AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Behavior.Personality.Trait extends LOI.Character.Part
  # We keep trait information in a local collection with documents structured as:
  #
  # primaryFactor
  #   type: type number 1-5
  #   sign: 1 or -1
  # secondaryFactor
  #   type: type number 1-5
  #   sign: 1 or -1
  # key
  @documents: new Mongo.Collection null

  # Prepares trait on the server.
  @create: (options) ->
    # Transform name and descriptions into translation documents.
    options.name =
      _id: @_createTranslation options.key, 'name', options.name

  # Inserts an item for an inherited item with metadata set on the class.
  @createSelf: ->
    @create @

  @_createTranslation: (traitKey, translationKey, defaultText) ->
    namespace = "LandsOfIllusions.Character.Behavior.Personality.Trait.#{traitKey}"
    AB.createTranslation namespace, translationKey, defaultText
