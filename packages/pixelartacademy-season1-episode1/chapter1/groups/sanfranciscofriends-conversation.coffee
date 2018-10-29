LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Groups.SanFranciscoFriends.Conversation extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.SanFranciscoFriends.Conversation'

  @location: ->
    # Applies to all locations.
    null

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/groups/sanfranciscofriends-conversation.script'

  @listeners: ->
    super(arguments...).concat [
      PAA.PersonUpdates
    ]

  @initialize()

  constructor: ->
    super arguments...

    @characterUpdatesHelper = new PAA.CharacterUpdatesHelper

  destroy: ->
    super arguments...

    @characterUpdatesHelper.destroy()

  # Script

  initializeScript: ->
    scene = @options.parent

    @setCallbacks
      AddAsMember: (complete) =>
        # Add person we're talking to as a member to the group.
        memberStateField = C1.Groups.SanFranciscoFriends.state.field "members.#{@things.person._id}"
        memberState = memberStateField()

        # Prepare the whole member state if needed.
        memberState ?=
          id: @things.person._id

        # Set the character as active.
        memberState.active = true

        # Save the new state.
        memberStateField memberState

        # Return back to main questions of the calling script.
        LOI.adventure.director.startScript @_returnScript, label: 'MainQuestions'
        complete()
        
      WhatsNew: (complete) =>
        @things.person.recordHangout()
        
        personUpdates = _.find scene.listeners, (listener) -> listener instanceof PAA.PersonUpdates
          
        script = personUpdates.getScript
          person: @things.person
          nextNode: @_returnScript.startNode.labels.MainQuestions
          readyField: scene.characterUpdatesHelper.ready

        LOI.adventure.director.startScript script

        complete()

  # Listener
  
  onChoicePlaceholder: (choicePlaceholderResponse) ->
    scene = @options.parent

    return unless choicePlaceholderResponse.placeholderId is 'PersonConversationMainQuestions'

    # Save the person to our script.
    person = choicePlaceholderResponse.script.things.person
    @script.setThings {person}

    # Subscribe to person's updates (actions and memories since last hanging out).
    scene.characterUpdatesHelper.person person
    
    # Save the script so we know where to return to.
    @script._returnScript = choicePlaceholderResponse.script

    # Check if this person is an active member and show the choices accordingly.
    if C1.Groups.SanFranciscoFriends.state "members.#{person._id}.active"
      label = 'MainQuestionsMember'

    else
      label = 'MainQuestionsNonMember'

    choicePlaceholderResponse.addChoice @script.startNode.labels[label].next
