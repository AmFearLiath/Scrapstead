class_name InteractionContext
extends RefCounted
## Explicit dependencies an interaction target may use for its action. Created
## and filled by the gameplay scene controller and handed to the
## PlayerInteractor; it replaces any global node lookup.

## The interacting player body.
var player: Node3D
