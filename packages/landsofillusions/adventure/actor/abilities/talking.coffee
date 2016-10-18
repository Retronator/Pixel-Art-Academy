LOI = LandsOfIllusions
Actor = LOI.Adventure.Actor

class Actor.Abilities.Talking extends Actor.Ability
  constructor: ->
    super

    # Start listening for dialog lines.
    Meteor.autorun (computation) =>
      return unless @actor()

      for scriptNode in @currentScripts()
        continue unless scriptNode instanceof LOI.Adventure.Script.Nodes.DialogLine

        # See if the dialog line should be spoken by this actor.
        dialogLine = scriptNode
        continue unless dialogLine.actor is @actor()

        # This is our line! Speak it!
        console.log "actor is me and i am speaking", dialogLine.line
