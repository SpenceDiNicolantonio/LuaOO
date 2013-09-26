require("LuaOO")

describe("Instance", function()

	local MyClass;
	local instance;


	before_each(function()
		MyClass = Object:Extend("MyClass");
		instance = MyClass:New();
		instance.publicField = "public field";
	end)


	---========================================---
	-- Query Methods
	---========================================---

	it("should be able to report its class", function()
		assert.equal(instance:GetClass(), MyClass);
		assert.not_equal(instance:GetClass(), Object);
	end)

	it("should be able to generate a string representation of itself", function()
		assert.is_string(instance.ToString());
	end)

	it("should be able to determine if its an instance of a class", function()
		MySubclass = MyClass:Extend("MySubclass");
		assert.True(instance:InstanceOf(MyClass));
		assert.True(instance:InstanceOf(Object));
		assert.False(instance:InstanceOf(MySubclass));
		assert.error(function()
			instance:InstanceOf(nil)
		end);
	end)


	---========================================---
	-- Public Member Definition
	---========================================---

	it("should allow definition of public methods", function()
		function instance:SomeMethod()
			return "public";
		end
		assert.equal(instance:SomeMethod(), "public");
	end)

	it("should allow definition of public fields", function()
		instance.someField = "field"
		assert.equal(instance.someField, "field");
	end)


	---========================================---
	-- Public Member Access/Invocation
	---========================================---

	it("should allow invocation of public methods", function()
		function MyClass:SomeMethod()
			return "public";
		end
		assert.equal(instance:SomeMethod(), "public");
	end)

	it("should allow invocation of public final methods", function()
		function MyClass.final:SomeMethod()
			return "final";
		end
		assert.equal(instance:SomeMethod(), "final");
	end)


	---========================================---
	-- Static Member Access/Invocation
	---========================================---

	it("should not allow invocation of static methods", function()
		function MyClass.static:SomeStaticMethod()
			return "static";
		end
		assert.error(function()
			instance:SomeStaticMethod();
		end);
	end)

	it("should not allow invocation of static final methods", function()
		function MyClass.static:SomeStaticFinalMethod()
			return "static final";
		end
		assert.error(function()
			instance:SomeStaticMethod();
		end);
	end)


	---========================================---
	-- Superclass Method Invocation
	---========================================---

	it("should allow invocation of superclass methods", function()
		Greeter = Object:Extend("Greeter");
		function Greeter:GetGreeting(name)
			return ("Hello "..name);
		end

		SpanishGreeter = Greeter:Extend("SpanishGreeter");
		function SpanishGreeter:GetGreeting(name)
			return ("Hola "..name);
		end

		local spanishGreeter = SpanishGreeter:New();
		local spanishGreeting = spanishGreeter:GetGreeting("Bob");
		local englishGreeting = spanishGreeter:Super('GetGreeting', "Bob");

		assert.equal(spanishGreeting, "Hola Bob");
		assert.equal(englishGreeting, "Hello Bob");
	end)

end)