AE = Artificial.Everywhere

_.mixin
  thingId: (thingClassOrId) ->
    return thingClassOrId if _.isString thingClassOrId
    return thingClassOrId.id() if thingClassOrId.id?

    throw new AE.ArgumentException 'You must provide a thing class or id.'
