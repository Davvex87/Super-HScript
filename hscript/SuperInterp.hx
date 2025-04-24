package hscript;

import haxe.io.Path;
import haxe.ds.Either;
import hscript.Expr;
import hscript.AbstractHScriptClass;
import hscript.HScriptClass;

using StringTools;

@:access(HScriptClass)
@:allow(AbstractHScriptClass)
class SuperInterp extends ReInterp
{
	public static var packages:Map<String, AbstractHScriptClass> = [];

	private var _proxy:AbstractHScriptClass;
	public var imports:Map<String, Dynamic>;

	public var blacklist:Array<Dynamic> = [];

	public static function resolveClass(name:String):Dynamic
	{
		if (packages.exists(name))
			return packages.get(name);

		return Type.resolveClass(name);
	}

	public function new()
	{
		imports = new Map();
		super();
	}

	public function registerStructures(decls:Array<ModuleDecl>, ?file:String = null)
	{
		var pkg:String = "";

		var fileName:Null<String> = file != null ? Path.withoutDirectory(Path.withoutExtension(file)) : null;

		for (d in decls)
		{
			if (d == null)
				continue;

			switch (d)
			{
				case DImport(path, everything):
					// expr(EImport(path, everything, alias));

					var strPath:String = path.join(".");
					if (everything)
					{
						error(ECustom('Bulk import not yet implemented'));
					}
					else
					{
						var c:Dynamic = cast(Type.resolveClass(strPath)) ?? cast(Type.resolveEnum(strPath)) ?? null;
						if (c == null)
							c = cast({
								var p:PossibleImport = {c: strPath};
								p;
							});

						imports.set(path[path.length-1], c);

						if (blacklist.contains(c))
							error(ECustom('Blacklisted import $c'));
					}

				case DPackage(path):

					for (p in path)
					{
						var code = p.charCodeAt(0);
						if (!(code >= 97 && code <= 122))
							error(EUnexpected(p));
					}

					pkg = path.join(".");

				case DClass(c):
					var code = c.name.charCodeAt(0);
					if (!(code >= 65 && code <= 90))
						error(ECustom("Type name should start with an uppercase letter"));

					var extClass:Null<Class<Any>> = null;
					if (c.extend != null)
					{
						switch (c.extend)
						{
							case CTPath(path, params):
								extClass = Type.resolveClass(path.join("."));
							default:
								error(ECustom("Invalid type for extension"));
						}

						if (blacklist.contains(extClass))
							error(ECustom('Blacklisted type $extClass referenced'));
					}

					var cl = _createStaticInstance(c, pkg, extClass);
					
					var pkgName = pkg.length > 0 ? '$pkg.' : '';
					var filePkg = '$pkgName${c.name}';

					if (file != null && c.name != fileName)
						filePkg = '$pkgName$fileName.${c.name}';

					packages.set(filePkg, cl);

					for (importPkg=>obj in imports)
					{
						if (!(obj is PossibleImport))
							continue;

						if (filePkg == importPkg)
							imports.set(importPkg, cl);
					}

				default:
			}
		}

		for (importPkg=>obj in imports)
		{
			if (obj is PossibleImport)
			{
				imports.remove(importPkg);
				error(ECustom('Type not found : $importPkg'));
			}
		}
	}

	private function _createStaticInstance(decl:ClassDecl, pkg:String, extClass:Null<Class<Any>> = null)
	{
		var cl:AbstractHScriptClass = new HScriptClass(decl, extClass, this);
		return cl;
	}

	override function resolve(id:String):Dynamic
	{
		@:privateAccess
		{
			switch(id)
			{
				case "super" if (_proxy != null):
					if (_proxy.superInstance == null)
						return _proxy.superConstructor;
	
					return _proxy.superInstance;

				case "this" if (_proxy != null):
					return _proxy;
			}
		}

		if (_proxy != null)
		{
			if (_proxy.has(id))
				return _proxy.read(id);
		}


		if (variables.exists(id))
			return variables.get(id);
		
		if (imports.exists(id))
			return imports.get(id);
		
		error(EUnknownVariable(id));

		return null;
	}

	override function expr(e:Expr):Dynamic
	{
		if (e == null)
			return null;

		#if hscriptPos
		curExpr = e;
		var x = e.e;
		#end
		switch( #if hscriptPos x #else e #end )
		{
			case EIdent(id):
				var val:Dynamic =  super.expr(e);
				if (blacklist.contains(val))
					error(ECustom('Blacklisted expression $val referenced'));
			case _:
		}
		
		return super.expr(e);
	}
}

@:structInit
class PossibleImport
{
	var c:String;
}