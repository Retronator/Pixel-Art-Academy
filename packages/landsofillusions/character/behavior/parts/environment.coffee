LOI = LandsOfIllusions

class LOI.Character.Behavior.Environment extends LOI.Character.Part
  averageClutter: ->
    @_clutter 'average'
    
  idealClutter: ->
    @_clutter 'ideal'
    
  _clutter: (property) ->
    @properties.clutter.part.properties[property].options.dataLocation()

  clutterString: ->
    environmentAdjectives = [
      "minimal"
      "tidy"
      "average"
      "messy",
      "chaotic"
    ]
    
    averageClutter = @averageClutter()
    idealClutter = @idealClutter()

    if averageClutter > 0
      apartmentAdjective = environmentAdjectives[averageClutter - 1]

    else
      apartmentAdjective = "unknown"

    clutterString = _.upperFirst "#{apartmentAdjective} apartment"

    if idealClutter > 0 and averageClutter isnt idealClutter
      clutterString += ", would like it to be #{environmentAdjectives[idealClutter - 1]}."

    else
      clutterString += "."

    clutterString

  peopleString: ->
    people = @properties.people.parts()
    
    if people.length is 1
      peopleString = "One person"
      
    else if people.length > 1
      peopleString = "#{people.length} people"
      
    else
      peopleString = "No people"
    
    "#{peopleString} in life."
