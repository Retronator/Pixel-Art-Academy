AE = Artificial.Everywhere

# A reactive object variable that allows you to react to updates made internally on the object. It is particularly
# useful to handle changes of objects from external libraries that are not reactive. We add a layer for reactive
# updates on top of that. For methods that access the object in the reactive wrapper, if you want to react only to
# changes of the whole object (when setting the variable and equals function returns false) you call the wrapper
# directly, and if you want to react also to object updates (manually signaled by someone else calling the updated())
# you call the withUpdates function to get the object from the wrapper.
#
# Example:
# scene = AE.ReactiveWrapper new THREE.Scene()
#
# # To react only to changes of the variable, call the reactive wrapper directly.
# Tracker.autorun =>
#   scene = @scene()
#   # Do something whenever the whole scene object is assigned or replaced.
#
# # To react to (re)assignments AND to manual updates, call the withUpdates function.
# Tracker.autorun =>
#   scene = @scene.withUpdates()
#   # Do something whenever the scene is changed or updated.
#
# # Someone that does an update of the variable signals that by calling updated.
# Tracker.autorun =>
#   scene = @scene()
#   scene.add someObject
#   @scene.updated()
#   # All the computations that rely on the wrapped object's change of state have been now called.
#
# Based on ReactiveField from PeerLibrary
# https://github.com/peerlibrary/meteor-reactive-field
#
class AE.ReactiveWrapper
  constructor: (initialValue, equalsFunc) ->
    value = new ReactiveVar initialValue, equalsFunc
    updatedDependency = new Tracker.Dependency()

    getterSetter = (newValue) ->
      if arguments.length > 0
        value.set newValue
        # We return the value as well, but we do not want to register a dependency.
        return Tracker.nonreactive =>
          value.get()

      value.get()

    # We mingle the prototype so that getterSetter instanceof ReactiveWrapper is true.
    if Object.setPrototypeOf
      Object.setPrototypeOf getterSetter, @constructor::
    else
      getterSetter.__proto__ = @constructor::

    getterSetter.toString = ->
      "ReactiveField{#{@()}}"

    getterSetter.apply = (obj, args) ->
      if args?.length > 0
        getterSetter args[0]
      else
        getterSetter()

    getterSetter.call = (obj, arg) ->
      if arguments.length > 1
        getterSetter arg
      else
        getterSetter()

    # Returns the value of the field that will also rerun the enclosing
    # computation every time the object is marked as updated.
    getterSetter.withUpdates = ->
      updatedDependency.depend()
      value.get()

    # Triggers recomputation of all computations that depend on the updates of the
    # field's value not set through the setter, such as direct underlying object changes.
    getterSetter.updated = ->
      updatedDependency.changed()

    return getterSetter
