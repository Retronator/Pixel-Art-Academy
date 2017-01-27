AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Profile extends AM.Document
  @id: -> 'PixelArtDatabase.Profile'

  # platformType: what platform this profile is on
  # platformName: the name of the platform if type is Other
  # url: link to the profile
  # username: username used on the platform
  # displayName: display name of the artist on the platform
  # imageUrl: profile image used by this profile
  # description: description written on the profile
  # followersCount: number of followers this profile has
  # claimCode: a random code that a user must provide to claim this profile (if it doesn't match user's services)
  # artist: artist that this profile represents
  #   _id
  #   displayName
  # sourceData: raw data returned by the platform API for this profile
  @Meta
    name: @id()
    fields: =>
      artist: @ReferenceField PADB.Artist, ['displayName'], false, 'profiles', ['platformType', 'displayName']

  @PlatformTypes:
    Twitter: 'Twitter'
    FacebookPage: 'FacebookPage'
    FacebookProfile: 'FacebookProfile'
    Other: 'Other'

  # Subscriptions

  @forUsername: @subscription 'forUsername'
