AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Yearbook = PAA.PixelPad.Apps.Yearbook

class Yearbook.ProfileForm.General extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Yearbook.ProfileForm.General'
  @register @id()

  constructor: (@yearbook) ->
    super arguments...

  onCreated: ->
    super arguments...

    @fullNameInput = new LOI.Components.Account.Characters.CharacterNameTranslationInput characterId: LOI.characterId

  renderFullNameInput: ->
    @fullNameInput.renderComponent @currentComponent()

  positionClass: ->
    return unless playerCharacterPage = @yearbook.playerCharacterPage()

    # Place the form on the opposite page of where the player is.
    if playerCharacterPage % 2 then 'right' else 'left'

  class @Age extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.Yearbook.ProfileForm.General.Age'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number
      @realtime = false
      @customAttributes =
        min: 13
        max: 150

    load: ->
      LOI.character().document().profile?.age

    save: (value) ->
      value = parseInt value

      if _.isNaN value
        value = null

      else
        # Don't try to update if the value is out of range (usually when typing in the first digit).
        return unless 13 <= value <= 150

      LOI.Character.updateProfile LOI.characterId(), 'age', value

  class @Country extends AB.Components.RegionSelection
    @register 'PixelArtAcademy.PixelPad.Apps.Yearbook.ProfileForm.General.Country'
    
    constructor: ->
      super arguments...
      
      @allowDeselection = true

    load: ->
      LOI.character().document().profile?.country

    save: (value) ->
      LOI.Character.updateProfile LOI.characterId(), 'country', value

  class @Aspiration extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.Yearbook.ProfileForm.General.Aspiration'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.TextArea
      @realtime = false

    load: ->
      LOI.character().document().profile?.aspiration

    save: (value) ->
      LOI.Character.updateProfile LOI.characterId(), 'aspiration', value
