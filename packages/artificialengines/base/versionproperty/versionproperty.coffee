AB = Artificial.Base

class AB.VersionProperty
  @Types = {}
  @type = null
  
  @setType: (type) ->
    @type = type
    
    for type of @Types
      propertyName = "is#{type}"
      @[propertyName] = @type is type
  
      do (propertyName) =>
        Template.registerHelper propertyName, =>
          @[propertyName]
