AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Artworks.Components.Admin.Artist extends PAA.Pages.Admin.Components.Document
  @register 'PixelArtAcademy.Artworks.Components.Admin.Artist'

  class @FirstName extends AM.DataInputComponent
    @register 'PixelArtAcademy.Artworks.Components.Admin.Artist.FirstName'

    load: -> @currentData()?.name?.first

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.first': value

  class @MiddleName extends AM.DataInputComponent
    @register 'PixelArtAcademy.Artworks.Components.Admin.Artist.MiddleName'

    load: -> @currentData()?.name?.middle

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.middle': value

  class @LastName extends AM.DataInputComponent
    @register 'PixelArtAcademy.Artworks.Components.Admin.Artist.LastName'

    load: -> @currentData()?.name?.last

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.last': value

  class @Nickname extends AM.DataInputComponent
    @register 'PixelArtAcademy.Artworks.Components.Admin.Artist.Nickname'

    load: -> @currentData()?.name?.nickname

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.nickname': value

  class @Pseudonym extends AM.DataInputComponent
    @register 'PixelArtAcademy.Artworks.Components.Admin.Artist.Pseudonym'

    load: -> @currentData()?.preudonym

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        pseudonym: value
