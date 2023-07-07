AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Yearbook = PAA.PixelPad.Apps.Yearbook

class Yearbook.ProfileForm.Favorites extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Yearbook.ProfileForm.Favorites'
  @register @id()

  constructor: (@yearbook) ->
    super arguments...

    @categories = [
      field: 'computer'
      name: "Computer/console"
    ,
      field: 'gameGenre'
      name: "Video game genre"
    ,
      field: 'artMedium'
      name: "Art medium"
    ,
      field: 'superhero'
      name: "Superhero"
    ,
      field: 'quote'
      name: "Quote",
      inputType: AM.DataInputComponent.Types.TextArea
    ]

  class @Favorite extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelPad.Apps.Yearbook.ProfileForm.Favorites.Favorite'

    constructor: ->
      super arguments...

      @realtime = false

    onCreated: ->
      super arguments...
      @type = @data().inputType or AM.DataInputComponent.Types.Text

    load: ->
      field = @data().field

      LOI.character().document().profile?.favorites?[field]

    save: (value) ->
      field = @data().field

      LOI.Character.updateProfile LOI.characterId(), "favorites.#{field}", value
