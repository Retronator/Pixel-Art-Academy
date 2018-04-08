AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions

Nodes = LOI.Adventure.Script.Nodes

class LOI.Memory.Action extends AM.Document
  @id: -> 'LandsOfIllusions.Memory.Action'
  # type: constructor type for inheritance
  # time: when this action was done
  # timelineId: timeline when the action was done
  # locationId: location where the action was done
  # contextId: optional context in which the action was done
  # character: character who did this action
  #   _id
  #   avatar
  #     fullName
  #     color
  # memory: optional memory this action belongs to.
  #   _id
  # content: extra information defining what was done in this action
  @type: @id()

  # Override register to do action initialization as well.
  @register: ->
    super

    translationNamespace = @type

    # On the server, create this avatar's translated names.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        for translationKey of @translationKeys
          defaultText = _.propertyValue @, translationKey
          AB.createTranslation translationNamespace, translationKey, defaultText if defaultText

  @register @type, @
  
  @Meta
    name: @id()
    fields: =>
      memory: @ReferenceField LOI.Memory, [], true, 'actions', ['time', 'character', 'type', 'content']
      character: @ReferenceField LOI.Character, ['avatar.fullName', 'avatar.color'], false

  # A place for actions to add their content patterns.
  @contentPatterns = {}

  @registerContentPattern: (type, pattern) ->
    @contentPatterns[type] = pattern

  # Methods

  @do: @method 'do'
  @changeContent: @method 'changeContent'

  # Subscriptions

  @forMemory: @subscription 'forMemory'
  @recentForLocation: @subscription 'recentForLocation'

  @translationKeys:
    startDescription: 'startDescription'
    activeDescription: 'activeDescription'
    endDescription: 'endDescription'

  startDescription: -> @_translateIfAvailable @constructor.translationKeys.startDescription
  activeDescription: -> @_translateIfAvailable @constructor.translationKeys.activeDescription
  endDescription: -> @_translateIfAvailable @constructor.translationKeys.endDescription

  _translateIfAvailable: (key) ->
    # Make sure the property is specified (we could have some stale translations lying around).
    return unless @constructor[key]

    # We assume the translation is already subscribed from the text interface.
    translation = AB.Translation.documents.findOne
      namespace: @constructor.type
      key: key

    return unless translation

    translated = translation.translate()

    if translated.language then translated.text else null

  # By default, start and end actions output the description to the narrative.
  start: (person) ->
    @_writeDescription @startDescription(), person

  end: (person) ->
    @_writeDescription @endDescription(), person

  _writeDescription: (description, person) ->
    return unless description

    # Format person into the description.
    description = LOI.Character.formatText description, 'person', person

    narrativeLine = new Nodes.NarrativeLine
      line: description

    LOI.adventure.director.startNode narrativeLine
