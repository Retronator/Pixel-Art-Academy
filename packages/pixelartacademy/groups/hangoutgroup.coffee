AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Groups.HangoutGroup extends LOI.Adventure.Group
  constructor: ->
    super

    # Active members are the ones that have done any memorable recent actions.
    @presentMembers = new ComputedField =>
      _.filter @members(), (member) =>
        # Find any actions this member has performed.
        recentActions = member.recentActions()

        # See if any of them are memorable
        _.find recentActions, (action) => action.isMemorable or action.memory

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

              for personIndex in [1..3]
                things["person#{personIndex}"] = persons[personIndex]
                @groupScript.ephemeralState "person#{personIndex}", persons[personIndex]?

              @groupScript.setThings things

          LOI.adventure.director.startScript @groupScript, {label}
