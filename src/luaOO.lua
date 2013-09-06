
-- FIXME most default methods can be defined in only the base class
-- FIXME hide metatable
-- FIXME error checking


---
-- Determines whether a given string is a restricted keyword
-- @param
--
local function isRestrictedKeyword(str)
	return (str == 'static')
		or (str == 'final');
end

---
-- Determines whether a given object is a class instance
--
local function isClass(class)
	return class
		and class.Extends
		and class:Extends(Object);
end;


---
-- Configure's a class' metatable
--
local function createClass(name, super)

	-- Verify name
	assert(type(name) == 'string', string.format("Invalid class name. Expected string, found %s.", type(name)));

	-- Verify class
	assert((super == nil) or isClass(super), "Invalid superclass. Expected class object or 'nil'");

	-- Create class
	local class = {};


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

	---
	-- Validates and store a class member
	--
	local function storeMember(key, value, static, final)
		-- Only allow method definitions for non-static members
		assert(static or (type(value) == 'function'), "Only methods may be defined non-static");

		-- Verify key not a restricted keyword
		assert(not isRestrictedKeyword(key), string.format("Cannot define method with name '%s', a restricted keyword", key));

		-- Verify final method doesn't exist
		local _, final = class:FindMethod(key);
		assert(not final, string.format("Cannot override final member '%s'", key));

		-- Store member
		local table = (static and members.static) or members;
		table = (final and table.final) or table;
		table[key] = value;
	end


	-- Final handle
	local finalHandle = setmetatable({}, {

		__index = function(self, key)
			assert(false, "Member access through member definition handles is not permitted");
		end,

		__newindex = function(self, key, value)
			storeMember(key, value, false, true);
		end
	})

	-- Static final handle
	local staticFinalHandle = setmetatable({}, {

		__index = function(self, key)
			assert(false, "Member access through member definition handles is not permitted");
		end,

		__newindex = function(self, key, value)
			storeMember(key, value, true, true);
		end
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
		end
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
		__call = function(self, ...) return self:New(...); end,

		--- String representation
		__tostring = function(self) return name; end
	});


	---============ Standard Methods ==============---
	-- The class' metatable is set to route static
	-- member access and method calls as needed.
	---=============================================---

	---
	-- Default Constructor
	--
	function members:Construct()
		-- Do nothing
	end

	---
	-- Default ToString
	--
	function members:ToString()
		return tostring(self);
	end

	---
	-- Returns the object's class
	--
	function members.final:GetClass()
		return class;
	end

	---
	-- Determines if the object is an instance of the given class
	--
	function members.final:InstanceOf(class)
		assert(isClass(class), "Invalid class. Expected class object.");
		return class:IsInstance(self);
	end

	---
	-- Determines a given object is an instance of the class
	--
	function members.static.final:IsInstance(object)
		return object
			and object.GetClass
			and (object:GetClass() == self);
	end

	---
	-- Searches recursively through the class hierarchy for
	-- an instance method with a given name.
	--
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
	--
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

	---
	-- Creates a subclass of the class
	--
	function members.static.final:Extend(name)
		return createClass(name, self);
	end

	---
	-- Returns the class' name
	--
	function members.static.final:GetName()
		return name;
	end

	---
	-- Returns the class' superclass
	--
	function members.static.final:Parent()
		return super;
	end

	---
	-- Determines if a given class is the same class as this
	-- class or is a superclass of this class
	--
	function members.static.final:Extends(class)
		return (self == class)
			or (self:Parent() and self:Parent():Extends(class));
	end

	---
	-- Creates a new instance of the class
	--
	function members.static.final:New(...)

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
			end
		});

		-- Call constructor
		instance:Construct(...);

		-- Return instance
		return instance;
	end

	---
	-- Calls a given superclass method.
	-- We need to keep track of depth (via closure variable),
	-- as any call to self:Super() in the called method will
	-- be made on the same instance and thus point at the
	-- instsance's parent class rather than its parent class'
	-- parent class.
	--
	local depth = 1;
	function members.final:Super(methodName, ...)

		-- Determine which constructor to call
		local superTarget = class;
		for i=1, depth do
			superTarget = superTarget:Parent();
		end

		-- Increment depth so if the super-constructor contains
		-- a call to self:Super(), we don't get stuck in an infinite loop
		depth = depth + 1;

		-- Call method
		local returnValues = {superTarget:FindMethod(methodName)(self, ...)};

		-- Decrement depth now that we're out of the super-constructor
		depth = depth - 1;

		-- Return results of method call
		return unpack(returnValues);
	end


	-- Return class
	return class;
end


--- Create Object base class
Object = createClass("Object");