AM = Artificial.Mummification

class AM.Hierarchy
  @create: (options) ->
    # Create a blank address if needed.
    options.address ?= new AM.Hierarchy.Address ''

    # Build a hierarchy of nodes that represents the data.
    new @Node options

  @convertObjectToStoredValue: (options) ->
    # TODO: Expand plain object into a structure with fields, nodes and templates.
