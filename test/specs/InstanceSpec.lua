require("LuaOO")

describe("Instance", function()

	local MyClass;
	local instance;


	before_each(function()
		MyClass = Object:Extend("MyClass");
		instance = MyClass:New();
	end)


	it("can report its class", function()
		assert.equal(instance:GetClass(), MyClass);
		assert.not_equal(instance:GetClass(), Object);
	end)


	it("provides a string representation of itself", function()
		assert.is_string(instance.ToString());
	end)


	it("can determine if its an instance of a class", function()
		MySubclass = MyClass:Extend("MySubclass");
		assert.True(instance:InstanceOf(MyClass));
		assert.True(instance:InstanceOf(Object));
		assert.False(instance:InstanceOf(MySubclass));
		assert.error(function()
			instance:InstanceOf(nil)
		end);
	end)

end)