AE = Artificial.Everywhere

class AE.ArgumentException extends Meteor.Error
  constructor: (reason, details) -> super 'argument-exception', reason, details

class AE.ArgumentNullException extends Meteor.Error
  constructor: (reason, details) -> super 'argument-null-exception', reason, details

class AE.ArgumentOutOfRangeException extends Meteor.Error
  constructor: (reason, details) -> super 'argument-out-of-range-exception', reason, details

class AE.ArithmeticException extends Meteor.Error
  # Arithmetic, casting, or conversion error.
  constructor: (reason, details) -> super 'arithmetic-exception', reason, details

class AE.InvalidOperationException extends Meteor.Error
  constructor: (reason, details) -> super 'invalid-operation-exception', reason, details

class AE.NotImplementedException extends Meteor.Error
  constructor: (reason, details) -> super 'not-implemented-exception', reason, details

class AE.UnauthorizedException extends Meteor.Error
  constructor: (reason, details) -> super 'unauthorized-exception', reason, details
