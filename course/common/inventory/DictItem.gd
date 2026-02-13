# UI display for items to use with DictInventory
class_name DictItem
extends Control

@export var icon: CompressedTexture2D: set = set_icon
@export var item_name: String: set = set_item_name
@export var amount: int: set = set_amount

@export var _icon: TextureRect
@export var _name_label: Label
@export var _amount_label: Label


func set_icon(new_icon: CompressedTexture2D):
	icon = new_icon
	_icon.texture = new_icon


func set_item_name(new_item_name: String):
	item_name = new_item_name
	_name_label.text = new_item_name


func set_amount(new_amount: int):
	amount = new_amount
	_amount_label.text = str(new_amount)
