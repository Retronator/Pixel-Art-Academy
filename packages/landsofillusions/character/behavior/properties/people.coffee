LOI = LandsOfIllusions

class LOI.Character.Behavior.Environment.People extends LOI.Character.Part.Property.Array
  @RelationshipType:
    Mom: 'Mom'
    Dad: 'Dad'
    Parent: 'Parent'
    Sister: 'Sister'
    Brother: 'Brother'
    Sibling: 'Sibling'
    Daughter: 'Daughter'
    Son: 'Son'
    Child: 'Child'
    OtherFamily: 'OtherFamily'
    Wife: 'Wife'
    Husband: 'Husband'
    Partner: 'Partner'
    Girlfriend: 'Girlfriend'
    Boyfriend: 'Boyfriend'
    SignificantOther: 'SignificantOther'
    Friend: 'Friend'

  @LivingProximity:
    Roommate: 'Roommate'
    Housemate: 'Housemate'
    Local: 'Local'
    Internet: 'Internet'

  toString: ->
    people = @parts()
    return unless people.length

    # TODO: Replace with translated relationship types.
    peopleRelationshipNames = (_.lowerCase person.properties.relationshipType.options.dataLocation() for person in people)

    "#{_.upperFirst peopleRelationshipNames.join ', '}."
