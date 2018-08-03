AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Pages.Admin.Artists.Artist extends Artificial.Mummification.Admin.Components.Document
  @id: -> 'PixelArtDatabase.Pages.Admin.Artists.Artist'
  @register @id()

  class @FirstName extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Artists.Artist.FirstName'

    load: -> @currentData()?.name?.first

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.first': value

  class @MiddleName extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Artists.Artist.MiddleName'

    load: -> @currentData()?.name?.middle

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.middle': value

  class @LastName extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Artists.Artist.LastName'

    load: -> @currentData()?.name?.last

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.last': value

  class @Nickname extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Artists.Artist.Nickname'

    load: -> @currentData()?.name?.nickname

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        'name.nickname': value

  class @Pseudonym extends AM.DataInputComponent
    @register 'PixelArtDatabase.Pages.Admin.Artists.Artist.Pseudonym'

    load: -> @currentData()?.pseudonym

    save: (value) -> Meteor.call "artistUpdate", @currentData()._id,
      $set:
        pseudonym: value
