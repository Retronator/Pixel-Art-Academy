AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Yearbook = PAA.PixelBoy.Apps.Yearbook

class Yearbook.ProfileForm.Favorites extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook.ProfileForm.Favorites'
  @register @id()

  constructor: (@yearbook) ->
    super

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
      name: "Quote"
    ]

  class @Favorite extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelBoy.Apps.Yearbook.ProfileForm.Favorites.Favorite'

    constructor: ->
      super

      @realtime = false

    load: ->
      field = @data()

      LOI.character().document().profile?.favorites?[field]

    save: (value) ->
      field = @data()

      LOI.Character.updateProfile LOI.characterId(), "favorites.#{field}", value
