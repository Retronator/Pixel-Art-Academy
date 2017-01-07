LOI = LandsOfIllusions
Ability = LOI.Adventure.Ability

class Ability.Talking extends Ability
  constructor: ->
    super

    # Start listening for dialog lines.
    @_autorun = Meteor.autorun (computation) =>
      return unless @thing()

      for scriptNode in @currentScripts()
        continue unless scriptNode instanceof LOI.Adventure.Script.Nodes.DialogLine

        # See if the dialog line should be spoken by this actor.
        dialogLine = scriptNode
        continue unless dialogLine.actor is @thing()

        # This is our line! Speak it!
        console.log "actor is me and i am speaking", dialogLine.line

  destroy: ->
    super

    @_autorun.stop()
