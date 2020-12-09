AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Quill = AM.Quill

class PAA.StudyGuide.Article.Task extends AM.Quill.BlotComponent
  onCreated: ->
    super arguments...

    @studyGuideLayout = new ComputedField =>
      @quillComponent()?.ancestorComponentOfType PAA.StudyGuide.Pages.Layout

    value = @value()
    taskClass = PAA.Learning.Task.getClassForId value.id
    
    unless taskClass
      console.warn "Unknown task with ID", value.id
      return

    goalClass = taskClass.goal()
    @goal = new goalClass
      
    @task = _.find @goal.tasks(), (task) => task instanceof taskClass

  onDestroyed: ->
    super arguments...

    @goal?.destroy()

  signedIn: ->
    Meteor.userId()?

  ensureSignedIn: (callback) ->
    # Simply perform the callback if signed in.
    if @signedIn()
      callback()
      return

    # Prompt the user to sign in.
    studyGuideLayout = @studyGuideLayout()

    dialog = new LOI.Components.Dialog
      message: "
        Tracking of completed tasks is only available with a Retronator account.
        Do you want to sign in?
      "
      buttons: [
        text: "Sign in"
        value: true
      ,
        text: "Cancel"
      ]

    studyGuideLayout.showActivatableModalDialog
      dialog: dialog
      callback: =>
        return unless dialog.result

        studyGuideLayout.signIn =>
          # See if sign in succeeded.
          return unless Retronator.user()

          # User has signed in, so perform the callback.
          callback()

  completed: ->
    # Task is completed if we have an entry.
    @task.entry()

  completedClass: ->
    'completed' if @completed()
    
  active: ->
    @task.active @goal.tasks()

  activeClass: ->
    'active' if @active()

  prerequisitesAll: ->
    @task.constructor.predecessorsCompleteType() is PAA.Learning.Task.PredecessorsCompleteType.All

  prerequisites: ->
    tasks = @goal.tasks()
    prerequisites = []

    # See if we only need one predecessor completed.
    anyCompleted = @task.constructor.predecessorsCompleteType() is PAA.Learning.Task.PredecessorsCompleteType.Any

    for predecessorClass in @task.predecessors()
      predecessor = _.find tasks, (task) => task instanceof predecessorClass

      if predecessor.completed()
        # We found a completed predecessor. If we only need to find one, there are no other prerequisites.
        return [] if anyCompleted

      else
        # Add this uncompleted task as a prerequisite.
        prerequisites.push predecessor

    prerequisites
