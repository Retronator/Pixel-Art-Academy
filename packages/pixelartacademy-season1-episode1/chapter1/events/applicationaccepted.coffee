LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Events.ApplicationAccepted extends LOI.Adventure.Event
  @type: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Events.ApplicationAccepted'
  @initialize()

  process: ->
    # Set the accepted field on the AdmissionWeek state.
    _.nestedProperty @readOnlyGameState, "things.#{C1.id()}.application.accepted", true

    # Set the date.
    _.nestedProperty @readOnlyGameState, "things.#{C1.id()}.application.acceptedTime", @gameTime
    
    character = LOI.Character.documents.findOne @gameStateDocument.character._id
    C1.Items.AdmissionEmail.send character
