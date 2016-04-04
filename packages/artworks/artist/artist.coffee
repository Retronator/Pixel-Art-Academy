LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademyArtworksArtist extends Document
  # name: real life name of the artist
  #   first
  #   middle
  #   last
  #   nickname
  # aka: array of alternative names
  # pseudonym: name that overrides default naming conventions
  # displayName: auto-generated name for embedding in related documents
  # profiles:
  #   (platform):
  #      url: link to the profile
  #      name: display name of the artist on the platform
  #      platformName: display name of the platform, if not one of the supported ones
  # claimCode: a random code that a user must provide to claim this artist (if no profiles match user's services)
  # character:
  #   _id
  @Meta
    name: 'PixelArtAcademyArtworksArtist'
    fields: =>
      displayName: @GeneratedField 'self', ['name', 'pseudonym'], (fields) ->
        return [fields._id, ''] unless fields.name or fields.pseudonym

        # Pseudonym overrides any other name so return that if present.
        return [fields._id, fields.pseudonym] if fields.pseudonym

        # Otherwise construct it in the format "First Middle 'Nickname' Last"
        name = fields.name.first or ''
        name = "#{name} #{fields.name.middle}" if fields.name.middle
        name = "#{name} '#{fields.name.nickname}'" if fields.name.nickname
        name = "#{name} #{fields.name.last}" if fields.name.last

        [fields._id, name]

      character: @ReferenceField LOI.Accounts.Character, ['name'], false, 'artist', ['displayName']

  @defaultData: ->
    name: {}
    aka: []
    profiles: {}
    claimCode: Random.id()

  # Tries to find an artist that would match with this user's services
  @findArtistForServices: (services) ->
    possibleMatches = []
    possibleMatches.push 'profiles.twitter.name': services.twitter.screenName if services.twitter

    @documents.findOne
      $or: possibleMatches

  # Compares artist's profiles to user's services to find a potential match.
  matchesServices: (services) ->
    return true if services.twitter?.screenName is @profiles.twitter?.name

    false

PAA.Artworks.Artist = PixelArtAcademyArtworksArtist
