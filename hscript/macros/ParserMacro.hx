package hscript.macros;

import haxe.macro.Type.Ref;
import haxe.macro.Type.ClassType;
import haxe.macro.Type.TFunc;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
	Macro used to modify and add fields to existing hscript classes and enums.
	
	This macro is internal use only and **should not be called in production**.
**/
class ParserMacro
{
	private static macro function buildAll():Array<Field>
	{
		var fields = Context.getBuildFields();
		var type = Context.getLocalType();
		var cls = Context.getLocalClass();

		if (cls == null && type != null)
			return addCustomTokens(type, fields);
		else if(cls != null)
			return addCustomTokenPrinters(cls, fields);

		return fields;
	}
	private static function addCustomTokens(type:haxe.macro.Type, fields:Array<Field>):Array<Field>
	{
		if (type == null) return fields;

		switch(type)
		{
			case TEnum(t, params):
				var e = t.get();
				if (e.name != "Token")  return fields;

				function makeEnumField(name, kind):Field
				{
					for (f in fields)
						if (f.name == name)
							return null;

					var field:Field = {
						name: name,
						doc: null,
						meta: [],
						access: [],
						kind: kind,
						pos: Context.currentPos()
					};
					fields.push(field);
					return field;
				}

				makeEnumField("TApostr", FVar(null, null));
			case _:
		}

		return fields;
	}

	private static function addCustomTokenPrinters(cls:Ref<ClassType>, fields:Array<Field>):Array<Field>
	{
		for (field in fields)
		{
			if (field.name != "tokenString") continue;
			switch(field.kind)
			{
				case FFun(f):
					f.expr = macro {
						return switch( $i{"t"} ) {
						case TEof: "<eof>";
						case TConst(c): constString(c);
						case TId(s): s;
						case TOp(s): s;
						case TPOpen: "(";
						case TPClose: ")";
						case TBrOpen: "{";
						case TBrClose: "}";
						case TDot: ".";
						case TQuestionDot: "?.";
						case TComma: ",";
						case TSemicolon: ";";
						case TBkOpen: "[";
						case TBkClose: "]";
						case TQuestion: "?";
						case TDoubleDot: ":";
						case TMeta(id): "@" + id;
						case TPrepro(id): "#" + id;
						case TApostr: "<apostrophe>";
						}
					}
				default:
			}
		}
		
		return fields;
	}
}