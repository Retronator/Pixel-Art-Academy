AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtReadability.IconSelection.Volume2 extends PAA.Challenges.Drawing.PixelArtReadability.IconSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtReadability.IconSelection.Volume2"
  
  @displayName: -> "The Graphics Book of Icons — Nature"

  @description: -> """
    More icons to choose from to complete this challenge.
  """
  
  @volumeNumber: -> 2

  @defaultUrl: -> 'the-graphics-book-of-icons-nature'

  @coverIconsCounts: -> 8: 3, 16: 2, 32: 1
  
  @initialize()
  
  @parts =
    farmAndPets: title: "Down on the farm"
    forest: title: "Among the trees"
    air: title: "In the air"
    water: title: "By the water"
    wilderness: title: "Wilderness"
    ground: title: "Creepy crawlies"
    fruit: title: "Fruit"
    plants: title: "Plants"
  
  @labels =
    farmAndPets: ['cat', 'cow', 'dog', 'duck', 'horse', 'mouse', 'pig', 'rabbit', 'sheep']
    forest: ['bear', 'hedgehog', 'raccoon', 'squirrel']
    air: ['bat', 'bee', 'butterfly', 'owl', 'parrot']
    water: ['crab', 'dolphin', 'fish', 'frog', 'lobster', 'penguin', 'shark', 'swan', 'turtle']
    wilderness: ['camel', 'elephant', 'giraffe', 'kangaroo', 'lion', 'rhinoceros', 'tiger', 'zebra']
    ground: ['ant', 'scorpion', 'snail', 'snake', 'spider']
    fruit: ['apple', 'banana', 'pear', 'pineapple', 'strawberry']
    plants: ['flower', 'mushroom', 'tree']
