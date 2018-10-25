AB = Artificial.Base
AM = Artificial.Mummification
RA = Retronator.Accounts
PADB = PixelArtDatabase

class PADB.Artist extends AM.Document
  @id: -> 'PixelArtDatabase.Artist'
  # name: real life name of the artist
  #   first
  #   middle
  #   last
  #   nickname
  # aka: array of alternative names
  # pseudonym: name that overrides default naming conventions
  # displayName: auto-generated name for embedding in related documents
  # profiles: an array of internet profiles connected to this artist, reverse of Profile.artist
  #   _id
  #   platformType
  #   displayName
  # combinedFollowersCount: auto-generated sum of all followers across all profiles
  # user: the user that has claimed this artist
  #   _id
  # claimCode: a random code that a user must provide to claim this artist (if no profiles match user's services)
  # characters: array of characters controlled by this artist, reverse of Character.artist
  #   _id
  #   name
  # artworks: array of artworks created by this artist, reverse of Artwork.authors
  #   _id
  #   title
  # artworksCount: auto-generated total number of artworks
  @Meta
    name: @id()
    fields: =>
      displayName: Document.GeneratedField 'self', ['name', 'pseudonym', 'aka'], (fields) ->
        return [fields._id, null] unless fields.name or fields.pseudonym or fields.aka

        # Pseudonym overrides any other name so return that if present.
        return [fields._id, fields.pseudonym] if fields.pseudonym

        # Otherwise construct it in the format "First Middle 'Nickname' prefix Last"
        if fields.name
          nameParts = [
            fields.name.first
            fields.name.middle
            "'#{fields.name.nickname}'" if fields.name.nickname
            fields.name.lastPrefix
            fields.name.last
          ]

          nameParts = _.without nameParts, null, undefined

          name = nameParts.join ' '

          return [fields._id, name] if name.length

        # If no name parts were present, get the first AKA.
        return [fields._id, fields.aka[0]] if fields.aka?[0]

        # We couldn't generate a name.
        [fields._id, null]

      user: Document.ReferenceField RA.User, ['displayName'], false, 'artists'

      artworksCount: Document.GeneratedField 'self', ['artworks'], (fields) ->
        return [fields._id, 0] unless fields.artworks

        [fields._id, fields.artworks.length]

      combinedFollowersCount: Document.GeneratedField 'self', ['profiles'], (fields) ->
        return [fields._id, 0] unless fields.profiles

        profiles = PADB.Profile.documents.find('artist._id': fields._id).fetch()

        combinedFollowersCount = _.sumBy profiles, 'followersCount'

        [fields._id, combinedFollowersCount]

  # Methods

  @insert: @method 'insert'

  # Subscriptions

  @all: @subscription 'all'
  @forName: new AB.Subscription
    name: "#{@id()}.forName"
    query: (name) =>
      query = {}

      for key, value of name
        query["name.#{key}"] = value
    
      @documents.find query
  @forPseudonym: @subscription 'forPseudonym'
  
  @namePattern:
    first: Match.Optional String
    middle: Match.Optional String
    last: Match.Optional String
    nickname: Match.Optional String
