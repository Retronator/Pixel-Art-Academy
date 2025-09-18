AB = Artificial.Babel
AM = Artificial.Mummification
AR = Artificial.Reality
LOI = LandsOfIllusions
PAA = PixelArtAcademy

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

_currentAxis = new THREE.Vector3

class PAA.Tutorials.Drawing.Simplification.Silhouette.RotateStep extends PAA.Tutorials.Drawing.Simplification.ModelStep
  constructor: ->
    super arguments...
    
    @goalAxis = new THREE.Vector3().setFromSphericalCoords 1, @options.goalRotation.polarAngle, @options.goalRotation.azimuthalAngle
    @goalCosineTolerance = Math.cos @options.goalRotation.angleTolerance
      
  completed: ->
    # Skip PathStep's completed implementation and go straight to the Step parent.
    return unless TutorialBitmap.Step::completed.apply @, arguments...
    
    return unless stepAreaData = @stepArea.data()
    return unless referenceData = @tutorialBitmap.getReferenceDataForUrl stepAreaData.referenceUrl

    camera = referenceData.displayOptions.camera
    
    _currentAxis.setFromSphericalCoords 1, camera.polarAngle or 0, camera.azimuthalAngle or 0
    
    # Cosine difference is the better the closest to 1 it is.
    cosineDifference = Math.abs @goalAxis.dot _currentAxis
    cosineDifference >= @goalCosineTolerance

  solve: ->
    stepAreaData = @stepArea.data()
    
    asset = @tutorialBitmap.getAssetData()
    reference = _.find asset.references, (reference) -> reference.url is stepAreaData.referenceUrl

    # Update the camera rotation to the goal values.
    updateReferenceAction = new LOI.Assets.VisualAsset.Actions.UpdateReference @tutorialBitmap.id(), bitmap, reference.image._id,
      displayOptions:
        camera:
          azimuthalAngle: @options.goalRotation.azimuthalAngle
          polarAngle: @options.goalRotation.polarAngle
        
    AM.Document.Versioning.executeAction bitmap, bitmap.lastEditTime, updateReferenceAction, new Date
