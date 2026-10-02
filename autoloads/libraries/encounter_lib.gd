extends Node

### Handles storing and communicating references to encounter data
##


# for combat encounters, please use the name format combat_(id) for easy id
const ENCOUNTERS : Dictionary[StringName,String] = {
	&"combat_test":"uid://bo20t23xmgyy6"
}

## call this to obtain encounter uid safely
func retrieve_encounter(encounter_name : StringName) -> String:
	var encounter_uid : String = ENCOUNTERS.get(encounter_name)
	if encounter_uid == null:
		print("failure to retrieve encounter")
		return "uid://bo20t23xmgyy6"
	return encounter_uid
