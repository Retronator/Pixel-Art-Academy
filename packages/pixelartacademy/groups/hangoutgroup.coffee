AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class PAA.Groups.HangoutGroup extends LOI.Adventure.Group
  @listeners: ->
    super(arguments...).concat [
      PAA.PersonUpdates
    ]

  constructor: ->
    super arguments...

    # Active members are the ones that have done any memorable recent actions.
    @presentMembers = new ComputedField =>
      _.filter @members(), (member) =>
        # Find any actions this member has performed.
        recentActions = member.recentActions()

        # See if any of them are memorable
        _.find recentActions, (action) => action.isMemorable or action.memory

    @characterUpdatesHelper = new PAA.CharacterUpdatesHelper

    @personUpdates = _.find @listeners, (listener) => listener instanceof PAA.PersonUpdates

  destroy: ->
    super arguments...

    @characterUpdatesHelper.destroy()

  members: ->
    # Override to provide things that are members of this group.
    # Each thing must be able to provide a list of their recent actions.
    []

  startMainQuestionsWithPerson: ->
    throw new AE.NotImplementedException "You must provide a way to start a default conversation with a group member."

  class @GroupListener extends LOI.Adventure.Listener
    class @Script extends LOI.Adventure.Script
      initialize: ->
        group = @options.parent

        @setCallbacks
          WhatsNew: (complete) =>
            remainingMembers = _.clone group.presentMembers()

            # Pause current callback node so dialogues can execute.
            LOI.adventure.director.pauseCurrentNode()

            handleNextMember = =>
              # Start next person's update.
              person = remainingMembers.shift()
              person.recordHangout()
              group.characterUpdatesHelper.person person

              script = group.personUpdates.getScript
                person: person
                justUpdate: true
                readyField: group.characterUpdatesHelper.ready
                nextNode: null
                endUpdateCallback: =>
                  # See if we have any members left.
                  if remainingMembers.length
                    handleNextMember()

                  else
                    # We're done!
                    complete()

              LOI.adventure.director.startScript script, label: 'JustUpdateStart'

            # Start the handling.
            handleNextMember()

          FollowUp: (complete) =>
            # Last choice is to end the interaction.
            nextNode = @startNode.labels.FollowUpEnd.next

            # We prepare a placeholder for the node that starts the follow up choices, so we can return to it.
            followUpRoot = null

            # Daisy chain people choices.
            for person in group.presentMembers() by -1
              do (person) =>
                # Create a dialog node followed by the jump (or following
                # to the last non-choice node if no jump is present).
                dialogNode = new Nodes.DialogueLine
                  line: "#{person.fullName()} …"
                  next: new Nodes.Callback
                    callback: (complete) =>
                      # Load actions/memories of the selected person.
                      group.characterUpdatesHelper.person person

                      # Get the update script for this person and make it continues back to group's main questions.
                      script = group.personUpdates.getScript
                        person: person
                        justFollowUp: true
                        readyField: group.characterUpdatesHelper.ready
                        nextNode: followUpRoot

                      # Start the person update from the follow up questions.
                      LOI.adventure.director.startScript script, label: 'JustFollowUpStart'
                      complete()

                  actor: LOI.character().avatar

                # Create a choice node that delivers the line if chosen.
                choiceNode = new Nodes.Choice
                  node: dialogNode
                  next: nextNode

                nextNode = choiceNode

            followUpRoot = nextNode

            LOI.adventure.director.startNode followUpRoot
            complete()

          JustOne: (complete) =>
            # Start direct one-on-one dialog 
            group.startMainQuestionsWithPerson @things.person1
            
            complete()

    onScriptsLoaded: ->
      @groupScript = @scripts[@constructor.Script.id()]

    onCommand: (commandResponse) ->
      scene = @options.parent

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.HangOut, Vocabulary.Keys.Verbs.SitDown]]
        action: =>
          presentMembers = scene.presentMembers()

          switch presentMembers.length
            when 0 then label = 'NoOne'
            when 1
              @groupScript.setThings person1: presentMembers[0]
              @groupScript.ephemeralState 'person1', presentMembers[0].fullName()

              # See if this group has more members otherwise.
              label = if scene.members().length is 1 then 'OnlyOne' else 'JustOne'

            else
              label = 'Start'

              # Randomly assign members to person 1-3.
              persons = []
              freeIndices = [1..3]
              leftMembers = _.clone presentMembers

              while leftMembers.length and freeIndices.length
                member = Random.choice leftMembers
                freeIndex = Random.choice freeIndices

                persons[freeIndex] = member

                _.pull leftMembers, member
                _.pull freeIndices, freeIndex

              things = {}

              for personIndex in [1..persons.length]
                things["person#{personIndex}"] = persons[personIndex]
                @groupScript.ephemeralState "person#{personIndex}", true

              @groupScript.setThings things

          # Clear out the rest of the people.
          if presentMembers.length < 3
            for personIndex in [presentMembers.length + 1..3]
              @groupScript.ephemeralState "person#{personIndex}", false

          LOI.adventure.director.startScript @groupScript, {label}
