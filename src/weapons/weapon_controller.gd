class_name WeaponController
extends Spatial

enum Weapon {
	KNIFE,
	PISTOL,
	MACHINEGUN,
	SHOTGUN,
	PLASMAGUN,
	ROCKETLAUNCHER,
	RAILGUN
}

var weapon_slots : Dictionary = {
	Weapon.KNIFE: true,
	Weapon.PISTOL: true,
	Weapon.MACHINEGUN: false,
	Weapon.SHOTGUN: false,
	Weapon.PLASMAGUN: false,
	Weapon.ROCKETLAUNCHER: false,
	Weapon.RAILGUN: false,
}

var slot_current : int = 0

onready var weapons : Array = get_children()


func _ready() -> void:
	pass


func switch_to_next_weapon() -> void:
	pass


func switch_to_last_weapon() -> void:
	pass


func switch_to_weapon_slot(slot_index: int) -> void:
	pass


func disable_all_weapons() -> void:
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			weapon.hide()
