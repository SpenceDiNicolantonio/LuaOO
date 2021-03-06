require("LuaOO")

describe("Extension", function()

	local Point1D;
	local Point2D;
	local Point3D;
	local p1;
	local p2;
	local p3;

	before_each(function()

		Point1D = Object:Extend("Point1D");
		function Point1D:Construct(x)
			self.x = x;
		end

		Point2D = Point1D:Extend("Point2D");
		function Point2D:Construct(x, y)
			self:Super('Construct', x);
			self.y = y;
		end

		Point3D = Point2D:Extend("Point3D");
		function Point3D:Construct(x, y, z)
			self:Super('Construct', x, y);
			self.z = z;
		end

		p1 = Point1D:New(11);
		p2 = Point2D:New(22, 33);
		p3 = Point3D:New(44, 55, 66);
	end)


	---========================================---
	-- Public Member Inheritence
	---========================================---

	it("should inherit public methods", function()
		function Point1D:ToString() return "a point" end
		assert.equals(p1:ToString(), "a point");
		assert.equals(p2:ToString(), "a point");
		assert.equals(p3:ToString(), "a point");
	end)

	it ("should inherit public final methods", function()
		function Point1D.final:ToString() return "a point" end
		assert.equals(p1:ToString(), "a point");
		assert.equals(p2:ToString(), "a point");
		assert.equals(p3:ToString(), "a point");
	end)


	---========================================---
	-- Public Member Overriding
	---========================================---

	it("should allow overriding of public methods", function()
		function Point1D:ToString() return ("("..self.x..")"); end
		function Point2D:ToString() return ("("..self.x..", "..self.y..")"); end
		function Point3D:ToString() return ("("..self.x..", "..self.y..", "..self.z..")"); end

		assert.equals(p1:ToString(), "(11)");
		assert.equals(p2:ToString(), "(22, 33)");
		assert.equals(p3:ToString(), "(44, 55, 66)");
	end)

	it("should not allow overriding of public final methods", function()
		function Point1D:ToString() return "a 1D point"; end
		function Point2D.final:ToString() return "a 2D point"; end
		assert.error(function()
			function Point3D:ToString() return "a 3D point"; end
		end)
		assert.error(function()
			function Point3D.final:ToString() return "a 3D point"; end
		end)
	end)


	---========================================---
	-- Static Member Inheritence
	---========================================---

	it("should inherit static methods", function()
		function Point1D.static:ToString() return "a point" end
		assert.equals(Point1D:ToString(), "a point");
		assert.equals(Point2D:ToString(), "a point");
		assert.equals(Point3D:ToString(), "a point");
	end)

	it ("should inherit static final methods", function()
		function Point1D.static.final:ToString() return "a point" end
		assert.equals(Point1D:ToString(), "a point");
		assert.equals(Point2D:ToString(), "a point");
		assert.equals(Point3D:ToString(), "a point");
	end)


	---========================================---
	-- Static Member Overriding
	---========================================---

	it("should not allow overriding of static final values", function()
		Point1D.static.final.someStaticValue = 13;
		assert.error(function()
			Point1D.static.someStaticValue = 6;
		end)
		assert.error(function()
			Point1D.static.final.someStaticValue = 6;
		end)
	end)

	it("should allow overriding of static methods", function()
		function Point1D.static:Dimensions() return 1; end
		function Point2D.static:Dimensions() return 2; end
		function Point3D.static:Dimensions() return 3; end

		assert.equals(Point1D:Dimensions(), 1);
		assert.equals(Point2D:Dimensions(), 2);
		assert.equals(Point3D:Dimensions(), 3);
	end)

	it("should not allow overriding of static final methods", function()
		function Point1D.static:Dimensions() return 1; end
		function Point2D.static.final:Dimensions() return 2; end
		assert.error(function()
			function Point3D.static:Dimensions() return 3; end
		end)
		assert.error(function()
			function Point3D.static.final:Dimensions() return 3; end
		end)
	end)


	---========================================---
	-- Constructor Inheritence
	---========================================---

	it("should inherit constructor logic", function()
		local MyClass = Object:Extend("MyClass");
		local MySubclass = MyClass:Extend("MySubclass");
		function MyClass:Construct()
			self.value = "MyClass value";
		end

		local myClassInstance = MyClass:New();
		local mySubclassInstance = MySubclass:New();
		assert.equal(myClassInstance.value, mySubclassInstance.value);
	end)

end)