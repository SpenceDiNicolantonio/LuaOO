require("LuaOO")

describe("Class", function()

	it("can be instantiated", function()
		local object = Object:New();
		assert.truthy(object)
	end)

	it("can be extended", function()
		local class = Object:Extend("MyClass");
		assert.truthy(class);
	end)

	it("cannot be extended without class name", function()
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
		local MyClass = Object:Extend("MyClass");
		assert.equals(Object:GetName(), "Object")
		assert.equals(MyClass:GetName(), "MyClass")
	end)

	it("can report its superclass", function()
		local MyClass = Object:Extend("MyClass");
		local MySubclass = MyClass:Extend("MySubclass");
		assert.Nil(Object:Parent());
		assert.same(MyClass:Parent(), Object);
		assert.same(MySubclass:Parent(), MyClass);
	end)

	it("can dertermine if it extends a class", function()
		local MyClass = Object:Extend("MyClass");
		local MySubclass = MyClass:Extend("MySubclass");
		assert.True(MyClass:Extends(Object));
		assert.True(MySubclass:Extends(MyClass));
		assert.False(MyClass:Extends(MySubclass));
		assert.False(Object:Extends(nil));
	end)

	it("can determine if an object is an instance of itself", function()
		local MyClass = Object:Extend("MyClass");
		local MyOtherClass = Object:Extend("MyOtherClass");
		local myInstance = MyClass:New();
		assert.True(MyClass:IsInstance(myInstance));
		assert.True(Object:IsInstance(myInstance));
		assert.False(MyOtherClass:IsInstance(myInstance));
		assert.False(MyOtherClass:IsInstance(nil));
	end)

end)