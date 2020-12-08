AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# A Study Guide activity describes an auto-generated learning goal and its tasks.
class PAA.StudyGuide.Activity extends AM.Document
  @id: -> 'PixelArtAcademy.StudyGuide.Activity'
  # goalId: the ID that the auto-generated goal should have
  # tasks: array of learning task descriptions
  #   id: the ID that the auto-generated task should have
  #   type: the type that identifies the task class individual tasks inherit from
  #   icon: icon value that represents the kind of work done in this task
  #   interests: array of interests this task increases
  #   requiredInterests: array of interests required to attempt this task
  #   predecessors: array of task IDs leading to this task
  #   predecessorsCompleteType: whether you need to complete any or all predecessor tasks
  #   groupNumber: number at which group level the task appears
  # finalTasks: array of learning task IDs that complete this goal
  # finalGroupNumber: number at which group level the exit node appears, 0 when undefined
  # requiredInterests: array of interests directly required by the goal, not coming from the tasks
  # [article]: array of delta operations for the Study Guide article of this activity
  #   insert: string or object to be inserted
  #     figure: a collection of visual elements with a caption
  #       layout: array of numbers controlling how many elements per row to show
  #       caption: the text written under the figure
  #       [elements]: array of elements that make the figure
  #         artwork: an artwork from the pixel art database
  #           _id
  #
  #         image: an image without any semantic information
  #           url
  #
  #         video: a video without any semantic information
  #           url
  #
  #     task: a learning task
  #       id: the id of the task to be displayed
  #
  #   attributes: object with formatting directives
  #     practice-section: a visually distinct section that includes practical learning tasks
  @Meta
    name: @id()

  # Methods
  @insert: @method 'insert'
  @update: @method 'update'
  @remove: @method 'remove'
  @renameGoalId: @method 'renameGoalId'

  @insertTask: @method 'insertTask'
  @updateTask: @method 'updateTask'
  @removeTask: @method 'removeTask'
  @renameTaskId: @method 'renameTaskId'
  @changeTaskType: @method 'changeTaskType'

  @updateArticle: @method 'updateArticle'

  # Subscriptions
  @all: @subscription 'all'
