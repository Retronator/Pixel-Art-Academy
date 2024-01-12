AP = Artificial.Pyramid

# Efficient implementation of complex numbers with operations that modify existing object (like three.js).
class AP.Fraction
  constructor: (@numerator = 1, @denominator = 1) ->
  
  invert: ->
    [@numerator, @denominator] = [@denominator, @numerator]

  simplify: ->
    smallestPart = => Math.min @numerator, @denominator
    
    primes = (true for i in [0..smallestPart()])
    
    currentPrime = 1
    
    increasePrime = =>
      currentPrime++
      currentPrime++ until primes[currentPrime] or currentPrime >= primes.length
      primes[number] = false for number in [currentPrime * 2...primes.length] by currentPrime
    
    increasePrime()
    
    while currentPrime <= smallestPart()
      if @numerator % currentPrime is 0 and @denominator % currentPrime is 0
        @numerator /= currentPrime
        @denominator /= currentPrime
        
      else
        increasePrime()
        
    return @
