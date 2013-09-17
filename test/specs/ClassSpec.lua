require("LuaOO")

describe("Class", function()

	local MyClass;

	before_each(function()
		MyClass = Object:Extend("MyClass");
	end)


	it("can be instantiated", function()
		local instance = MyClass:New();
		assert.truthy(instance);
	end)


	it("can be extended", function()
		local subclass = MyClass:Extend("MySubclass");
		assert.truthy(subclass);
	end)


	it("requires a class name for extension", function()
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


	it("can report its name", function()
		local MySubclass = MyClass:Extend("MySubclass");
		assert.equals(MyClass:GetName(), "MyClass");
		assert.equals(MySubclass:GetName(), "MySubclass");
	end)


	it("can report its superclass", function()
		local MySubclass = MyClass:Extend("MySubclass");
		assert.equal(MyClass:Parent(), Object);
		assert.equal(MySubclass:Parent(), MyClass);
	end)


	it("can dertermine if it extends a class", function()
		local MySubclass = MyClass:Extend("MySubclass");
		assert.True(MyClass:Extends(Object));
		assert.True(MySubclass:Extends(MyClass));
		assert.True(MySubclass:Extends(Object));
		assert.False(MyClass:Extends(MySubclass));
		assert.False(MyClass:Extends(MyClass));
	end)


	it("can determine if an object is an instance of it", function()
		local MyOtherClass = Object:Extend("MyOtherClass");
		local instance = MyClass:New();
		assert.True(MyClass:IsInstance(instance));
		assert.True(Object:IsInstance(instance));
		assert.False(MyOtherClass:IsInstance(instance));
		assert.False(MyOtherClass:IsInstance(nil));
	end)


	it("does not allow definition of public fields", function()
		assert.error(function()
			MyClass.someField = "value";
		end);
		assert.error(function()
			MyClass.final.someField = "value";
		end);
	end)


	it("allows definition of public methods", function()
		function MyClass:SomeMethod() end
	end)


	it("allows definition of static fields", function()
		MyClass.static.someField = "value";
	end)


	it("allows definition of static methods", function()
		function MyClass.static:SomeStaticMethod() end
	end)


	it("allows definition of public final methods", function()
		function MyClass.final:SomeFinalMethod() end
	end)


	it("allows definition of static final methods", function()
		function MyClass.static.final:SomeStaticFinalMethod() end
	end)


	it("cannot call public methods", function()
		function MyClass:SomeMethod() return "public"; end
		assert.error(function()
			MyClass:SomeMethod();
		end)
	end)


	it("cannot call public final methods", function()
		function MyClass.final:SomeFinalMethod() return "final"; end
		assert.error(function()
			MyClass:SomeFinalMethod();
		end)
	end)


	it("can call static methods", function()
		function MyClass.static:SomeStaticMethod() return "static"; end
		assert.equals(MyClass:SomeStaticMethod(), "static");
	end)


	it("can call static final methods", function()
		function MyClass.static.final:SomeStaticFinalMethod() return "static final"; end
		assert.equals(MyClass:SomeStaticFinalMethod(), "static final");
	end)


	it("should be able to remove methods", function()
		function MyClass:SomeFunction() return 1; end
		function MyClass.static.SomeStaticFunction() return 1; end
		MyClass.SomeFunction = nil;
		MyClass.static.SomeStaticFunction = nil;
	end)


	it("should not be able to remove final methods", function()
		function MyClass.final:SomeFinalFunction() return 1; end
		function MyClass.static.final:SomeStaticFinalFunction() return 1; end
		assert.error(function()
			MyClass.SomeFinalFunction = nil;
		end)
		assert.error(function()
			MyClass.final.SomeFinalFunction = nil;
		end)
		assert.error(function()
			MyClass.static.SomeStaticFinalFunction = nil;
		end)
		assert.error(function()
			MyClass.static.final.SomeStaticFinalFunction = nil;
		end)
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

end)