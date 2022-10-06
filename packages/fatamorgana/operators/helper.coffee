AM = Artificial.Mirage
FM = FataMorgana

class FM.Helper extends FM.Operator
  constructor: ->
    super arguments...
    
    # Create a getter/setter instance.
    getterSetter = ->
      getterSetter.value arguments...
      
    # Transfer any fields to the instance.
    for key, value of @
      getterSetter[key] = value

    # Change the prototype of the instance.
    Object.setPrototypeOf getterSetter, @constructor.prototype

    # Return the function instead of constructed object. Return must be explicit.
    return getterSetter

  value: ->
    # Override to provide a getter/setter for this helper.
    @data.value arguments...
