AR = Artificial.Reality

class AR.Chemistry.Materials
  @_materialClassesById = {}
  @_materialClassesByFormula = {}

  @registerMaterial: (materialClass) ->
    @_materialClassesById[materialClass.id()] = materialClass

    if formula = materialClass.formula()
      @_materialClassesByFormula[formula.toLowerCase()] = materialClass

  @getClassForId: (id) ->
    @_materialClassesById[id]

  @getClassForFormula: (formula) ->
    @_materialClassesByFormula[formula.toLowerCase()]

  @getClasses: ->
    _.values @_materialClassesById
