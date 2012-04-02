#if macro
import haxe.macro.Expr;
#end

class UserScript
{
    @:macro public static function extract_meta(uscls:String, file:String):Expr
    {
        haxe.macro.Context.onGenerate(function (types) {
            for (type in types) {
                switch (type) {
                    case TInst(c, _):
                        var cls = c.get();
                        if (cls.name == uscls) {
                            var meta = cls.meta.get();
                            var usheader = macro.UserScript.generate_meta(meta);
                            usheader += "\n#CODE_HERE#\n";

                            var outfile = neko.io.File.write(file, false);
                            outfile.writeString(usheader);
                            outfile.close();
                        }
                    default:
                }
            }
        });

        var ret = EConst(CType("Void"));
        return {expr: ret, pos:haxe.macro.Context.currentPos()};
    }

#if macro
    public static function generate(infile:String, outfile:String)
    {
        var script = new macro.UserScript(outfile);
        // XXX: GetReady is hardcoded here, need to find a way to fix it...
        script.from_infile(new GetReady(), infile);
        script.write(outfile);
    }
#end
}
