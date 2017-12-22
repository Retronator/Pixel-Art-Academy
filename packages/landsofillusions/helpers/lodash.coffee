AE = Artificial.Everywhere
LOI = LandsOfIllusions

_.mixin
  thingId: (thingClassOrId) ->
    return unless thingClassOrId

    return thingClassOrId if _.isString thingClassOrId
    return thingClassOrId.id() if thingClassOrId.id?

    throw new AE.ArgumentException 'You must provide a thing class or id.'

  thingClass: (thingClassOrId) ->
    return unless thingClassOrId

    return thingClassOrId if _.isFunction thingClassOrId
    return LOI.Adventure.Thing.getClassForId thingClassOrId if _.isString thingClassOrId
    return thingClassOrId.constructor if thingClassOrId instanceof LOI.Adventure.Thing

    throw new AE.ArgumentException 'You must provide a thing class or id.'

  thingIdAndClass: (thingClassOrId) ->
    [_.thingId thingClassOrId, _.thingClass thingClassOrId]
