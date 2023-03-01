AB = Artificial.Base

class AB.VersionProperty
  @Types = {}
  @type = null
  
  @setType: (type) ->
    @type = type
    
    for type in @Types
      @["is#{type}"] = @type is type
