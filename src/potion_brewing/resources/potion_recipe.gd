extends Resource
class_name PotionRecipe

@export var name: String = ""
@export var potion: Potion
@export var requirements: Array[PotionRecipeRequirement] 


func get_ingredient_requirement(data: IngredientData) -> PotionRecipeRequirement:
	return requirements.filter(func(req): return req.data == data).front()


func get_requirement_idx(req: PotionRecipeRequirement) -> int:
	return requirements.find(req)


func is_completed() -> bool:
	for req in requirements:
		if req.current_count != req.max_count:
			return false
	return true
