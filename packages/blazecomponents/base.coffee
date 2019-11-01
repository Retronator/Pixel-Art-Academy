# @nodoc
# TODO: Deduplicate between blaze component and common component packages.
createMatcher = (propertyOrMatcherOrFunction, checkMixins) ->
  if _.isString propertyOrMatcherOrFunction
    property = propertyOrMatcherOrFunction
    propertyOrMatcherOrFunction = (child, parent) =>
      # If child is parent, we might get into an infinite loop if this is
      # called from getFirstWith, so in that case we do not use getFirstWith.
      if checkMixins and child isnt parent and child.getFirstWith
        !!child.getFirstWith null, property
      else
        property of child

  else if not _.isFunction propertyOrMatcherOrFunction
    assert _.isObject propertyOrMatcherOrFunction
    matcher = propertyOrMatcherOrFunction
    propertyOrMatcherOrFunction = (child, parent) =>
      for property, value of matcher
        # If child is parent, we might get into an infinite loop if this is
        # called from getFirstWith, so in that case we do not use getFirstWith.
        if checkMixins and child isnt parent and child.getFirstWith
          childWithProperty = child.getFirstWith null, property
        else
          childWithProperty = child if property of child
        return false unless childWithProperty

        if _.isFunction childWithProperty[property]
          return false unless childWithProperty[property]() is value
        else
          return false unless childWithProperty[property] is value

      true

  propertyOrMatcherOrFunction

# A common base class for both {CommonComponent} and {CommonMixin}.
class share.CommonComponentBase extends BlazeComponent
  # A version of [subscribe](https://github.com/peerlibrary/meteor-blaze-components#user-content-reference_instance_subscribe)
  # which logs errors to the console if no error callback is specified.
  #
  # @return [SubscriptionHandle]
  subscribe: (name, args...) ->
    lastArgument = args[args.length - 1]

    callbacks = {}
    if _.isFunction lastArgument
      callbacks.onReady = args.pop()
    else if _.any [lastArgument?.onReady, lastArgument?.onError, lastArgument?.onStop], _.isFunction
      callbacks = args.pop()

    unless callbacks.onError or callbacks.onStop
      callbacks.onStop = (error) =>
        console.error "Subscription '#{name}' error", error if error

    args.push callbacks

    super name, args...

  # Traverses the components tree towards the root and returns the first component which matches the
  # provided component name, class, or instance.
  #
  # Returns `null` if such component is not found.
  #
  # It returns a strict ancestor, it does not check the component itself first.
  #
  # @param [String, Class<BlazeComponent>, BlazeComponent] nameOrComponent
  # @return [BlazeComponent]
  ancestorComponent: (nameOrComponent) ->
    if _.isString nameOrComponent
      @ancestorComponentWith (child, parent) =>
        child.componentName() is nameOrComponent
    else
      @ancestorComponentWith (child, parent) =>
        # nameOrComponent is a class.
        return true if child.constructor is nameOrComponent

        # nameOrComponent is an instance, or something else.
        return true if child is nameOrComponent

        false

  # Traverses the components tree towards the root and finds the first component which matches a
  # `propertyOrMatcherOrFunction` predicate.
  #
  # Returns `null` if such component is not found.
  #
  # A `propertyOrMatcherOrFunction` predicate can be:
  # * a property name string, in this case the first component which has a property with the given name
  # (or its mixins do) is matched
  # * a matcher object specifying mapping between property names and their values, in this case the first component
  # which (or its mixins) has all properties from the matcher object equal to given values is matched
  # (if a property is a function, it is called and its return value is compared instead)
  # * a function which receives `(ancestor, component)` with `this` bound to `component`, in this case the first component
  # for which the function returns a true value is matched
  #
  # It returns a strict ancestor, it does not check the component itself first.
  #
  # @param [String, Object, Function] propertyOrMatcherOrFunction
  # @return [BlazeComponent]
  ancestorComponentWith: (propertyOrMatcherOrFunction) ->
    assert propertyOrMatcherOrFunction

    # When checking for properties we check mixins as well.
    propertyOrMatcherOrFunction = createMatcher propertyOrMatcherOrFunction, true

    component = @component().parentComponent()
    while component and not propertyOrMatcherOrFunction.call @, component, @
      component = component.parentComponent()
    component

  # Traverses the components tree towards the root and finds the first component (or its mixin) with a property `propertyName`,
  # and if it is a function, calls it with `args` arguments, otherwise returns the value of the property.
  #
  # Returns `undefined` if such component is not found.
  #
  # It calls a strict ancestor, it does not check the component itself first.
  #
  # @param [String] propertyName
  # @return [anything]
  callAncestorWith: (propertyName, args...) ->
    assert _.isString propertyName

    component = @ancestorComponentWith propertyName

    # We are calling callFirstWith on the component because here we are not
    # traversing mixins but components themselves so we have to recurse once more.
    # Components should always have callFirstWith.
    component?.callFirstWith null, propertyName, args...
