LOI = LandsOfIllusions
Actor = LOI.Adventure.Actor

class Actor.Abilities.Talking extends Actor.Ability
  @register 'LandsOfIllusions.Adventure.Actor.Abilities.Talking'

  onCreated: ->
    super

    @line = new ReactiveField null

    # Start listening for dialog lines.
    @autorun =>
      for scriptNode in @currentScripts()
        continue unless scriptNode instanceof LOI.Adventure.Script.Nodes.DialogLine

        # See if the dialog line should be spoken by this actor.
        dialogLine = scriptNode
        continue unless dialogLine.actor is @actor

        # This is our line! Speak it!
        $('.dialog-bubble').css 'opacity', 0
        @line dialogLine.line
        # start with blast.js to split up our lines
        setTimeout ->
          $('.speaking').blast delimiter: 'character'
          #animate blast in
          $('.dialog-bubble').css('opacity', 1)
          $('.blast').velocity 'transition.fadeIn', {stagger: 100, duration: 100}
        , 100 #setTimeout bc something's running before something else

        timeToSpeak = 1000 + dialogLine.line.length * 75 # ms

        # Clear any existing timeout.
        Meteor.clearTimeout @_timeoutHandle

        @_timeoutHandle = Meteor.setTimeout =>
          # The actor has finished speaking the dialog.
          # clear the blast.js debris
          $('.dialog-bubble.speaking').html('')
          $('.dialog-bubble.speaking').attr('aria-label', '')
          @line null
          dialogLine.end()
        ,
          timeToSpeak
