LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Group extends LOI.Adventure.Scene
  # lastHangoutTime: the time when player last hanged out with this group
  #   time: real-world time of the hangout
  #   gameTime: fractional time in game days
  isVisible: -> false

  members: ->
    # Override to provide things that are members of this group. Each thing must 
    # be able to provide a list of actions that happened since the last hangout time.
    []

  things: ->
    # Calculate which members should appear at the location.
    # TODO: filter by actions after last hangout time.
    @members()

  # Listener

  onCommand: (commandResponse) ->
    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.HangOut, Vocabulary.Keys.Verbs.SitDown]]
      action: =>
        # TODO
        console.log "HANGOUT"
