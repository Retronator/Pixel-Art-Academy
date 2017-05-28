AM = Artificial.Mummification

class AM.Hierarchy.Template extends AM.Document
  # data: the root node of the template
  #   fields: the data of the template
  #     {field}: string name of related keys
  #       value: the terminal raw value of the field
  #       templateId: a reference to a template which should be inserted at this field
  #       node: a non-terminal value of the field that continues the hierarchy
  #         fields:
  #           {field}:
  #             value
  #             templateId
  #             node
  #               ...
  @Meta
    abstract: true

  # Child class should implement these fields.
  @updateData: null
  @forId: null

  constructor: ->
    # The field that loaded the template will want a node with our data.
    # Note that this resets the address hierarchy from here on out to this template.
    @node = new AM.Hierarchy.Node
      load: => @data
      save: (address, value) =>
        @constructor.updateData @_id, address, value
