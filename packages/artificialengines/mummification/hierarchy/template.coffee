AM = Artificial.Mummification

class AM.Template extends AM.Document
  @id: -> 'Artificial.Mummification.Template'
  # {field}: string name of related keys
  #   value
  #   templateID
  #   node
  #     value
  #     templateID
  #     node
  #       ...
  @Meta
    name: @id()
