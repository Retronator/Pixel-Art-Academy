LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Stasis.Vat extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.C3.Stasis.Vat'
  @fullName: -> "vat with an agent"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      It's a chamber full of liquid, big enough to hold a body.
    "

  @initialize()
  
  constructor: (@options) ->
    super

  fullName: ->
    "vat holding #{@_characterFullName()}"

  description: ->
    "#{@_characterFullName()} is suspended in the vat with their eyes closed, looking peaceful, given they're a piece of machinery.
    You can activate the agent by using the control panel."

  _characterFullName: ->
    @options.character.avatar.fullName()

  # Listener

  onCommand: (commandResponse) ->
    vat = @options.parent

    # Listen for this avatar's name.
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, vat.options.character.avatar]
      action: => LOI.adventure.showDescription vat
