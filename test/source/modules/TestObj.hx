package modules;

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