LOI = LandsOfIllusions
AM = Artificial.Mummification

Nodes = LOI.Adventure.Script.Nodes

class LOI.Memory.Actions.Talk extends LOI.Memory.Action
  # content:
  #   person: thing or profile ID the profile is talking to
  @type: 'LandsOfIllusions.Memory.Actions.Talk'
  @registerType @type, @

  @registerContentPattern @type, person: String

  @retainDuration: -> 60 # seconds

  @startDescription: ->
    "_person_ starts talking to _targetPerson_."

  @activeDescription: ->
    "_They_ _are_ talking to _targetPerson_."

  startDescription: -> @_formatDescription @constructor.translationKeys.startDescription
  activeDescription: -> @_formatDescription @constructor.translationKeys.activeDescription

  _formatDescription: (translationKey) ->
    return unless targetPerson = @_getTargetPerson()

    description = @_translateIfAvailable translationKey
    LOI.Profile.formatText description, 'targetPerson', targetPerson, true

  createStartScript: (person, nextNode, nodeOptions) ->
    return unless targetPerson = @_getTargetPerson()

    animationNode = new Nodes.Animation _.extend {}, nodeOptions,
      next: nextNode
      callback: (complete) =>
        # The profile should approach the target profile.
        person.avatar.walkTo
          target: targetPerson
          onCompleted: =>
            # The profiles should turn towards each other.
            person.avatar.lookAt targetPerson
            targetPerson.avatar.lookAt person

            complete()

          onCanceled: =>
            # Script was interrupted, so just complete.
            complete()

    # Don't output the description if this is your profile.
    return animationNode if person._id is LOI.profileId()

    @_createDescriptionScript person, @startDescription(), animationNode, nodeOptions

  _getTargetPerson: ->
    # See if we have the target person in the scene.
    LOI.adventure.getCurrentThing @content.person
