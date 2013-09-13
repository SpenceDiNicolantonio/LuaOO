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


	it("can call public methods", function()
		function MyClass:SomeMethod()
			return "public";
		end
		assert.equal(instance:SomeMethod(), "public");
	end)


	it("can call public final methods", function()
		function MyClass.final:SomeMethod()
			return "final";
		end
		assert.equal(instance:SomeMethod(), "final");
	end)


	it("cannot call static methods", function()
		function MyClass.static:SomeStaticMethod()
			return "static";
		end
		assert.error(function()
			instance:SomeStaticMethod();
		end);
	end)


	it("cannot call static final methods", function()
		function MyClass.static:SomeStaticFinalMethod()
			return "static final";
		end
		assert.error(function()
			instance:SomeStaticMethod();
		end);
	end)


	it("can call superclass methods", function()
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