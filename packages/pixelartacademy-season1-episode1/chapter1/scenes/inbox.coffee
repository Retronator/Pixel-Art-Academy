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

    @admissionEmailArrived = new ComputedField =>
      gameDate = LOI.adventure.gameDate()
      emailDate = @admissionEmail.gameDate()

      # Admission email has arrived if current game time is after the email was sent.
      gameDate?.getTime() > emailDate?.getTime()

  destroy: ->
    super

    @admissionEmailArrived.stop()

  things: ->
    things = []
    
    things.push @admissionEmail if @admissionEmailArrived()

    things

  ready: ->
    conditions = [
      super
      @admissionEmail.ready()
    ]

    _.every conditions
