AM = Artificial.Mirage
AB = null

Meteor.startup ->
  AB = Artificial.Babel

class AM.Component extends CommonComponent
  onCreated: ->
    super

    # Artificial Babel
    AB.subscribeComponent @

  onDestroyed: ->
    AB.unsubscribeComponent @

  # Modified firstNode and lastNode helpers that skip over text nodes. Useful if the component doesn't have
  # persistent first and last nodes, since the original helpers will point to surrounding text elements.
  firstElementNode: ->
    firstNode = @firstNode()

    # Not using nextElementSibling because it is not yet widely supported on text nodes.
    while firstNode and firstNode.nodeType isnt Node.ELEMENT_NODE
      firstNode = firstNode.nextSibling

    firstNode

  lastElementNode: ->
    lastNode = @lastNode()

    # Not using previousElementSibling because it is not yet widely supported on text nodes.
    while lastNode and lastNode.nodeType isnt Node.ELEMENT_NODE
      lastNode = lastNode.previousSibling

    lastNode

  # Returns a jQuery object with all the top-level nodes within the component, ignoring possible initial and last
  # non-element nodes.
  $children: ->
    return $() unless @isRendered()

    firstNode = @firstElementNode()
    lastNode = @lastElementNode()

    if firstNode is lastNode
      $(firstNode)
    else
      $(firstNode).nextUntil(lastNode).addBack().add(lastNode)

  # Traversal

  isDescendantOf: (component) ->
    current = @

    while current.componentParent()
      current = current.componentParent()
      return true if current is component

    return false

  componentChildrenOfType: (constructor) ->
    @componentChildrenWith (child) ->
      child instanceof constructor

  # Code based on childComponentsWith.
  parentDataWith: (propertyOrMatcherOrFunction) ->
    if _.isString propertyOrMatcherOrFunction
      property = propertyOrMatcherOrFunction
      propertyOrMatcherOrFunction = (data) =>
        property of data

    else if not _.isFunction propertyOrMatcherOrFunction
      assert _.isObject propertyOrMatcherOrFunction
      matcher = propertyOrMatcherOrFunction
      propertyOrMatcherOrFunction = (data) =>
        for property, value of matcher
          return false unless property of data

          if _.isFunction parent[property]
            return false unless parent[property]() is value

          else
            return false unless parent[property] is value

        true

    level = 0

    loop
      data = Template.parentData level
      return null unless data
      return data if propertyOrMatcherOrFunction.call data, data

      level++

  # Helpers

  $equals: (args...) ->
    # Removing kwargs.
    args.pop() if args[args.length - 1] instanceof Spacebars.kw

    _.uniq(args).length is 1

  $is: (args...) ->
    @$equals args...

  $gt: (args...) ->
    return unless _.isNumber args[0] and _.isNumber args[1]

    args[0] > args[1]

  $lt: (args...) ->
    return unless _.isNumber args[0] and _.isNumber args[1]

    args[0] < args[1]

  # Styles

  # Converts a style object to a css string. Useful in templates
  # when you need just the string and not a style attribute.
  css: (styleObject) ->
    AM.CSSHelper.objectToString styleObject

  # Converts a style object to a css attribute. Useful in templates as a helper to construct the style attribute.
  style: (styleObject) ->
    style: AM.CSSHelper.objectToString styleObject

  # Converts an array of style classes into a class attribute. It doesn't return anything
  # if the array is empty (or null) so that class attribute is not unnecessarily created.
  class: (styleClassesArray) ->
    if styleClassesArray?.length
      class: styleClassesArray.join ' '

  # Artificial Babel

  # Translates the provided key with Artificial Babel.
  translate: (key) ->
    AB.translateForComponent @, key

  # Spacebars shorthand for translate that returns just the text of the translation.
  t7e: (translationOrKey) ->
    if translationOrKey instanceof AB.Translation
      translation = translationOrKey
      AB.translate(translation).text
      
    else
      translationKey = translationOrKey
      @translate(translationKey).text
