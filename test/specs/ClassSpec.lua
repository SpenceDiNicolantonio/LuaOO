require("LuaOO")

describe("Class", function()

	local MyClass;

	before_each(function()
		MyClass = Object:Extend("MyClass");
	end)


	---========================================---
	-- Instantiation / Extension
	---========================================---

	it("should be instantiable", function()
		local instance = MyClass:New();
		assert.truthy(instance);
	end)

	it("should be extendable", function()
		local subclass = MyClass:Extend("MySubclass");
		assert.truthy(subclass);
	end)

	it("should require a class name for extension", function()
		assert.error(function()
			MyClass:Extend();
		end)
		assert.error(function()
			MyClass:Extend(2);
		end)
		assert.error(function()
			MyClass:Extend(function() end);
		end)
	end)


	---========================================---
	-- Query Methods
	---========================================---

	it("should be able to report its name", function()
		local MySubclass = MyClass:Extend("MySubclass");
		assert.equals(MyClass:GetName(), "MyClass");
		assert.equals(MySubclass:GetName(), "MySubclass");
	end)

	it("should be able to report its superclass", function()
		local MySubclass = MyClass:Extend("MySubclass");
		assert.equal(MyClass:Parent(), Object);
		assert.equal(MySubclass:Parent(), MyClass);
	end)

	it("should be able to dertermine if it extends a class", function()
		local MySubclass = MyClass:Extend("MySubclass");
		assert.True(MyClass:Extends(Object));
		assert.True(MySubclass:Extends(MyClass));
		assert.True(MySubclass:Extends(Object));
		assert.False(MyClass:Extends(MySubclass));
		assert.False(MyClass:Extends(MyClass));
	end)

	it("should be able to determine if an object is an instance of it", function()
		local MyOtherClass = Object:Extend("MyOtherClass");
		local instance = MyClass:New();
		assert.True(MyClass:IsInstance(instance));
		assert.True(Object:IsInstance(instance));
		assert.False(MyOtherClass:IsInstance(instance));
		assert.False(MyOtherClass:IsInstance(nil));
	end)

	it("should be able to determine if a value is a class", function()
		assert.True(Object:IsClass(Object));
		assert.True(Object:IsClass(MyClass));
		assert.False(Object:IsClass(nil));
		assert.False(Object:IsClass({}));
		assert.False(Object:IsClass(2));
		assert.False(Object:IsClass("string"));
	end)

	it("should be able to determine if a value is an object", function()
		local instance = MyClass:New();
		assert.False(Object:IsObject(Object));
		assert.False(Object:IsObject(MyClass));
		assert.False(Object:IsObject(nil));
		assert.False(Object:IsObject({}));
		assert.False(Object:IsObject(2));
		assert.False(Object:IsObject("string"));
		assert.True(Object:IsObject(instance));
	end)


	---========================================---
	-- Public Member Definition
	---========================================---

	it("should not allow definition of public fields", function()
		assert.error(function()
			MyClass.someField = "value";
		end);
		assert.error(function()
			MyClass.final.someField = "value";
		end);
	end)

	it("should allow definition of public methods", function()
		function MyClass:SomeMethod() end
	end)

	it("should allow definition of public final methods", function()
		function MyClass.final:SomeMethod() end
	end)

	it("should not allow removal of public final methods", function()
		function MyClass.final:SomeMethod() return 1; end
		assert.error(function()
			MyClass.SomeMethod = nil;
		end)
		assert.error(function()
			MyClass.final.SomeMethod = nil;
		end)
	end)


	---========================================---
	-- Public Member Access/Invocation
	---========================================---

	it("should not allow invocation of public methods", function()
		function MyClass:SomeMethod() return "public"; end
		assert.error(function()
			MyClass:SomeMethod();
		end)
	end)

	it("should not allow invocation of public final methods", function()
		function MyClass.final:SomeFinalMethod() return "final"; end
		assert.error(function()
			MyClass:SomeFinalMethod();
		end)
	end)


	---========================================---
	-- Static Member Definition
	---========================================---

	it("should allow definition of static fields", function()
		MyClass.static.someField = "value";
	end)

	it("should allow definition of static final fields", function()
		MyClass.static.final.someField = "value";
	end)


	it("should allow definition of static methods", function()
		function MyClass.static:SomeMethod() end
	end)

	it("should allow definition of static final methods", function()
		function MyClass.static.final:SomeMethod() end
	end)

	it("should not allow removal of static final methods", function()
		function MyClass.static.final:SomeMethod() return 1; end
		assert.error(function()
			MyClass.static.SomeMethod = nil;
		end)
		assert.error(function()
			MyClass.static.final.SomeMethod = nil;
		end)
	end)


	---========================================---
	-- Static Member Access/Invocation
	---========================================---

	it("should not provide access static fields", function()
		MyClass.static.someField = "staticField";
		assert.equals(MyClass.someField, "staticField");
	end)

	it("should provide access static final fields", function()
		MyClass.static.final.SOME_CONSTANT = "constant";
		assert.equals(MyClass.SOME_CONSTANT, "constant");
	end)

	it("should allow invocation of static methods", function()
		function MyClass.static:SomeMethod() return "static"; end
		assert.equals(MyClass:SomeMethod(), "static");
	end)

	it("should allow invocation static final methods", function()
		function MyClass.static.final:SomeMethod() return "static final"; end
		assert.equals(MyClass:SomeMethod(), "static final");
	end)

end)