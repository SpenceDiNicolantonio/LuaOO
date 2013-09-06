require("test/print");
require("src/luaOO")

local tests = {};


--==========================================================================--
-- Functions
--==========================================================================--

---
-- Defines classes used in tests
--
local function createClasses()

	---================== Point2D ==================---
	---=============================================---
	--
	local Point2D = Object:Extend("Point2D");

	function Point2D:Construct(x, y)
		print("Point2D.Construct");
		self.x = x;
		self.y = y;
	end

	function Point2D:Override()
		print("Point2D.Override");
	end

	function Point2D:Only2D()
		print("Point2D.Method2DOnly");
	end

	function Point2D.static:StaticOverride()
		print("Point2D.static.StaticOverride");
	end

	function Point2D.static.StaticOnly2D()
		print("Point2D.static.Static2DOnly");
	end

	function Point2D:ToString()
		return string.format("(%s, %s)", tostring(self.x), tostring(self.y));
	end

	function Point2D.final:Final2D()
		print("Point2D.final.Final2D");
	end

	--	function Point2D.final:Final2D()
	--		print("Overriden final");
	--	end

	function Point2D.static.final:StaticFinal2D()
		print("Point2D.static.final:StaticFinal2D");
	end


	---================== Point3D ==================---
	---=============================================---
	local Point3D = Point2D:Extend("Point3D");

	function Point3D:Construct(x, y, z)
		print("Point3D.Construct");
		--self:Super(x, y);
		self:Super('Construct', x, y);
		self.z = z;
	end

	function Point3D:Override()
		print("Point3D.Override");
	end

	function Point3D:Only3D()
		print("Point3D.Method3DOnly");
	end

	function Point3D.static:StaticOverride()
		print("Point3D.static.StaticOverride");
	end

	function Point3D.static:StaticOnly3D()
		print("Point3D.static.Static3DOnly");
	end

	--	function Point3D.final:Final2D()
	--		print("Point3D.final.Final3D");
	--	end

	--	function Point3D.static.final:StaticFinal2D()
	--		print("Point2D.static.final:StaticFinal3D");
	--	end


	---================== Point4D ==================---
	---=============================================---

	local Point4D = Point3D:Extend("Point4D");

	function Point4D:Construct(x, y, z, a)
		print("Point4D.Construct");
		self:Super('Construct', x, y, z);
		self.a = a;
	end

	function Point4D:ToString()
		return string.format("(%s, %s, %s, %s)", tostring(self.x), tostring(self.y), tostring(self.z), tostring(self.a));
	end


	---================== Return ===================---
	---=============================================---
	--
	return Point2D, Point3D, Point4D;
end



--==========================================================================--
-- Tests
--==========================================================================--

--function tests:classname()
--	-- Should fail
--	Point2D = Object:Extend();
--end

--function tests.method()
--	local Point2D = createPoint2D();
--	
--	function Point2D:DoSomething()
--		print("Point2D:DoSomething()");
--	end
--
--	local p = Point2D:New();
--	p:DoSomething();
--end

--function tests.valueAsMethod()
--	local Point2D = createClasses();
--	
--	Point2D.static.DoSomething = "234234";
--	print(Point2D.DoSomething)
--	
--	-- Should fail
--	Point2D.DoSomething = "234234S";
--end


function tests.extension()
	print()
	print("=================")
	print("CREATING CLASSES")
	print("=================")
	local Point2D, Point3D, Point4D = createClasses();

	--printTable(Point3D)

	--- Instantiation
	print("======================")
	print("INSTANTIATING OBJECTS")
	print("======================")
	local p2 = Point2D:New(11, 22);
	local p3 = Point3D:New(33, 44, 55);
	local p4 = Point4D:New(66, 77, 88, 99);

	--- Print classes
	print()
	print("================")
	print("PRINTING CLASSES")
	print("================")
	print(Object:GetName().."-------------------")
	printTable(Object)
	print()
	print(Point2D:GetName().."-------------------")
	printTable(Point2D)
	print()
	print(Point3D:GetName().."-------------------")
	printTable(Point3D)
	print()
	print(Point4D:GetName().."-------------------")
	printTable(Point4D)
	print()

	--- Print instances
	print()
	print("==================")
	print("PRINTING INSTANCES")
	print("==================")
	print()
	print(p2:GetClass():GetName().."-------------------")
	printTable(p2)
	print()
	print(p3:GetClass():GetName().."-------------------")
	printTable(p3)
	print()
	print(p4:GetClass():GetName().."-------------------")
	printTable(p4)
	print()

	print()
	print()
	print("Tests--------------------")


	print()
	print("=============")
	print("RUNNING TESTS")
	print("=============")

	print()
	print("p2: "..p2:ToString())
	p2:Override();
	p2:Only2D();
	--	p2:Only3D();	-- should fail
	Point2D:StaticOverride();
	--	p2:StaticOnly2D();	-- should fail
	Point2D:StaticOnly2D();
	--	Point2D:StaticOnly3D();	-- should fail
	p2:Final2D();
	Point2D:StaticFinal2D();

	print();
	print("p3: "..p3:ToString());
	p3:Override();
	p3:Only2D();
	p3:Only3D();
	Point3D:StaticOverride();
	Point3D:StaticOnly2D();
	Point3D:StaticOnly3D();
	--	p3:Final3D();
	--	Point3D:StaticFinal3D();

	print();
	print("p4: "..p4:ToString());

	print()
	print("-----------------------------------")
	print()

end



--==========================================================================--
-- Run Tests
--==========================================================================--

for i, test in pairs(tests) do
	test();
end