package;

import utest.ITest;
import utest.Assert;
import hscript.*;

class Test
{
	static function main()
	{
		var runner = new utest.Runner();

		runner.addCase(new TestHScriptFeatures());
		runner.addCase(new TestHScriptOOP());

		utest.ui.Report.create(runner);
		runner.run();
	}
}

class TestHScriptFeatures implements ITest
{
	public function new() {}

	private function evalExpr(expr:String, ?vars: Map<String, Dynamic>, ?params:Array<Dynamic>):Dynamic
	{
		var parser = new SuperParser();
		var interp = new SuperInterp();

		var program = parser.parseString(expr, '<eval>', 0);

		if (params != null)
			interp.variables.set("params", params);

		if (vars != null)
		{
			for (key => value in vars)
			{
				interp.variables.set(key, value);
			}
		}

		return interp.execute(program);
	}

	function testArithmetic()
	{
		Assert.equals(7, evalExpr('3 + 4;'));
		Assert.equals(14, evalExpr('3 * 4 + 2;'));
		Assert.equals(4, evalExpr('16 / (7 - 3);'));
	}

	function testConditions()
	{
		Assert.isTrue(evalExpr("3 > 1;"));
		Assert.isTrue(evalExpr("3 >= 3;"));
		Assert.isFalse(evalExpr("4 < 7 && 1 + 2 == 4;"));
		Assert.isTrue(evalExpr("false || 1 % 2 == 1;"));
		Assert.equals("I am at work", evalExpr("if (true == false) 'I am here'; else 'I am at work';"));
		Assert.equals(3, evalExpr("false ? 10 : 3;"));
	}

	function testStringInterpolation()
	{
		Assert.equals("Hello, World!", evalExpr("'Hello, ${params[0]}!';", ["World"]));
		Assert.equals("I have 5 coins", evalExpr("'I have ${3+2} coins';"));
		Assert.equals("OneTwoThree", evalExpr("'${params[0]}${params[1]}${params[2]}';", ["One","Two","Three"]));
	}

	function testAssignment()
	{
		Assert.equals(7, evalExpr('var a = 5; a += 2;'));
		Assert.equals('foo', evalExpr("var a:String = null; a ??= 'foo'; a;"));
	}

	function testOptionalChaining()
	{
        Assert.equals('ok', evalExpr('var a = { f: "ok" }; a?.f;'));
        Assert.isNull(evalExpr('var a = null; a?.f;'));
    }

	function testFields()
		{
			Assert.equals(5.5, evalExpr("TestObj.myVar;", ["TestObj"=>TestObj]));
			Assert.equals("3 apples", evalExpr("TestObj.testFunc(3, 'apple');", ["TestObj"=>TestObj]));
			Assert.equals(2, evalExpr("var t = new TestObj(); t.secretCode[2];", ["TestObj"=>TestObj]));
			Assert.equals("SECRET_CODE", evalExpr("var t = new TestObj(); t.getRecovery();", ["TestObj"=>TestObj]));

			var obj:Dynamic = evalExpr("return { n1: 5, others: {o1: true, o2: 'NO!'}}");

			Assert.equals(5, obj.n1);
			Assert.isTrue(obj.others.o1);
			evalExpr("obj.others.o2 = 'YES!'", ["obj"=>obj]);
			Assert.equals("YES!", obj.others.o2);
		}

	function testFunctions()
	{
		var fn:Dynamic = evalExpr('function(arg1, num) { return arg1 + num; }');
		if (Type.typeof(fn) == Type.ValueType.TFunction)
			Assert.pass("fn correctly declared as a function");
		else 
			Assert.fail("fn test failed, function not declared");

		Assert.equals(7, fn(3, 4));
		Assert.equals("Hi", fn("H", "i"));

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
}

class TestHScriptOOP
{
	public function new() {}
}

class TestObj
{
	public static var myVar:Float = 5.5;
	public static function testFunc(num:Int, fruit:String)
	{
		return '$num ${fruit}s';
	}

	public function new() {}

	public var secretCode:Array<Int> = [4,3,2,1];
	public function getRecovery()
	{
		return "SECRET_CODE";
	}
}