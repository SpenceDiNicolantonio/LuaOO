LuaOO [![Build Status](https://travis-ci.org/Pezzer13/LuaOO.png?branch=master)](https://travis-ci.org/Pezzer13/LuaOO)
=====
A framework for Java-inspired object oriented programming in Lua.

Features
-----------
- Inheritence (single inheritence through extension)
- Constructors
- Properties
- Static class members
- Final class members
- Method overriding
- Invocation of superclass methods (including constructors)
- Immutable Object References
- `GetClass()`
- `InstanceOf()`
- `Parent()`

Usage
-----
Lets define two simple classes to greet people. The first will say hello in English, the second in Spanish.
```Lua
-- Require LuaOO to define the global base class 'Object'
require("LuaOO");


-- Define Greeter class by extending Object
local Greeter = Object:Extend("Greeter");

-- Define a public method on the Greeter class to construct a greeting
function Greeter:GetGreeting(name)
  return string.format("Hello %s!", name);
end

-- Define a public final method on the Greeter class
function Greeter.final:Greet()
  local greeting = self:GetGreeting();
  print(greeting);
end


-- Define a Spanish Greeter class that extends Greeter
local SpanishGreeter = Greeter:Extend("SpanishGreeter");

-- Override the SpanishGreeter class' GetGreeting method to return a spanish greeting
function SpanishGreeter:GetGreeting(name)
  return string.format("Hola %s!", name);
end


-- Create instances of each class
local greeter = Greeter:New();
local spanishGreeter = SpanishGreeter:New();


-- Say hello!
greeter:Greet("Pezzer");        -- Hello Pezzer!
spanishGreeter:Greet("Pezzer"); -- Hola Pezzer!
```


Constructors
------------
When a class is instantiated, `Construct()` will be called with any arguments passed to `New()`.
```Lua
local Point = Object:Extend("Point");

function Point:Construct(x, y)
  self.x = x;
  self.y = y;
end

local myPoint = Point:New(6, 13);
-- myPoint -> {x = 6, y = 13}
```


Static Members
--------------
Static members can be defined on a clas using the `static` definition handle.
```Lua
local MyClass = Object:Extend("MyClass");

-- Static value
MyClass.static.myStaticValue = 13;

-- Static method
function MyClass.static:MyStaticMethod()
  print(MyClass.myStaticValue)
end


-- Static members are accessed at the class level
print(MyClass.myStaticValue); --> 13
MyClass:MyStaticMethod(); --> 13
```

Constants / Final Members
-------------------------
Class members defined as `final` cannot be overridden.
```Lua
local MyClass = Object:Extend("MyClass");

-- Final static value (class constant)
MyClass.static.final.MY_CONSTANT = 13;

-- Final static method
function MyClass.static.final:MyStaticFinalMethod()
  print(MyClass.MY_CONSTANT);
end

-- Final instance method
function MyClass.final:MyFinalInstanceMethod()
  print(MyClass.MY_CONSTANT);
end


-- Final members are accessed the same as non-final members
print(MyClass.MY_CONSTANT); --> 13
MyClass:MyStaticFinalMethod(); --> 13

local instance = MyClass:New();
instance:MyFinalInstanceMethod(); --> 13


-- Attempting to override final members will result in an error
MyClass.MY_CONSTANT = "new value"; --> ERROR!
```

Properties
----------
Class properties can be declared on a class via the `InitProperty()` method. Properties will automatically be
accessed/mutated through getter/setter methods, if defined. If an appropriate getter/setter is not defined, the
property will simply be accessed directly.

The naming convention for property getter and setter methods is `Get<PropertyName>` and `Set<PropertyName>`,
respectively, where the first character of the property name is capitalized. For example, a property named `value`
would use accessor `GetValue()` and mutator `SetValue()`.

```Lua
local Point = Object:Extend("Point");

-- Declare properties
Point:InitProperty("x");
Point:InitProperty("y");

function Point:GetX()
  return self.x;
end

function Point:SetX(value)
  self.x = value;
end

-- Notice getter/setter methods haven't been defined for property 'y'


-- Properties allow us utilize getter/setter methods implicitely 
local myPoint = Point:New();
myPoint.x;       -- Invokes myPoint:GetX()
myPoint.y;       -- Accesses myPoint.y directly, because Point:GetY() is undefined
myPoint.x = 5;   -- Invokes myPoint:SetX(5)
myPoint.y = 10;  -- Mutates myPoint.y directly, because Point:SetY() is undefined
```

While property getter/setter methods can be defined explicitely, independent of the property's initialization,
they can also be passed as arguments to the `InitProperty()` method for convenience. The `x` property in the previous
example could have been defined as follows:


```Lua
Point:InitProperty("x",
  function(self)
    return self.x;
  end,
  function(self, value)
    self.x = value;
  end
);
```


Immutable Object references
---------------------------
One of the goals of LuaOO is to preserve as much of the default functionality in the Lua language as possible. 
For this reason, all fields are public members and can be mutated directly:
```Lua
local MyClass = Object:Extend("MyClass");

function MyClass:Construct()
  self.value = "some value";
end

local instance = MyClass:New();

-- Fields are public and accessable directly
instance.value = "some other value";
```
In certain cases, it may be desirable to make an instance immutable. This can be acomplished using the `ReadOnly()`
method, which is defined in the `Object` base class. This method will return an immutable wrapper to the instance on 
which the method was called. This feature is especially convenient for defining class constants:
```Lua
local Color = Object:Extend("Color");

function Color:Construct(r, g, b)
  self.r = r;
  self.g = g;
  self.b = b;
end

Color.static.final.BLACK = Color:New(0, 0, 0):ReadOnly();
Color.static.final.WHITE = Color:New(255, 255, 255):ReadOnly();
Color.static.final.MAGENTA = Color:New(255, 0, 255):ReadOnly();
...

-- Attempting to mutate a read-only reference will result in an error
Color.static.final.MAGENTA.r = 0; --> ERROR!
```
