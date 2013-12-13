
---================= Constants =================---
---=============================================---

-- Keywords that are restricted for one reason
-- or another and cannot be used for class member names
local RESTRICTED_KEYWORDS = {'static', 'final'};

-- The name of the constructor function
local CONSTRUCTOR_NAME = "Construct";



---============== Local Functions ==============---
---=============================================---

---
-- An empty function
local function doNothing() end

---
-- Determines whether a given string is a restricted keyword
-- @param str (string) The string in question
-- @return (boolean) true if the given string is a restricted keyword; false otherwise
local function isRestrictedKeyword(str)
	for _, keyword in pairs(RESTRICTED_KEYWORDS) do
		if (str == keyword) then
			return true;
		end
	end
	return false;
end

---
-- Determines whether a given value is a class
-- @param value (*) The value in question
-- @return (boolean) true if the given value is a class; false otherwise
local function isClass(value)
	-- nil?
	if (value == nil) then
		return false;
	end

	-- Base class?
	if (value == Object) then
		return true;
	end

	-- Verify class methods and that it extends Object
	return type(value) == 'table'
		and value.GetName ~= nil
		and value.Parent ~= nil
		and value.FindMethod ~= nil
		and value.FindStaticMember ~= nil
		and value.IsInstance ~= nil
		and value.Extend ~= nil
		and value.New ~= nil
		and value.Extends ~= nil
		and value:Extends(Object);
end;


---========== createClass() Function ===========---
-- This is where the magic happens. The createClass()
-- function handles the construction of a class
-- object, including the setting of its metatable
-- to facilitate inheritence and other OO goodness.
---=============================================---

---
-- Configure's a class' metatable
-- @param name (string) The name of the class
-- @param super (class)The superclass
-- @return (class) a class
local function createClass(name, super)

	-- Verify name
	assert(type(name) == 'string', string.format("Invalid class name. Expected string, found %s.", type(name)));

	-- Verify class
	assert((super == nil) or isClass(super), "Invalid superclass. Expected class object or 'nil'");

	-- Create class
	local class = {};


	---============ Properties Storage =============---
	-- All property names are stored here. Any time
	-- a field is accessed or mutated, this list will
	-- be checked. If the field's name is found in this
	-- list, then property methods (GetX/SetX) will be
	-- used, if they exist.
	---=============================================---
	local properties = {};


	---=========== Class Member Storage ============---
	-- Storing class members here allows us to completely
	-- hide them from the user and prevent unwanted behavior.
	---=============================================---
	local members = {
		final = {},
		static = {
			final = {}
		}
	}

	---
	-- Validates and store a class member
	-- @param key (string) The name of the member being stored
	-- @param value (*) The value or function being stored
	-- @param static (boolean) true for static member; false otherwise
	-- @param final (boolean) true for final member; false otherwise
	local function storeMember(key, value, static, final)
		-- Verify not base class
		assert(super ~= nil, "Cannot mutate the Object class. Extend it!");

		-- Only allow method definitions for non-static members
		assert(static or (type(value) == 'function') or (value == nil), "Only methods may be defined non-static");

		-- Verify key not a restricted keyword
		assert(not isRestrictedKeyword(key), string.format("Cannot define method with name '%s', a restricted keyword", key));

		-- Verify final method doesn't exist
		local _, finalMemberExists;
		if (static) then
			_, finalMemberExists = class:FindStaticMember(key);
		else
			_, finalMemberExists = class:FindMethod(key);
		end
		assert(not finalMemberExists, string.format("Cannot override final member '%s'", key));


		-- Remove old member if storing final
		local t = members;
		t = (static and t.static) or t;
		t[key] = nil;

		-- Store new member
		local t = members;
		t = (static and t.static) or t;
		t = (final and t.final) or t;
		t[key] = value;
	end


	---========= Member Definition Handles =========---
	-- Member definition handles are provided to allow
	-- a user to define class members without actually
	-- being granting access to the underlying member
	-- storage. These handles have metatables configured
	-- to forward member definitions to the underlying
	-- class member storage.
	-- Usage:  MyClass.static.final.MyMethod() will
	-- define a static final method 'MyMethod' in the
	-- class 'MyClass'.
	---=============================================---

	-- Final handle
	local finalHandle = setmetatable({}, {

		__index = function(self, key)
			error("Member access through member definition handles is not permitted");
		end,

		__newindex = function(self, key, value)
			storeMember(key, value, false, true);
		end,

		__metatable = false
	})

	-- Static final handle
	local staticFinalHandle = setmetatable({}, {

		__index = function(self, key)
			error("Member access through member definition handles is not permitted");
		end,

		__newindex = function(self, key, value)
			storeMember(key, value, true, true);
		end,

		__metatable = false
	});

	-- Static handle
	local staticHandle = setmetatable({}, {

		__index = function(self, key)
			-- Only allow access to static final handle
			assert(key == 'final', "Member access through member definition handles is not permitted");
			return staticFinalHandle;
		end,

		__newindex = function(self, key, value)
			storeMember(key, value, true, false);
		end,

		__metatable = false
	});


	---============== Class Metatable ==============---
	-- The class' metatable is set to route static
	-- member access and method calls as needed.
	---=============================================---
	setmetatable(class, {

		--- Forward all calls to member definition handle or static member
		__index = function(self, key)
			return (key == 'final' and finalHandle)
				or (key == 'static' and staticHandle)
				or members.static.final.FindStaticMember(class, key);
		end,

		--- Store new members as non-static non-final
		__newindex = function(self, key, value)
			storeMember(key, value, false, false);
		end,

		--- Forward MyClass() -> MyClass:New()
		__call = function(self, ...)
			return self:New(...);
		end,

		--- String representation
		__tostring = function(self)
			return name;
		end,

		--- Don't allow access to metatable
		__metatable = false
	});


	---============= Default Methods ===============---
	-- These methods must be definied per class rather
	-- than be inherited. This is typically because
	-- they facility the inheritence, or rely on
	-- closure variables (up values).
	---=============================================---

	---
	-- Returns the object's class
	-- @return (class) The object's class
	function members.final:GetClass()
		return class;
	end

	---
	-- Calls a given superclass method.
	-- We need to keep track of depth (via closure variable),
	-- as any call to self:Super() in the called method will
	-- be made on the same instance and thus point at the
	-- instsance's parent class rather than its parent class'
	-- parent class.
	-- @param methodName (string) The name of the method to call
	-- @param ... (*) Arguments to be passed to the superclass method
	-- return (*) Values returned by superclass method called
	local depth = 1;
	function members.final:Super(methodName, ...)
		-- Determine which class to call method on
		local superTarget = class;
		for i=1, depth do
			superTarget = superTarget:Parent();
		end

		-- Increment depth so if the superclass method contains
		-- a call to self:Super(), we don't get stuck in an infinite loop
		depth = depth + 1;

		-- Find method
		local method = superTarget:FindMethod(methodName);
		assert(type(method) == 'function', string.format("Method '%s' not found", methodName));

		-- Call method
		local returnValues = {method(self, ...)};

		-- Decrement depth now that we're out of the superclass call
		depth = depth - 1;

		-- Return results of method call
		return unpack(returnValues);
	end

	---
	-- Returns the class' name
	-- @return (string) class' name
	function members.static.final:GetName()
		return name;
	end

	---
	-- Returns the class' superclass
	-- @return (class) class' parent class
	function members.static.final:Parent()
		return super;
	end

	---
	-- Searches recursively through the class hierarchy for
	-- an instance method with a given name.
	-- @param methodName (string) Name of the instance method to search for
	-- @return (function, boolean) The instance method and whether the method
	-- is final; nil if no method was found
	function members.static.final:FindMethod(methodName)
		-- Don't bother looking for restricted keywords
		if (isRestrictedKeyword(methodName)) then
			return;
		end

		-- Check for method in class
		local method = members[methodName];
		local final = members.final[methodName];
		if (method) then
			return method, false;
		elseif (final) then
			return final, true;
		end


		-- Method not found in class, so check superclass
		if (super) then
			return super:FindMethod(methodName);
		end

		-- Base case... method not found
		return nil;
	end

	---
	-- Searches recursively through the class hierarchy for
	-- a static member with a given name.
	-- @param memberName (string) The name of the class member to search for
	-- @return (*, boolean) The value/function and whether it is final; nil if
	-- the member wasn't found
	function members.static.final:FindStaticMember(memberName)
		-- Don't bother looking for restricted keywords
		if (isRestrictedKeyword(memberName)) then
			return;
		end

		-- Check for member in class
		local member = members.static[memberName];
		local final = members.static.final[memberName];
		if (member) then
			return member, false;
		elseif (final) then
			return final, true;
		end

		-- Member not found in class, so check superclass
		if (super) then
			return super:FindStaticMember(memberName);
		end

		-- Base case... method not found
		return nil;
	end


	---============ Base Class Methods =============---
	-- Defined only on the base class and thus
	-- inherited by all classes.
	---=============================================---

	-- Return here if not the base class
	if (super ~= nil) then
		return class;
	end


	---
	-- Determines if the given value is a class
	-- @param value (*) The value in question
	-- @return (boolean) true if the given value is a class; false otherwise
	function members.static.final:IsClass(value)
		return isClass(value);
	end

	---
	-- Determines whether a given value is an object
	-- @param value (*) The value in question
	-- @return (boolean) true if the given value is an object; false otherwise
	function members.static.final:IsObject(value)
		return (Object and Object:IsInstance(value)) or false;
	end

	---
	-- Default ToString
	-- @return (string) The default string representation of of the instance
	function members:ToString()
		return tostring(self);
	end

	---
	-- Returns a read-only wrapper of the instance
	-- @return (Object) The read-only reference
	function members.final:ReadOnly()
		return setmetatable({}, {
			__index = self,
			__newindex = function(table, key, value)
				error("Attempt to modify read-only table")
			end,
			__metatable = false
		});
	end

	---
	-- Determines if the object is an instance of the given class
	-- @param class (class) The class in question
	-- @return (boolean) true if the object is an instance of the given class;
	-- false otherwise
	function members.final:InstanceOf(class)
		assert(isClass(class), "Invalid class. Expected class object.");
		return class:IsInstance(self);
	end

	---
	-- Determines a given object is an instance of the class
	-- @param object (object) The object in question
	-- @return (boolean) true if 'object' is an instance of the class; false otherwise
	function members.static.final:IsInstance(object)
		-- Verify input
		if ((type(object) ~= 'table') or (object.GetClass == nil)) then
			return false;
		end

		local class = object:GetClass();
		return (class == self) or (class:Extends(self));
	end

	---
	-- Creates a subclass of the class
	-- @param name (string) subclass name
	-- @return (class) The subclass
	function members.static.final:Extend(name)
		return createClass(name, self);
	end

	---
	-- Determines if a given class is the same class as this
	-- class or is a superclass of this class
	-- @param class (class) The class in question
	-- @return (boolean) true if the class extends the given class; false otherwise
	function members.static.final:Extends(class)
		assert(class ~= nil, "Expected class, found nil.");

		local parent = self:Parent();
		return (parent ~= nil) and ((parent == class) or parent:Extends(class));
	end

	---
	-- Initializes a property. Properties will be accessed via getter/setter
	-- methods if defined; otherwise, they will be accessed/mutated directly.
	-- The naming convention for a property getter/setter is Get<PropertyName>
	-- and Set<PropertyName>, respectively, with the first character of the
	-- property name capitalized. For example, the propert 'value' would use
	-- accessor 'GetValue()' and mutator 'SetValue(). The getter/setter methods
	-- can be defined independently of the property's initialization, or can
	-- be passed as arguments to be defined implicitely.
	-- @param propertyName (string) The name of the property
	-- @param getter (function) Property accessor function. If nil, no getter will
	-- be defined.
	-- @param setter (function) Property mutator function. If nil, no setter will
	-- be defined.
	function members.static.final:InitProperty(propertyName, getter, setter)
		-- Validate input
		assert(type(propertyName) == 'string', "Invalid property name. Expected string, found " .. type(propertyName));
		assert((getter == nil) or (type(getter) == 'function'), "Invalid getter function. Expected nil or function, found " .. type(propertyName));
		assert((setter == nil) or (type(setter) == 'function'), "Invalid setter function. Expected nil or function, found " .. type(propertyName));

		-- Determine getter/setter name
		local UppercasePropertyName = propertyName:gsub("^%l", string.upper);
		local getterName = "Get" .. UppercasePropertyName;
		local setterName = "Set" .. UppercasePropertyName;

		-- Store/define property info/methods
		properties[propertyName] = {
			getterName = getterName,
			setterName = setterName
		};

		-- Set getter/setter, if provided
		if (getter) then
			self[getterName] = getter;
		end
		if (setter) then
			self[setterName] = setter;
		end

	end

	---
	-- Initializes a final property, a property which cannot be overwritten
	-- once an initial value has been assigned.
	-- @param propertyName (string) The name of the property
	-- @param getter (function) Property accessor function. If nil, no getter will
	-- be defined.
	function members.static.final:InitFinalProperty(propertyName, getter)
		self:InitProperty(propertyName, getter, function(self, value)
			assert(self[propertyName] == nil, "Cannot overwrite final property: "..propertyName);
			self[propertyName] = value;
		end)
	end

	---
	-- Creates a new instance of the class
	-- @param ... (*) Arguments to be passed to the class constructor
	-- @return (object) The new class instance
	function members.static.final:New(...)
		local class = self;

		-- Verify not base class
		assert(class:Parent() ~= nil, "Cannot instantiate the Object class. Extend it!");

		-- Create instance
		local instance = setmetatable({}, {

			-- Forward method calls to class
			__index = function(self, key)
				return class:FindMethod(key);
			end,

			-- Don't allow overriding final members
			__newindex = function(self, key, value)
				local _, final = class:FindMethod(key);
				local _, staticFinal = class:FindStaticMember(key);
				assert(not final and not staticFinal, string.format("Cannot override final member '%s'", key));
				rawset(self, key, value);
			end,

			-- Don't allow access to metatable
			__metatable = false

		});

		-- Create instance handle
		local instanceHandle = setmetatable({}, {

			__index = function(self, key)

				-- If property, use property method
				if (properties[key]) then
					local getter = class:FindMethod(properties[key].getterName);
					if (getter) then
						return getter(instance);
					end
				end

				-- Forward to instance
				return instance[key];
			end,

			__newindex = function(self, key, value)

				-- If property, use property method
				if (properties[key]) then
					local setter = class:FindMethod(properties[key].setterName);
					if (setter) then
						return setter(instance, value);
					end
				end

				-- Forward to instance
				instance[key] = value;
			end,

			__metatable = false
		})

		-- Call constructor
		local constructor = instance[CONSTRUCTOR_NAME];
		if (constructor) then
			constructor(instance, ...);
		end

		-- Return instance handle
		return instanceHandle;
	end


	-- Return class
	return class;
end


---============= Object Base Class =============---
-- Create global class from which all classes will
-- extend.
---=============================================---
Object = createClass("Object");
