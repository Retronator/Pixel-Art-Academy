AB = Artificial.Babel
LOI = LandsOfIllusions

class LOI.Character.Behavior.FocalPoint extends LOI.Character.Part
  # Prepares a focal point on the server.
  @create: (options) ->
    # Transform name and descriptions into translation documents.
    options.name =
      _id: @_createTranslation options.key, 'name', options.name

  # Inserts a focal point for an inherited item with metadata set on the class.
  @createSelf: ->
    @create @

  @_createTranslation: (focalPointKey, translationKey, defaultText) ->
    namespace = "LandsOfIllusions.Character.Behavior.FocalPoint.#{focalPointKey}"
    AB.createTranslation namespace, translationKey, defaultText
