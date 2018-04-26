LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Group extends LOI.Adventure.Scene
  # lastHangoutTime: the time when player last hanged out with this group
  #   time: real-world time of the hangout
  #   gameTime: fractional time in game days
  isVisible: -> false
    
  constructor: ->
    super

    @members = new ComputedField =>
      LOI.Character.getPerson memberId for memberId in @memberIds()

    @lastHangoutTime = new ComputedField =>
      @state('lastHangoutTime')?.time or new Date(0)

    # Subscribe to actions of members.
    Tracker.autorun (computation) =>
      LOI.Memory.Action.recentForCharacters.subscribe @memberIds(), @lastHangoutTime()

    @actions = new ComputedField =>
      LOI.Memory.Action.documents.fetch
        'character._id': $in: @memberIds()
        time: $gt: @lastHangoutTime()
        # We only care about memorable actions for group activity.
        $or: [
          isMemorable: true
        ,
          memory: $exists: true
        ]

  memberIds: ->
    # Override to provide things that are members of this group. Each thing must 
    # be able to provide a list of actions that happened since the last hangout time.
    []

  things: ->
    # Calculate which members should appear at the location.
    actions = @actions()

    _.filter @members(), (member) =>
      # Find any memorable actions this member has performed.
      _.find actions, (action) => action.character._id is member._id

  # Listener

  onCommand: (commandResponse) ->
    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.HangOut, Vocabulary.Keys.Verbs.SitDown]]
      action: =>
        # TODO
        console.log "HANGOUT"
