require("LuaOO")

describe("ReadOnly", function()

	local MyClass;
	local instance;


	before_each(function()
		MyClass = Object:Extend("MyClass");

		function MyClass:Construct()
			self.value = 0;
		end

		function MyClass:GetValue()
			return self.value;
		end

		function MyClass:SetValue(newValue)
			self.value = newValue;
		end

		instance = MyClass:New();
	end)


	it("should provide access to a read-only version of an instance", function()
		instance:SetValue(15);
		local readOnly = instance:ReadOnly();
		assert.equal(readOnly:GetValue(), 15);
	end)

	it("should not allow mutation of read-only instance wrappers", function()
		local readOnly = instance:ReadOnly();
		assert.error(function()
			readOnly.x = "some value";
		end)
		assert.error(function()
			readOnly:SetValue(10);
		end)
	end)

	it("should allow mutation of normal instance reference after read-only version is created", function()
		instance:SetValue(15);
		local readOnly = instance:ReadOnly();
		assert.equal(instance:GetValue(), 15);
		assert.equal(readOnly:GetValue(), 15);
		instance:SetValue(20);
		assert.equal(instance:GetValue(), 20);
		assert.equal(readOnly:GetValue(), 20);


	end)

end)