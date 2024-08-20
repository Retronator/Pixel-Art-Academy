AE = Artificial.Everywhere

# Exception classes with predefined error codes.

class AE.ArgumentException extends Meteor.Error
  constructor: (reason, details) -> super 'argument-exception', reason, details

class AE.ArgumentNullException extends Meteor.Error
  constructor: (reason, details) -> super 'argument-null-exception', reason, details

class AE.ArgumentOutOfRangeException extends Meteor.Error
  constructor: (reason, details) -> super 'argument-out-of-range-exception', reason, details

# Arithmetic, casting, or conversion error.
class AE.ArithmeticException extends Meteor.Error
  constructor: (reason, details) -> super 'arithmetic-exception', reason, details

class AE.InvalidOperationException extends Meteor.Error
  constructor: (reason, details) -> super 'invalid-operation-exception', reason, details
  
class AE.IOException extends Meteor.Error
  constructor: (reason, details) -> super 'io-exception', reason, details

class AE.NotImplementedException extends Meteor.Error
  constructor: (reason, details) -> super 'not-implemented-exception', reason, details

class AE.LimitExceededException extends Meteor.Error
  constructor: (reason, details) -> super 'limit-exceeded-exception', reason, details

class AE.UnauthorizedException extends Meteor.Error
  constructor: (reason, details) -> super 'unauthorized-exception', reason, details

class AE.ExternalException extends Meteor.Error
  constructor: (reason, details) -> super 'external-exception', reason, details

class AE.InvalidOrderException extends Meteor.Error
  constructor: (reason, details) -> super 'invalid-order-exception', reason, details
