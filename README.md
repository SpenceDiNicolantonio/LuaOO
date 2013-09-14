LuaOO
=====
[![Build Status](https://travis-ci.org/Pezzer13/LuaOO.png?branch=master)](https://travis-ci.org/Pezzer13/LuaOO)

An framework for Java-inspired object oriented programming in Lua.


Example
-------
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
function MyClass.static.MyStaticMethod()
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
