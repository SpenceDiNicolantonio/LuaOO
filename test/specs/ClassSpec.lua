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
		assert.has.error(function()
			MyClass:Extend();
		end)
		assert.has.error(function()
			MyClass:Extend(2);
		end)
		assert.has.error(function()
			MyClass:Extend(function() end);
		end)
	end)


	it("can report its name", function()
		local MySubclass = Object:Extend("MySubclass");
		assert.equals(MyClass:GetName(), "MyClass");
		assert.equals(MySubclass:GetName(), "MySubclass");
	end)


	it("can report its superclass", function()
		local MySubclass = MyClass:Extend("MySubclass");
		assert.same(MyClass:Parent(), Object);
		assert.same(MySubclass:Parent(), MyClass);
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


	it("cannot define public fields", function()
		assert.has.error(function()
			MyClass.someField = "value";
		end);
		assert.has.error(function()
			MyClass.final.someField = "value";
		end);
	end)


	it("can define public methods", function()
		function MyClass:SomeMethod() end
	end)


	it("can define static fields", function()
		Object.static.someField = "value";
	end)


	it("can define static methods", function()
		function Object.static:SomeStaticMethod() end
	end)


	it("can define public final methods", function()
		function Object.final:SomeFinalMethod() end
	end)


	it("can define static final methods", function()
		function Object.static.final:SomeStaticFinalMethod() end
	end)

end)