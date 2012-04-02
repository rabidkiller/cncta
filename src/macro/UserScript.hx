package macro;

import haxe.macro.Expr;

class UserScript
{
    private var template:String;

    public function new(template:String)
    {
        this.template = neko.io.File.getContent(template);
    }

    public function from_infile(tpl:IUserScriptTemplate, infile:String)
    {
        var code = new jsmin.JSMin(neko.io.File.getContent(infile)).output;

        this.template = StringTools.replace(
            this.template,
            "#CODE_HERE#",
            tpl.generate(code)
        );
    }

    public function write(outfile:String)
    {
        var out = neko.io.File.write(outfile, false);
        out.writeString(this.template);
        out.close();
    }

    public static function finalize_meta(name:String, value:String):String
    {
        return "// @" + name + " " + value + "\n";
    }

    public static function get_string_value(e:ExprDef):String
    {
        switch (e) {
            case EConst(c):
                switch (c) {
                    case CString(val):
                        return val;
                    default:
                }
            default:
        }

        return null;
    }

    public static function get_values(e:ExprDef):Array<String>
    {
        var out:Array<String> = new Array();

        switch (e) {
            case EConst(c):
                switch (c) {
                    case CString(val):
                        return [val];
                    default:
                }
            case EArrayDecl(a):
                for (val in a) {
                    out.push(UserScript.get_string_value(val.expr));
                }
            default:
        }

        return out;
    }

    public static function generate_meta(meta:Metadata)
    {
        var out = "// ==UserScript==\n";

        for (m in meta) {
            var name:String = m.name;

            for (p in m.params) {
                var values = UserScript.get_values(p.expr);
                for (value in values) {
                    out += UserScript.finalize_meta(name, value);
                }
            }
        }

        out += "// ==/UserScript==\n";

        return out;
    }
}
