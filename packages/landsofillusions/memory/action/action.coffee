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
  # memory: optional memory this action belongs to
  #   _id
  # isMemorable: boolean weather this action is being memorized even without a memory
  # content: extra information defining what was done in this action, specified in inherited actions

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
  
  @Meta
    name: @id()
    fields: =>
      memory: @ReferenceField LOI.Memory, [], false, 'actions', ['time', 'character', 'type', 'content', 'memory']
      character: @ReferenceField LOI.Character, ['avatar.fullName', 'avatar.color'], false

  @type: @id()
  @register @type, @

  # A place for actions to add their content patterns.
  @contentPatterns = {}

  @registerContentPattern: (type, pattern) ->
    @contentPatterns[type] = pattern

  @isMemorable: -> false # Override to persist actions of this type even when used outside of memories.
  @retainDuration: -> false # Override with number of seconds actions of this type are retained when not memorable.

  # Methods

  @do: @method 'do'
  @updateTimeAndSituation: @method 'updateTimeAndSituation'
  @updateContent: @method 'updateContent'

  # Subscriptions

  @forMemory: @subscription 'forMemory'
  @recentForTimelineLocation: @subscription 'recentForTimelineLocation'
  @recentForCharacter: @subscription 'recentForCharacter'
  @recentForCharacters: @subscription 'recentForCharacters'

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
    namespace = @constructor.type
    translation = AB.existingTranslation namespace, key

    return unless translation

    translated = translation.translate()

    if translated.language then translated.text else null

  start: (person) -> @_runScript person, @createStartScript
  end: (person) -> @_runScript person, @createEndScript

  _runScript: (person, createScriptFunction) ->
    Tracker.autorun (computation) =>
      # Wait until person is ready.
      return unless person.ready()
      computation.stop()

      script = createScriptFunction.call @, person
      LOI.adventure.director.startBackgroundNode script if script

  # Override to provide what happens when an action is started or ends. 
  # By default, start and end actions output the description to the narrative.
  createStartScript: (person, nextNode, nodeOptions) ->
    @_createDescriptionScript person, @startDescription(), nextNode, nodeOptions

  createEndScript: (person, nextNode, nodeOptions) ->
    @_createDescriptionScript person, @endDescription(), nextNode, nodeOptions

  _createDescriptionScript: (person, description, nextNode, nodeOptions) ->
    return unless description

    # Format person into the description.
    description = LOI.Character.formatText description, 'person', person
    
    options = _.extend {}, nodeOptions,
      line: description
      next: nextNode

    new Nodes.NarrativeLine options

  shouldSkipTransition: (oldAction) ->
    # Override to determine when transitions between distinct actions are not necessary.
    false

  onCommand: (person, commandResponse) -> # Override to listen to commands.
