class_name InteractionContext
extends RefCounted
## Explicit dependencies an interaction target may use for its action. Created
## and filled by the gameplay scene controller and handed to the
## PlayerInteractor; it replaces any global node lookup.

## The interacting player body.
var player: Node3D
## Items the player carries.
var inventory: CarryInventory
## The session's credit account.
var wallet: Wallet
## Item definitions used in this scene.
var item_catalog: ItemCatalog
## Owned upgrades.
var upgrades: UpgradeProgress
