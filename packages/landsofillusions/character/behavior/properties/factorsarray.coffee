LOI = LandsOfIllusions

class LOI.Character.Behavior.Personality.FactorsArray extends LOI.Character.Part.Property.Array
  getFactorPart: (type) ->
    factorPart = @partsByOrder()[type]
    return factorPart if factorPart

    # The factor part does not exist yet (since there is no data for it), so we create it.
    Tracker.nonreactive =>
      partDataLocation = @options.dataLocation.child type
  
      partDataLocation.saveMetaData
        type: @options.type
  
      factorPartClass = LOI.Character.Part.getClassForType @options.type
      factorPart = factorPartClass.create
        dataLocation: partDataLocation
        parent: @
  
      # Set the factor index.
      factorPart.properties.index.options.dataLocation type

    factorPart
