class_name ViewGD

## A tracked reference's dependency.
class Dep:
	var component: Node
	var property: String
	# This will be a callable if is_computed is true, and null otherwise.
	var function
	var is_computed := false
	
	func _init(c: Node, p: String, f = null):
		self.component = c
		self.property = p
		self.function = f

## A value that is being tracked.
class TrackedRef:
	var deps := []
	var value: Variant
	var hit: bool
	var is_computed = false

## Where all reference date is stored.
var refs := {}
## Whether we're tracking depdencies.
var tracking := true
## Component to bind to.
var component: Node
## IDs we have already used (for watchers and computed values).
var used_ids := []

## Registers a series of values onto this component.
func data(val_dict: Dictionary):
	for key in val_dict:
		var val = val_dict[key]
		self.refs[key] = TrackedRef.new()
		self.refs[key].value = val

## Updates dependencies.
## Any dependencies in the ignore list will not be updated.
func _update_deps(property: String, value, ignore: Array = []):
	if not self.tracking:
		if property in self.refs:
			self.refs[property].value = value
			for dep in self.refs[property].deps:
				if dep in ignore:
					continue
				if dep.is_computed:
					var result = dep.function.call()
					self._update_deps(dep.property, result)
				else:
					dep.component.set(dep.property, value)
			
## Sets a stored value.
## Returns true if the value exists.
func set_v(property: String, value: Variant) -> bool:
	if property in self.refs:
		assert(not self.refs[property].is_computed, "Computed properties cannot be directly assigned values.")
		self._update_deps(property, value)
		return true
	return false
		
## Returns a stored value. 
func get_v(property: String):
	if property in self.refs:
		if self.tracking:
			self.refs[property].hit = true
		return self.refs[property].value

## Binds a component's property to a tracked ref.
## If an update signal is passed, this becomes a two way binding. The tracked ref can be modified
## by both ViewGD and the component, updating whenever the signal fires.
## `tracked_ref` can either be a string indicating the name of the reactive value or a function.
func bind(_component: Node, property_name: String, tracked_ref, update_signal: String = ""):
	var value_name
	if typeof(tracked_ref) == TYPE_CALLABLE:
		# If a function has been passed, create a new computed function.
		value_name = get_unique_id()
		self.computed(value_name, tracked_ref)
	else:
		value_name = tracked_ref
	
	var dep := Dep.new(_component, property_name)
	self.refs[value_name].deps.append(dep)
	_component.set(property_name, self.refs[value_name].value)
	
	if update_signal != "":
		_component.connect(update_signal, func(_1 = null, _2 = null, _3 = null, _4 = null, _5 = null, _6 = null, _7 = null, _8 = null, _9 = null):
			var new_val = _component.get(property_name)
			
			# For convenience, if the property is a string and the value is not, we autoconvert.
			var val_type = typeof(self.refs[value_name].value)
			if val_type is int:
				new_val = int(new_val)
			if val_type is float:
				new_val = float(new_val)
			if val_type is bool:
				new_val = bool(new_val)
			
			self._update_deps(value_name, new_val, [dep])
		)

## Runs a function when the values given change.
func watch(value_names: Array, fn: Callable):
	var func_name = self.get_unique_id()
	var dep = Dep.new(self.component, func_name, fn)
	dep.is_computed = true
	for value_name in value_names:
		self.refs[value_name].deps.append(dep)
	fn.call()
	
## Runs a function when any tracked dependencies change.
func computed(value_name: String, fn: Callable):
	self.refs[value_name] = TrackedRef.new()
	self.refs[value_name].is_computed = true
	
	# Reset all hit refs
	for ref_name in self.refs:
		self.refs[ref_name].hit = false
	
	# Cache current value
	self.refs[value_name].value = fn.call()
	
	# Add to all hit refs as dependency
	self.refs[value_name].hit = false
	var dep = Dep.new(self.component, value_name, fn)
	dep.is_computed = true
	for ref_name in self.refs:
		var ref = self.refs[ref_name]
		if ref.hit and not dep in ref.deps:
			self.refs[ref_name].deps.append(dep)
	
### Generates a unique ID for value names.
func get_unique_id() -> String:
	var id = str(randi())
	while id in self.used_ids:
		id = str(randi())
	self.used_ids.append(id)
	return id
	
## Begins tracking dependencies.
func begin():
	self.tracking = true
	
## Ends tracking dependencies.
func end():
	self.tracking = false

func _init(_component: Node):
	self.component = _component
	
	# Attach props if defined
	if self.component.has_method("props"):
		self.begin()
		self.data(self.component.props())
		self.end()
		
## Adds a list of nodes to a parent node based on a list of data.
func foreach(prop_name: String, parent: Node, component_path: String, create_fn: Callable):
	# We register a watcher on the component that creates, updates,
	# and deletes child nodes based on the list.
	var watch_func = func():
		# Delete old children
		for child in parent.get_children():
			parent.remove_child(child)
			child.queue_free()
		
		# Add new children
		var items : Array[Variant] = self.get_v(prop_name)
		for i in range(len(items)):
			var item = items[i]
			var child = load(component_path).instantiate()
			create_fn.call(child, item, i)
			parent.add_child(child)
	self.watch([prop_name], watch_func)

# List helpers

## Like `append`, but returns the array.
func append(arr: Array, e: Variant) -> Array:
	arr.append(e)
	return arr
	
## Like `push_back`, but returns the array.
func push_back(arr: Array, e: Variant) -> Array:
	arr.push_back(e)
	return arr
	
## Like `push_front`, but returns the array.
func push_front(arr: Array, e: Variant) -> Array:
	arr.push_front(e)
	return arr

## Like `pop_back`, but returns the array.
func pop_back(arr: Array) -> Array:
	arr.pop_back()
	return arr
	
## Like `pop_at`, but returns the array.
func pop_at(arr: Array, i: int) -> Array:
	arr.pop_at(i)
	return arr

## Like `append_array`, but returns the array.
func append_array(arr: Array, arr2: Array) -> Array:
	arr.append_array(arr2)
	return arr

## Like `assign`, but returns the array.
func assign(arr: Array, arr2: Array) -> Array:
	arr.assign(arr2)
	return arr
	
## Like `reverse`, but returns the array.
func reverse(arr: Array) -> Array:
	arr.reverse()
	return arr
	
## Like `insert`, but returns the array.
func insert(arr: Array, i: int, e: Variant) -> Array:
	arr.insert(i, e)
	return arr
	
## Sets an element of the array and returns it.
func set_at(arr: Array, i: int, e: Variant) -> Array:
	arr[i] = e
	return arr

# Object helpers

## Updates a field of the object, then returns the object.
func o_set(obj: Variant, f_name: String, f_val: Variant) -> Variant:
	if typeof(obj) == TYPE_DICTIONARY:
		obj[f_name] = f_val
	else:
		obj.set(f_name, f_val)
	return obj
