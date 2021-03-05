class_name WeaponController
extends Spatial

enum WeaponSlot {
	KNIFE,
	PISTOL,
	MACHINEGUN,
	SHOTGUN,
	ROCKETLAUNCHER
}

var weapon_slots : Dictionary = {
	WeaponSlot.KNIFE: true,
	WeaponSlot.PISTOL: true,
	WeaponSlot.MACHINEGUN: false,
	WeaponSlot.SHOTGUN: false,
	WeaponSlot.ROCKETLAUNCHER: false
}

var slot_current : int = 0
var weapon_active; # TODO make this variable typed

onready var weapons : Array = get_children()


func _ready() -> void:
	if weapon_slots.size() != weapons.size():
		push_error("Size of weapon_slots is not equal to the number of weapon nodes.")
	pass


func switch_to_next_weapon() -> void:
	slot_current = (slot_current + 1) % weapon_slots.size()
	print(String(slot_current))
	
	if not weapon_slots[slot_current]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(slot_current)


func switch_to_previous_weapon() -> void:
	slot_current = posmod(slot_current - 1, weapon_slots.size())
	
	if not weapon_slots[slot_current]:
		switch_to_previous_weapon()
	else:
		switch_to_weapon_slot(slot_current)


func switch_to_weapon_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= weapon_slots.size() or slot_index >= weapons.size():
		return
	
	if not weapon_slots[slot_index]:
		return
	
	disable_all_weapons()
	weapon_active = weapons[slot_index]
	if weapon_active.has_method("set_active"):
		weapon_active.set_active()
	else:
		weapon_active.show()


func disable_all_weapons() -> void:
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			weapon.hide()
