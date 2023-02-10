Common Component
================

An alternative base [Blaze Component](https://github.com/peerlibrary/meteor-blaze-components)
extended with common features.

Adding this package to your [Meteor](http://www.meteor.com/) application adds `CommonComponent` and
`CommonMixin` classes into the global scope.

**Pull requests with new features are more than encouraged.** Let us all combine our common practices and
patterns together. We can always split it later into smaller packages.

Both client and server side.

Installation
------------

```
meteor add retronator:blaze-common-component
```

Usage
-----

You can use [`CommonComponent`](https://peerlibrary.github.io/meteor-blaze-common-component/class/CommonComponent.html)
as a base class for your components and
[`CommonMixin`](https://peerlibrary.github.io/meteor-blaze-common-component/class/CommonMixin.html) for your mixins.

The idea is that instead of using Blaze global template helpers you can simply use methods shared
between all your components by using a common base class for them. In this way interaction between
helpers is much cleaner and can nicely tie into the rest of the object-oriented programming.

This package provides some common features community found useful in their components.

The suggested pattern is that in your application your first extend the `CommonComponent` with an app-level
base class for all your components in the app, and then use that app-level base class in your app. Something
like:

```javascript
class AppBaseComponent extends CommonComponent {
  // All app-level methods.
}

class BlogPostComponent extends AppBaseComponent {
  // Your component for blog posts.
}

BlogPostComponent.register('BlogPostComponent');
```

In this way it is easy to later on add new features app-wide. And remember, if some feature is very
useful to you, it will probably be useful to others as well. Consider contributing it to this package.

Available features
------------------

See [generated documentation](https://peerlibrary.github.io/meteor-blaze-common-component/) for documentation
of all features available.
