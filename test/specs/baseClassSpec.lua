require("LuaOO")

describe("Base Class", function()

	---========================================---
	-- Instantiation / Extension
	---========================================---

	it("should be instantiable", function()
		assert.error(function()
			Object:New();
		end)
	end)

	it("should be extendable", function()
		local MyClass = Object:Extend("MyClass");
		assert.truthy(MyClass);
	end)

	it("should require a class name for extension", function()
		assert.error(function()
			Object:Extend();
		end)
		assert.error(function()
			Object:Extend(2);
		end)
		assert.error(function()
			Object:Extend(function() end);
		end)
	end)


	---========================================---
	-- Query Methods
	---========================================---

	it("should be able to report its name", function()
		assert.equals(Object:GetName(), "Object");
	end)

	it("should have no superclass", function()
		assert.equals(Object:Parent(), nil);
	end)

	it("should be able to dertermine if it extends a class", function()
		local MyClass = Object:Extend("MyClass");
		assert.False(Object:Extends(MyClass));
		assert.False(Object:Extends(Object));
		assert.error(function()
			Object:Extends(nil)
		end);
	end)

	it("should be able to determine if an object is an instance of it", function()
		local MyClass = Object:Extend("MyClass");
		local instance = MyClass:New();
		assert.True(Object:IsInstance(instance));
		assert.False(Object:IsInstance(nil));
	end)


	---========================================---
	-- Finality
	---========================================---

	it("should not allow definition of public fields", function()
		assert.error(function()
			Object.someField = "value";
		end)
	end)

	it("should not allow definition of public final fields", function()
		assert.error(function()
			Object.final.someField = "value";
		end)
	end)

	it("should not allow definition of public methods", function()
		assert.error(function()
			function Object:SomeMethod() end
		end)
	end)

	it("should not allow definition of public final methods", function()
		assert.error(function()
			function Object.final:SomeFinalMethod() end
		end)
	end)

	it("should not allow definition of static fields", function()
		assert.error(function()
			Object.static.someField = "value";
		end)
	end)

	it("should not allow definition of static methods", function()
		assert.error(function()
			function Object.static:SomeStaticMethod() end
		end)
	end)

	it("should not allow definition of static final methods", function()
		assert.error(function()
			function Object.static.final:SomeStaticFinalMethod() end
		end)
	end)

end)