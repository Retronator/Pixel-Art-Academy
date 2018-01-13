LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Inbox extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Inbox'

  @location: -> LOI.Emails.Inbox

  @initialize()

  constructor: ->
    super

    @admissionEmail = new C1.Items.AdmissionEmail

  things: ->
    things = []
    
    # Add the admission email if current game time is after the email was sent.
    if emailTime = @admissionEmail.gameTime()
      things.push @admissionEmail if LOI.adventure.gameDate().getTime() > emailTime.getTime()

    things

  ready: ->
    conditions = [
      super
      @admissionEmail.ready()
    ]

    _.every conditions
