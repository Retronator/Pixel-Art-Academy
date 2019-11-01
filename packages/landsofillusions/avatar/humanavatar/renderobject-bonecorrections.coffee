AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.HumanAvatar.RenderObject extends LOI.HumanAvatar.RenderObject
  @_boneHierarchy =
    children:
      "Lumbar Spine":
        landmark: 'navel'
        children:
          "Thoracic Spine Bottom":
            part: 'AbdomenShape'
            partPath: 'torso.abdomen.shape'
            landmark: 'navel'
            children:
              "Thoracic Spine Top":
                part: 'AbdomenShape'
                partPath: 'torso.abdomen.shape'
                landmark: 'xiphoid'
                children:
                  Neck:
                    part: 'ChestShape'
                    partPath: 'torso.chest.shape'
                    landmark: 'suprasternalNotch'
                    children:
                      Head:
                        part: 'NeckShape'
                        partPath: 'torso.neck.shape'
                        landmark: 'atlas'
                  "Left Shoulder":
                    part: 'ChestShape'
                    partPath: 'torso.chest.shape'
                    landmark: 'suprasternalNotch'
                    children:
                      "Left Upper Arm":
                        part: 'ChestShape'
                        partPath: 'torso.chest.shape'
                        landmark: 'shoulderLeft'
                        parentLandmark: 'suprasternalNotch'
                        children:
                          "Left Lower Arm":
                            part: 'UpperArmShape'
                            partPath: 'arms.upperArm.shape'
                            landmark: 'elbow'
                            parentLandmark: 'shoulder'
                            children:
                              "Left Hand":
                                part: 'LowerArmShape'
                                partPath: 'arms.lowerArm.shape'
                                landmark: 'wrist'
                  "Right Shoulder":
                    part: 'ChestShape'
                    partPath: 'torso.chest.shape'
                    landmark: 'suprasternalNotch'
                    children:
                      "Right Upper Arm":
                        part: 'ChestShape'
                        partPath: 'torso.chest.shape'
                        landmark: 'shoulderRight'
                        parentLandmark: 'suprasternalNotch'
                        children:
                          "Right Lower Arm":
                            part: 'UpperArmShape'
                            partPath: 'arms.upperArm.shape'
                            landmark: 'elbow'
                            parentLandmark: 'shoulder'
                            flipped: true
                            children:
                              "Right Hand":
                                part: 'LowerArmShape'
                                partPath: 'arms.lowerArm.shape'
                                landmark: 'wrist'
                                flipped: true
              "Clothes Top L 1":
                part: 'AbdomenShape'
                partPath: 'torso.abdomen.shape'
                landmark: 'xiphoid'
              "Clothes Top R 1":
                part: 'AbdomenShape'
                partPath: 'torso.abdomen.shape'
                landmark: 'xiphoid'
          "Left Acetabulum":
            part: 'AbdomenShape'
            partPath: 'torso.abdomen.shape'
            landmark: 'hypogastrium'
            children:
              "Left Upper Leg":
                part: 'GroinShape'
                partPath: 'torso.groin.shape'
                landmark: 'acetabulumLeft'
                children:
                  "Left Lower Leg":
                    part: 'ThighShape'
                    partPath: 'legs.thigh.shape'
                    landmark: 'knee'
                    parentLandmark: 'acetabulum'
                    children:
                      "Left Foot":
                        part: 'LowerLegShape'
                        partPath: 'legs.lowerLeg.shape'
                        landmark: 'ankle'
          "Right Acetabulum":
            part: 'AbdomenShape'
            partPath: 'torso.abdomen.shape'
            landmark: 'hypogastrium'
            children:
              "Right Upper Leg":
                part: 'GroinShape'
                partPath: 'torso.groin.shape'
                landmark: 'acetabulumRight'
                children:
                  "Right Lower Leg":
                    part: 'ThighShape'
                    partPath: 'legs.thigh.shape'
                    landmark: 'knee'
                    parentLandmark: 'acetabulum'
                    flipped: true
                    children:
                      "Right Foot":
                        part: 'LowerLegShape'
                        partPath: 'legs.lowerLeg.shape'
                        landmark: 'ankle'
                        flipped: true
          "Clothes Bottom L 1":
            part: 'AbdomenShape'
            partPath: 'torso.abdomen.shape'
            landmark: 'hypogastrium'
          "Clothes Bottom R 1":
            part: 'AbdomenShape'
            partPath: 'torso.abdomen.shape'
            landmark: 'hypogastrium'

  # Calculate bone offsets relative to default body.
  _calculateBoneCorrections: (side) ->
    corrections = {}
    @_calculateBoneCorrectionsOnNode side, @constructor._boneHierarchy, null, corrections

    corrections

  _calculateBoneCorrectionsOnNode: (side, node, parent, corrections) ->
    # Transverse the hierarchy.
    if node.children
      for childName, child of node.children
        correction = @_calculateBoneCorrectionsOnNode side, child, node, corrections
        corrections[childName] = correction if correction?.x or correction?.y

    # We don't have anything to do in top nodes.
    return unless node.part

    # Find the default separation of current and parent landmark in the default part.
    partClass = LOI.Character.Part.Types.Avatar.Body[node.part]
    return unless defaultPartRot8 = partClass.options.default

    # On the symmetrical limbs we have to search for mirror sides first.
    searchSide = if node.flipped then LOI.Engine.RenderingSides.mirrorSides[side] else side
    defaultFlipped = false
    defaultSprite = LOI.Assets.Sprite.findInCache name: "#{defaultPartRot8}/#{_.kebabCase searchSide}"

    unless defaultSprite
      mirrorSearchSide = LOI.Engine.RenderingSides.mirrorSides[searchSide]
      defaultFlipped = true
      defaultSprite = LOI.Assets.Sprite.findInCache name: "#{defaultPartRot8}/#{_.kebabCase mirrorSearchSide}"

    return unless defaultSprite

    return unless parentLandmark = _.find defaultSprite.landmarks, (landmark) => landmark.name is node.parentLandmark or parent.landmark
    return unless nodeLandmark = _.find defaultSprite.landmarks, (landmark) => landmark.name is node.landmark

    defaultOffset =
      x: nodeLandmark.x - parentLandmark.x
      y: nodeLandmark.y - parentLandmark.y

    defaultOffset.x *= -1 if defaultFlipped

    # Find the actual correction for this human avatar by comparing its part to the default.
    part = @humanAvatar.body

    for property in node.partPath.split '.'
      part = part.properties[property].part

    spriteId = part.properties[searchSide].options.dataLocation()? 'spriteId'
    sprite = LOI.Assets.Sprite.getFromCache spriteId
    actualFlipped = false

    unless sprite
      mirrorSearchSide = LOI.Engine.RenderingSides.mirrorSides[searchSide]
      mirrorSpriteId = part.properties[mirrorSearchSide].options.dataLocation()? 'spriteId'
      sprite = LOI.Assets.Sprite.getFromCache mirrorSpriteId
      actualFlipped = true

    return unless sprite

    return unless parentLandmark = _.find sprite.landmarks, (landmark) => landmark.name is node.parentLandmark or parent.landmark
    return unless nodeLandmark = _.find sprite.landmarks, (landmark) => landmark.name is node.landmark

    offset =
      x: nodeLandmark.x - parentLandmark.x
      y: nodeLandmark.y - parentLandmark.y

    offset.x *= -1 if actualFlipped

    # Return correction for this node.
    correction =
      x: offset.x - defaultOffset.x
      y: offset.y - defaultOffset.y

    correction.x *= -1 if node.flipped

    correction
