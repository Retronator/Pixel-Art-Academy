# Comparing arrays of components by reference. This might not be really necessary
# to do, because all operations we officially support modify length of the array
# (add a new component or remove an old one). But if somebody is modifying the
# reactive variable directly we want a sane behavior. The default ReactiveVar
# equality always returns false when comparing any non-primitive values. Because
# the order of components in the children array is arbitrary we could further
# improve this comparison to compare arrays as sets, ignoring the order. Or we
# could have some canonical order of components in the array.
arrayReferenceEquals = (a, b) ->
  return false if a.length isnt b.length

  for i in [0...a.length]
    return false if a[i] isnt b[i]

  true

createMatcher = (propertyOrMatcherOrFunction) ->
  if _.isString propertyOrMatcherOrFunction
    property = propertyOrMatcherOrFunction
    propertyOrMatcherOrFunction = (child, parent) =>
      property of child

  else if not _.isFunction propertyOrMatcherOrFunction
    assert _.isObject propertyOrMatcherOrFunction
    matcher = propertyOrMatcherOrFunction
    propertyOrMatcherOrFunction = (child, parent) =>
      for property, value of matcher
        return false unless property of child

        if _.isFunction child[property]
          return false unless child[property]() is value
        else
          return false unless child[property] is value

      true

  propertyOrMatcherOrFunction

class ComponentsNamespace
  # We have a special field for components. This allows us to have the namespace with the same name
  # as a component, without overriding anything in the component (we do not want to use component
  # object as a namespace object).
  @COMPONENTS_FIELD: ''

getPathAndName = (name) ->
  assert name

  path = name.split '.'

  name = path.pop()

  assert name

  {path, name}

getNamespace = (components, path) ->
  assert _.isObject components
  assert _.isArray path

  match = components

  while (segment = path.shift())?
    match = match[segment]
    return null unless _.isObject match

  return null unless _.isObject match

  match or null

createNamespace = (components, path) ->
  assert _.isObject components
  assert _.isArray path

  match = components

  while (segment = path.shift())?
    match[segment] = new components.constructor() unless segment of match
    match = match[segment]
    assert _.isObject match

  assert _.isObject match

  match

getComponent = (components, name) ->
  assert _.isObject components

  return null unless name

  {path, name} = getPathAndName name

  namespace = getNamespace components, path
  return null unless namespace

  namespace[components.constructor.COMPONENTS_FIELD]?[name] or null

setComponent = (components, name, component) ->
  assert _.isObject components
  assert name
  assert component

  {path, name} = getPathAndName name

  namespace = createNamespace components, path

  namespace[components.constructor.COMPONENTS_FIELD] ?= new components.constructor()
  assert name not of namespace[components.constructor.COMPONENTS_FIELD]
  namespace[components.constructor.COMPONENTS_FIELD][name] = component

componentChildrenDeprecationWarning = false
componentChildrenWithDeprecationWarning = false
addComponentChildDeprecationWarning = false
removeComponentChildDeprecationWarning = false

componentParentDeprecationWarning = false

childrenComponentsDeprecationWarning = false
childrenComponentsWithDeprecationWarning = false

class BaseComponent
  @components: new ComponentsNamespace()

  @register: (componentName, componentClass) ->
    throw new Error "Component name is required for registration." unless componentName

    # To allow calling @register 'name' from inside a class body.
    componentClass ?= @

    throw new Error "Component '#{ componentName }' already registered." if getComponent @components, componentName

    # The last condition is to make sure we do not throw the exception when registering a subclass.
    # Subclassed components have at this stage the same component as the parent component, so we have
    # to check if they are the same class. If not, this is not an error, it is a subclass.
    if componentClass.componentName() and componentClass.componentName() isnt componentName and getComponent(@components, componentClass.componentName()) is componentClass
      throw new Error "Component '#{ componentName }' already registered under the name '#{ componentClass.componentName() }'."

    componentClass.componentName componentName
    assert.equal componentClass.componentName(), componentName

    setComponent @components, componentName, componentClass

    # To allow chaining.
    @

  @getComponent: (componentsNamespace, componentName) ->
    unless componentName
      componentName = componentsNamespace
      componentsNamespace = @components

    # If component is missing, just return a null.
    return null unless componentName

    # But otherwise throw an exception.
    throw new Error "Component name '#{ componentName }' is not a string." unless _.isString componentName

    getComponent componentsNamespace, componentName

  # Component name is set in the register class method. If not using a registered component and a component name is
  # wanted, component name has to be set manually or this class method should be overridden with a custom implementation.
  # Care should be taken that unregistered components have their own name and not the name of their parent class, which
  # they would have by default. Probably component name should be set in the constructor for such classes, or by calling
  # componentName class method manually on the new class of this new component.
  @componentName: (componentName) ->
    # Setter.
    if componentName
      @_componentName = componentName
      # To allow chaining.
      return @

    # Getter.
    @_componentName or null

  # We allow access to the component name through a method so that it can be accessed in templates in an easy way.
  # It should never be overridden. The implementation should always be exactly the same as class method implementation.
  componentName: ->
    # Instance method is just a getter, not a setter as well.
    @constructor.componentName()

  # The order of components is arbitrary and does not necessary match siblings relations in DOM.
  # nameOrComponent is optional and it limits the returned children only to those.
  childComponents: (nameOrComponent) ->
    @_componentInternals ?= {}
    @_componentInternals.childComponents ?= new ReactiveField [], arrayReferenceEquals

    # Quick path. Returns a shallow copy.
    return (child for child in @_componentInternals.childComponents()) unless nameOrComponent

    if _.isString nameOrComponent
      @childComponentsWith (child, parent) =>
        child.componentName() is nameOrComponent
    else
      @childComponentsWith (child, parent) =>
        # nameOrComponent is a class.
        return true if child.constructor is nameOrComponent

        # nameOrComponent is an instance, or something else.
        return true if child is nameOrComponent

        false

  # The order of components is arbitrary and does not necessary match siblings relations in DOM.
  # Returns children which pass a predicate function.
  childComponentsWith: (propertyOrMatcherOrFunction) ->
    assert propertyOrMatcherOrFunction

    propertyOrMatcherOrFunction = createMatcher propertyOrMatcherOrFunction

    results = new ComputedField =>
      child for child in @childComponents() when propertyOrMatcherOrFunction.call @, child, @
    ,
      arrayReferenceEquals

    results()

  addChildComponent: (childComponent) ->
    @_componentInternals ?= {}
    @_componentInternals.childComponents ?= new ReactiveField [], arrayReferenceEquals
    @_componentInternals.childComponents Tracker.nonreactive =>
      @_componentInternals.childComponents().concat [childComponent]

    # To allow chaining.
    @

  removeChildComponent: (childComponent) ->
    @_componentInternals ?= {}
    @_componentInternals.childComponents ?= new ReactiveField [], arrayReferenceEquals
    @_componentInternals.childComponents Tracker.nonreactive =>
      _.without @_componentInternals.childComponents(), childComponent

    # To allow chaining.
    @

  parentComponent: (parentComponent) ->
    @_componentInternals ?= {}
    # We use reference equality here. This makes reactivity not invalidate the
    # computation if the same component instance (by reference) is set as a parent.
    @_componentInternals.parentComponent ?= new ReactiveField null, (a, b) -> a is b

    # Setter.
    unless _.isUndefined parentComponent
      @_componentInternals.parentComponent parentComponent
      # To allow chaining.
      return @

    # Getter.
    @_componentInternals.parentComponent()

  @renderComponent: (parentComponent) ->
    throw new Error "Not implemented"

  renderComponent: (parentComponent) ->
    throw new Error "Not implemented"

  @extendComponent: (constructor, methods) ->
    currentClass = @

    unless _.isFunction constructor
      methods = constructor
      constructor = ->
        constructor.__super__.constructor.apply @, arguments

    constructor:: = Object.create currentClass::
    constructor::constructor = constructor

    # We use "own" here because this is how CoffeeScript extends the class.
    for own property, value of currentClass
      constructor[property] = value
    constructor.__super__ = currentClass::

    # We expect the plain object of methods here, but if something
    # else is passed, we use only "own" properties.
    for own property, value of methods or {}
      constructor::[property] = value

    constructor

  # Deprecated method names.
  # TODO: Remove them in the future.

  # @deprecated Use childComponents instead.
  componentChildren: (args...) ->
    unless componentChildrenDeprecationWarning
      componentChildrenDeprecationWarning = true
      console?.warn "componentChildren has been deprecated. Use childComponents instead."

    @childComponents args...

  # @deprecated Use childComponentsWith instead.
  componentChildrenWith: (args...) ->
    unless componentChildrenWithDeprecationWarning
      componentChildrenWithDeprecationWarning = true
      console?.warn "componentChildrenWith has been deprecated. Use childComponentsWith instead."

    @childComponentsWith args...

  # @deprecated Use addChildComponent instead.
  addComponentChild: (args...) ->
    unless addComponentChildDeprecationWarning
      addComponentChildDeprecationWarning = true
      console?.warn "addComponentChild has been deprecated. Use addChildComponent instead."

    @addChildComponent args...

  # @deprecated Use removeChildComponent instead.
  removeComponentChild: (args...) ->
    unless removeComponentChildDeprecationWarning
      removeComponentChildDeprecationWarning = true
      console?.warn "removeComponentChild has been deprecated. Use removeChildComponent instead."

    @removeChildComponent args...

  # @deprecated Use parentComponent instead.
  componentParent: (args...) ->
    unless componentParentDeprecationWarning
      componentParentDeprecationWarning = true
      console?.warn "componentParent has been deprecated. Use parentComponent instead."

    @parentComponent args...

  # @deprecated Use childComponents instead.
  childrenComponents: (args...) ->
    unless componentChildrenDeprecationWarning
      componentChildrenDeprecationWarning = true
      console?.warn "childrenComponents has been deprecated. Use childComponents instead."

    @childComponents args...

  # @deprecated Use childComponentsWith instead.
  childrenComponentsWith: (args...) ->
    unless componentChildrenWithDeprecationWarning
      componentChildrenWithDeprecationWarning = true
      console?.warn "childrenComponentsWith has been deprecated. Use childComponentsWith instead."

    @childComponentsWith args...
