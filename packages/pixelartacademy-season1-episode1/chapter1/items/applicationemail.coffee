RA = Retronator.Accounts
RS = Retronator.Store
LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Items.ApplicationEmail extends LOI.Emails.Email
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Items.ApplicationEmail'

  @translations: ->
    from: "Retropolis Academy of Art"
    subject: "Application received"
    textIntro: """
      Dear _char_,

      Thank you for your interest in studying at Retropolis Academy of Art. We are confirming that we have received your application. 
    """
    textAdmissionsOpen: "Admissions are currently open so it will take just a day or two for us to arrange the start of your admission week. We'll email you again soon."
    textAdmissionsClosed: "Admissions are currently closed, but we anticipate to open them again later this year. We will email you with further instructions at that time."
    textOutro: """
      Sincerely,<br/>
      Retropolis Academy of Art Admissions
    """

  @initialize()

  @senderAddress: -> 'academyofart@retropolis.city'

  @sender: ->
    name: @getServerTranslations().from
    address: @senderAddress()

  @subject: -> @getServerTranslations().subject

  @body: (character) ->
    user = RA.User.documents.findOne character.user._id
    @_createBody user, character, @getServerTranslations()
    
  @_createBody: (user, character, translations) ->
    text = translations.textIntro

    meetsRequirements = user.hasItem C1.accessRequirement()
    text = "#{text}\n\n#{if meetsRequirements then translations.textAdmissionsOpen else translations.textAdmissionsClosed}"

    text = "#{text}\n\n#{translations.textOutro}"

    # Do variable substitution.
    text = text.replace /_char_/g, character.avatar.fullName.translate().text

    # Create the html version by treating it as markdown.
    converter = new Showdown.converter()
    html = converter.makeHtml text

    # Remove HTML from text.
    text = text.replace /<br\/>/g, ''

    {text, html}

  gameTime: ->
    return unless LOI.adventure.readOnlyGameState()

    # The application email should arrive when the character has applied.
    # Note: application time can be zero (from migrations) so we test existence separately.
    applicationTime = C1.readOnlyState('application')?.applicationTime
    return unless applicationTime?

    new LOI.GameDate applicationTime

  sender: ->
    name: @translations()?.from
    address: @constructor.senderAddress()

  recipient: ->
    character: LOI.character()

  subject: -> @translations()?.subject

  body: ->
    @constructor._createBody Retronator.user(), LOI.character().document(), @translations()
