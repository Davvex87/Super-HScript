package;

import utest.Runner;
import utest.ui.Report;

import cases.ClassFeaturesCase;
import cases.LanguageFeaturesCase;

class Test
{
	static function main()
	{
		var runner = new Runner();

		runner.addCase(new LanguageFeaturesCase());
		runner.addCase(new ClassFeaturesCase());

		Report.create(runner);
		runner.run();
	}
}