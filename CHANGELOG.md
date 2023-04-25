# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.10] - 2023-04-24
### Added
- bt_push.gd
- bt_pull.gd

### Changed

- Improved Utility Value calculation for AI searching for good cards to use inside BT Nodes.

### Removed
- bt_set_status

## [0.0.9] - 2022-11-10
### Added
- SetLeftRightTargets
- SetInlineTargets
- Hexagonal Targeting

### Changed

- Improved Garbage Collection (Went from >1000 Orphan Nodes to 13 Orphan Nodes after a playthrough)

### Removed
- 

## [0.0.8] - 2022-10-21
### Added
- Walking and Jumping animations
- Card animations
- Weapon models
- Battle SFX

### Changed

-

### Removed
- 

## [0.0.7] - 2022-07-21
### Added
- 

### Changed
- Improved AI
	- AI can move, turn, act, and react.
- Fixed card maker bug that duplicated BT node dialog children nodes when clicking "edit node"

### Removed
- 

## [0.0.6] - 2022-07-15
### Added
- AI has been implemented

### Changed
- Units are saved under unique id's

### Removed
- 

## [0.0.5] - 2022-07-07
### Added
- BTCardModifyStat.gd - Modifies the stat of the card being casted until end of turn.

### Changed
- Fixed BTDecorator.gd bug that didn't check for child node before the tick function
- Fixed (CardMaker) SetIntArg bug that would crash upon opening node from Behavior Tree. Checks for integer value correctly.
- Fixed how maps are loaded. Test map is now correctly saved in res://data/maps/
- Fixed Export Godot Project so that it will export ".crd, .dat, and .map" files.

### Removed
- 

## [0.0.4] - 2022-07-04
### Added
- Title Screen
- Menus

### Changed
- 

### Removed
- HexCell.gd Position Labels

## [0.0.3] - 2022-07-01
### Added
- Consume card feature
- Reflex card feature
- Counter card feature
- BT_Caster_Add_Card
- BT_Target_Add_Card
- BT_Hand_Modify_Stat

### Changed
- 

### Removed
-

## [0.0.2] - 2022-06-29
### Added
- Unit Var: current_crit_chance
- Unit Var: base_crit_chance

### Changed
- 

### Removed
-

## [0.0.1] - 2022-06-24
### Added
- Accurate Changelog

### Changed
- 

### Removed
-