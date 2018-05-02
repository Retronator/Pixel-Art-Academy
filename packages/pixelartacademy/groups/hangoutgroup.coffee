AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Groups.HangoutGroup extends LOI.Adventure.Group
  constructor: ->
    super

    @earliestTime = new ComputedField =>
      # Take the last hangout time, but not earlier than 1 month.
      # Note: we must use constructor state because the instance shortcut hasn't been assigned yet.
      lastHangoutTime = @state('lastHangoutTime')?.time.getTime() or 0
      earliestTime = Math.max lastHangoutTime, Date.now() - 30 * 24 * 60 * 60 * 1000

      lastHangoutGameTime = @state('lastHangoutTime')?.gameTime.getTime() or 0
      
      time: new Date earliestTime
      gameTime: new LOI.GameDate lastHangoutGameTime

    # Subscribe to actions of people members (non-NPCs).
    Tracker.autorun (computation) =>
      peopleMembers = _.filter @members(), (member) -> member instanceof LOI.Character.Person
      peopleMemberIds = (member._id for member in peopleMembers)

      LOI.Memory.Action.recentForCharacters.subscribe peopleMemberIds, @earliestTime().time

    # Active members are the ones that have done any memorable actions since last hangout.
    @presentMembers = new ComputedField =>
      earliestTime = @earliestTime()
      
      _.filter @members(), (member) =>
        # Find any actions this member has performed.
        recentActions = member.recentActions earliestTime

        # See if any of them are memorable
        _.find recentActions, (action) => action.isMemorable or action.memory

  members: ->
    # Override to provide things that are members of this group. Each thing must 
    # be able to provide a list of actions that happened since the last hangout time.
    []

  @listeners: ->
    super.concat [
      @GroupListener
    ]

  class @GroupListener extends LOI.Adventure.Listener
    @id: -> "PixelArtAcademy.Groups.HangoutGroup"

    @scriptUrls: -> [
      'retronator_pixelartacademy/groups/hangoutgroup.script'
    ]

    class @GroupScript extends LOI.Adventure.Script
      @id: -> "PixelArtAcademy.Groups.HangoutGroup"
      @initialize()

      initialize: ->
        return

        @setCallbacks
          Dummy: (complete) =>
            complete()

    @initialize()

    onScriptsLoaded: ->
      @groupScript = @scripts[@constructor.GroupScript.id()]

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
