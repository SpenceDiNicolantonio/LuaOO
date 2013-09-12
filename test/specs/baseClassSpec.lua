require("LuaOO")

describe("Base Class", function()

	it("cannot be instantiated", function()
		assert.has.error(function()
			Object:New();
		end)
	end)

	it("can be extended", function()
		local MyClass = Object:Extend("MyClass");
		assert.truthy(MyClass);
	end)


	it("requires a class name for extension", function()
		assert.has.error(function()
			Object:Extend();
		end)
		assert.has.error(function()
			Object:Extend(2);
		end)
		assert.has.error(function()
			Object:Extend(function() end);
		end)
	end)


	it("can report its name", function()
		assert.equals(Object:GetName(), "Object");
	end)


	it("has no superclass", function()
		assert.Nil(Object:Parent());
	end)


	it("can dertermine if it extends a class", function()
		local MyClass = Object:Extend("MyClass");
		assert.False(Object:Extends(MyClass));
		assert.False(Object:Extends(Object));
		assert.False(Object:Extends(nil));
	end)


	it("can determine if an object is an instance of it", function()
		local MyClass = Object:Extend("MyClass");
		local instance = MyClass:New();
		assert.True(Object:IsInstance(instance));
		assert.False(Object:IsInstance(nil));
	end)


	it("does not allow definition of public fields", function()
		assert.has.error(function()
			Object.someField = "value";
		end)
		assert.has.error(function()
			Object.final.someField = "value";
		end)
	end)


	it("does not allow definition of public methods", function()
		assert.has.error(function()
			function Object:SomeMethod() end
		end)
	end)


	it("does not allow definition of static fields", function()
		assert.has.error(function()
			Object.static.someField = "value";
		end)
	end)


	it("does not allow definition of static methods", function()
		assert.has.error(function()
			function Object.static:SomeStaticMethod() end
		end)
	end)


	it("does not allow definition of public final methods", function()
		assert.has.error(function()
			function Object.final:SomeFinalMethod() end
		end)
	end)


	it("does not allow definition of static final methods", function()
		assert.has.error(function()
			function Object.static.final:SomeStaticFinalMethod() end
		end)
	end)

end)