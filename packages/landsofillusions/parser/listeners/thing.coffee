AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Parser.ThingListener extends LOI.Adventure.Listener
  onCommand: (commandResponse) ->
    currentPhysicalThings = LOI.adventure.currentPhysicalThings()

    character = LOI.character()
    characterRenderObject = character?.avatar.getRenderObject()

    for thing in currentPhysicalThings
      do (thing) =>
        renderObject = thing.avatar.getRenderObject?()

        # Look at a thing to see its description.
        commandResponse.onPhrase
          form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.WhatIs, Vocabulary.Keys.Verbs.WhoIs], thing.avatar]
          action: =>
            LOI.adventure.showDescription thing

            # If we have a character and an object for the thing, the character should face the thing.
            return unless character and renderObject

            characterRenderObject.facePosition renderObject

        if character and renderObject
          # Go to a thing.
          commandResponse.onPhrase
            form: [Vocabulary.Keys.Verbs.GoToThing, thing.avatar]
            priority: -1
            action: =>
              # Create move memory action.
              type = LOI.Memory.Actions.Move.type
              situation = LOI.adventure.currentSituationParameters()

              LOI.Memory.Action.do type, character.id, situation,
                coordinates: renderObject.position.toObject()
