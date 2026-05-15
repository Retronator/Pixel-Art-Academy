AB = Artificial.Base

class AB.VersionProperty
  @Types = {}
  
  @initialize: ->
    @type = new ReactiveField null
  
  @setType: (value) ->
    @type value
    
    for type of @Types
      propertyName = "is#{type}"
      @[propertyName] = type is value
  
      do (propertyName) =>
        Template.registerHelper propertyName, =>
          @[propertyName]
