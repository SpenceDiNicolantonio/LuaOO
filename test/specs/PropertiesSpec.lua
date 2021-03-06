require("LuaOO")

describe("Properties", function()

	local Point;
	local instance;


	before_each(function()
		Point = Object:Extend("Point");

		Point:InitProperty("x");

		function Point:GetX()
			return self.realX;
		end

		function Point:SetX(x)
			self.realX = x;
		end


		Point:InitProperty("y",
			function(self)
				return self.realY;
			end,
			function(self, y)
				self.realY = y;
			end
		);

		Point:InitProperty("sameName",
			function(self)
				return self.sameName;
			end,
			function(self, value)
				self.sameName = value;
			end
		);

		Point:InitFinalProperty("finalProperty");

		instance = Point:New();
	end)


	it("should be accessed directly if property method does not exist", function()
		instance.realX = 5;
		instance.realY = 10;
		assert.equal(instance.realX, 5);
		assert.equal(instance.realY, 10);
	end)

	it("should use accessor method if it exists", function()
		instance.realX = 5;
		instance.realY = 10
		assert.equal(instance.x, 5);
		assert.equal(instance.y, 10);
	end)

	it("should use mutator method if it exists", function()
		instance.x = 5;
		instance.y = 10
		assert.equal(instance.realX, 5);
		assert.equal(instance.realY, 10);
	end)

	it("should work with properties that match the name of the underlying field", function()
		instance.sameName = 5
		assert.equal(instance.sameName, 5);
	end)

	it("should not allow overwriting of final properties", function()
		instance.finalProperty = 5;
		assert.error(function()
			instance.finalProperty = 10;
		end)
	end)

end)