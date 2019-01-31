AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.Mesh.ValueField
  constructor: (parent, field, value) ->
    updatedDependency = new Tracker.Dependency

    valueField = (newValue) =>
      unless newValue is undefined
        value = newValue
        updatedDependency.changed()
        parent.contentUpdated()
        return

      updatedDependency.depend()
      value

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf valueField, @constructor.prototype
    
    valueField.changedLocally = ->
      updatedDependency.changed()

    valueField.save = (saveData) ->
      return if value is undefined 
      saveData[field] = value

    valueField.apply = (obj, args) ->
      if args?.length > 0
        valueField args[0]

      else
        valueField()

    valueField.call = (obj, arg) ->
      if arguments.length > 1
        valueField arg

      else
        valueField()

    return valueField
