LOI = LandsOfIllusions

lines = LOI.Character.Behavior.Personality.traitsData.split '\n'
currentCategory = null

for line in lines
  if currentCategory
    if line.length
      trait = _.extend
        key: line
      ,
        currentCategory

      # Add trait information to local collection.
      LOI.Character.Behavior.Personality.Trait.documents.insert trait

      # Prepare trait translations on the server.
      if Meteor.isServer
        LOI.Character.Behavior.Personality.Trait.create
          key: trait.key
          name: trait.key

    else
      # We've reached the end of the category.
      currentCategory = null

  else
    # Wait till we get an entry.
    continue unless line.length

    # The line contains the category signature.
    currentCategory =
      primaryFactor:
        type: parseInt line[0]
        sign: parseInt "#{line[1]}1"
      secondaryFactor:
        type: parseInt line[2]
        sign: parseInt "#{line[3]}1"
