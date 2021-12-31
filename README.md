# Clue

Clue is a Swift library, and a command-line tool that finds symbol references in Swift projects.

Like Xcode, finding references of a symbol with Clue can be fairly straightforward. Unlike Xcode, Clue exposes controls that fine tune its behavior, so that an expert can find the code references they need 100% of the time.

(Hopefully, it isn't hard to become an expert user!)

[IndexStoreDB]: https://github.com/apple/indexstore-db

# TODO
- Document `getter:property`, `setter:property`, `didSet:property`, `willSet:property`, they don't normally appear in code, hence we don't have conveniences for them. User need to know these "syntax" to perform queries for them, usually to get their definition but that's kind of strange since they are defined aloneside `property` anyways.
