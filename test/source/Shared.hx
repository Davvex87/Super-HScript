import haxe.io.Path;
import sys.io.File;
import hscript.*;

function evalExpr(expr:String, ?vars: Map<String, Dynamic>, ?params:Array<Dynamic>):Dynamic
{
	var parser = new SuperParser();
	var interp = new SuperInterp();

	var program = parser.parseString(expr, '<eval>', 0);

	if (params != null)
		interp.variables.set("params", params);

	if (vars != null)
		for (key => value in vars)
			interp.variables.set(key, value);
	
	return interp.execute(program);
}

function evalFile(file:String, ?vars:Map<String, Dynamic>):Dynamic
{
	var expr = File.getContent(file);
	var fname = Path.withoutDirectory(file);

	var parser = new SuperParser();
	var interp = new SuperInterp();

	var program = parser.parseString(expr, fname, 0);
	var modules = parser.parseModule(expr, fname, 0);

	if (vars != null)
		for (key => value in vars)
			interp.variables.set(key, value);

	interp.registerStructures(modules, file);
	return interp.execute(program);
}