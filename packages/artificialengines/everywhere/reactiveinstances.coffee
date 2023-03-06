AE = Artificial.Everywhere

# Creates instance of classes provided from a reactive source and destroys them when they are no longer necessary.
class AE.ReactiveInstances
  constructor: (sourceFunction, options = {}) ->
    reactiveInstances = new ReactiveField []

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf reactiveInstances, @constructor.prototype
    
    instances = []
    
    classes = new AE.ReactiveArray sourceFunction,
      added: (addedClass) =>
        instance = null
        Tracker.nonreactive => instance = new addedClass
        instances.push instance
        reactiveInstances instances
        
      removed: (removedClass) =>
        instance = _.find instances, instance instanceof removedClass
        instance.destroy?()
        _.pull instance
        reactiveInstances instances

    reactiveInstances.stop = ->
      classes.stop()
      instance.destroy?() for instance in instances

    return reactiveInstances
