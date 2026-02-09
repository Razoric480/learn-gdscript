# Holds the data for one practice
class_name Practice
extends Resource

const QueryResult := Documentation.QueryResult

# Uniquely identifies the practice resource.
@export var practice_id := ""

@export var title := ""
@export var goal := "" # (String, MULTILINE)
@export var starting_code := "" # (String, MULTILINE)
@export var cursor_line := 0 # (int, 9999)
@export var cursor_column := 0 # (int, 9999)
@export var hints := PackedStringArray()
@export var validator_script_path := "" # (String, FILE)
@export var script_slice_path := "" # (String, FILE)
# Optional: Name of the EXPORT slice to use (if script has multiple EXPORT blocks)
# If empty, will use the first EXPORT found in the script
@export var slice_name := ""
@export var documentation_references := PackedStringArray()
@export var documentation_resource: Resource = preload("res://course/Documentation.tres"): set = set_documentation_resource
@export var description := ""


func set_documentation_resource(new_documentation_resource: Resource) -> void:
	assert(
		(new_documentation_resource == null) or (new_documentation_resource is Documentation),
		"resource `%s` is not a Documentation resource" % [new_documentation_resource.resource_path]
	)
	documentation_resource = new_documentation_resource


func get_documentation_resource() -> Documentation:
	return documentation_resource as Documentation


func get_documentation_raw() -> QueryResult:
	if documentation_resource == null:
		if not documentation_references.is_empty():
			push_error(
				"Documentation References were selected, but no documentation resource was set"
			)
		return null
	return get_documentation_resource().get_references(documentation_references)
