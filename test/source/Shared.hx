import hscript.*;

function evalExpr(expr:String, ?vars: Map<String, Dynamic>, ?params:Array<Dynamic>):Dynamic
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