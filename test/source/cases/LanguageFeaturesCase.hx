package cases;

import modules.TestObj;
import Shared;

import utest.ITest;
import utest.Assert;

/**
 * Test suite class for ensuring language features work correctly.
 * It provides test functions for vanilla HScript features and also Super-HScript specific features.
 */
class LanguageFeaturesCase implements ITest
{
	public function new() {}

	/**
	 * Tests basic mathematic operators.
	 */
	function testArithmetic()
	{
		Assert.equals(7, evalExpr('3 + 4;'));
		Assert.equals(14, evalExpr('3 * 4 + 2;'));
		Assert.equals(4, evalExpr('16 / (7 - 3);'));
	}

	/**
	 * Tests conditions with boolean algebra.
	 */
	function testConditions()
	{
		Assert.isTrue(evalExpr("3 > 1;"));
		Assert.isTrue(evalExpr("3 >= 3;"));
		Assert.isFalse(evalExpr("4 < 7 && 1 + 2 == 4;"));
		Assert.isTrue(evalExpr("false || 1 % 2 == 1;"));
		Assert.equals("I am at work", evalExpr("if (true == false) 'I am here'; else 'I am at work';"));
		Assert.equals(3, evalExpr("false ? 10 : 3;"));
	}

	/**
	 * Tests for string interpolation.
	 */
	function testStringInterpolation()
	{
		Assert.equals("Hello, World!", evalExpr("'Hello, ${params[0]}!';", ["World"]));
		Assert.equals("I have 5 coins", evalExpr("'I have ${3+2} coins';"));
		Assert.equals("OneTwoThree", evalExpr("'${params[0]}${params[1]}${params[2]}';", ["One","Two","Three"]));
	}

	/**
	 * Tests the var operator, local assignments and other special assignment operators.
	 */
	function testAssignment()
	{
		Assert.equals(7, evalExpr('var a = 5; a += 2;'));
		Assert.equals('foo', evalExpr("var a:String = null; a ??= 'foo'; a;"));
	}

	/**
	 * Tests optional chaining expressions.
	 */
	function testOptionalChaining()
	{
		Assert.equals('ok', evalExpr('var a = { f: "ok" }; a?.f;'));
		Assert.isNull(evalExpr('var a = null; a?.f;'));
	}

	/**
	 * Tests for field write and read operations on both anonymous structures and class objects.
	 */
	function testFields()
	{
		Assert.equals(5.5, evalExpr("TestObj.myVar;", ["TestObj"=>TestObj]));
		Assert.equals("3 apples", evalExpr("TestObj.testFunc(3, 'apple');", ["TestObj"=>TestObj]));
		Assert.equals(2, evalExpr("var t = new TestObj(); t.secretCode[2];", ["TestObj"=>TestObj]));
		Assert.equals("SECRET_CODE", evalExpr("var t = new TestObj(); t.getRecovery();", ["TestObj"=>TestObj]));

		var obj:Dynamic = evalExpr("{ n1: 5, others: {o1: true, o2: 'NO!'}}");

		Assert.equals(5, obj.n1);
		Assert.isTrue(obj.others.o1);
		evalExpr("obj.others.o2 = 'YES!'", ["obj"=>obj]);
		Assert.equals("YES!", obj.others.o2);
	}

	/**
	 * Tests function definitions, function calls and function arguments.
	 * Type definitions are ignored.
	 */
	function testFunctions()
	{
		// First test: Tests for declaring a function and calling it from Haxe with some arguments.

		var fn:Dynamic = evalExpr('function(arg1, num) { return arg1 + num; }');
		if (Type.typeof(fn) == Type.ValueType.TFunction)
			Assert.pass("fn correctly declared as a function");
		else 
			Assert.fail("fn test failed, function not declared");

		Assert.equals(7, fn(3, 4));
		Assert.equals("Hi", fn("H", "i"));


		// Second test: Tests for modifications on objects not present to the locals map.

		var fn2:Dynamic = evalExpr('function(obj) {obj.a = true; obj.n.b += 3;}');
		if (Type.typeof(fn2) == Type.ValueType.TFunction)
			Assert.pass("fn2 correctly declared as a function");
		else 
			Assert.fail("fn2 test failed, function not declared");

		var obj = {
			a: false,
			n: {
				b: 2
			}
		}

		fn2(obj);

		Assert.isTrue(obj.a);
		Assert.equals(5, obj.n.b);
	}

	/**
	 * Tests for while, do-while, for and recursion loops.
	 */
	function testLoops()
	{
		// For loops
		Assert.equals(1024, evalExpr('var o = 1; for (i in 0...10) o *= 2; o;'));

		// While and Do-While loops
		Assert.equals(9, evalExpr('var o = 0; while (o < 9) o+=1; o;'));
		Assert.equals(-1, evalExpr('var o = 0; do o-=1 while (o > 0); o;'));
		Assert.equals(0, evalExpr('var o = 3; do o-=1 while (o > 0); o;'));
		Assert.equals(0, evalExpr('var o = 0; while (o > 0) o-=1; o;'));
		Assert.equals(-3, evalExpr('var o = -3; while (o > 0) o-=1; o;'));

		// Recursion loops
		try
			{ Assert.equals(9, evalExpr('var o = 0; function r() { if (o >= 9) return o; o+=1; return r(); } r();')); }
		catch(e:Dynamic)
			Assert.fail("function recursed forever");
	}

	/**
	 * Tests for basic iterators.
	 */
	function testIterators()
	{
		Assert.equals(6, evalExpr('var o = 0; for (i in [1, 2, 3]) o+=i; o;'));
	}


	
	// TODO

	function testPartialFunction() {}
	function testProperties() {}
	function testDefines() {}
	function testGADT() {}
	function testPatternMatching() {}
}