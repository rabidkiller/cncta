class GetReady implements IUserScriptTemplate
{
    private var code:String;

    public function new(code:String)
    {
        this.code = code;
    }

    private function attach_loader()
    {
        var watcher = this.get_watcher_on("typeof(webfrontend) == 'object'");
        var attach = "";

        attach += "finish_handler__ = " + watcher + ";";
        attach += "if (typeof(loader) != 'undefined')";
        attach +=     "loader.addFinishHandler(finish_handler__);";
        attach += "else if(typeof(window.loader) != 'undefined')";
        attach +=     "window.loader.addFinishHandler(finish_handler__)";

        return this.escape_code(attach);
    }

    private inline function escape_code(code:String)
    {
        // TODO: do this in one pass someday...
        var out = StringTools.replace(code, "\\", "\\\\");
        out     = StringTools.replace(out,  "\n", "\\n");
        out     = StringTools.replace(out,  "\"", "\\\"");
        return "\"" + out + "\"";
    }

    private function get_watcher_on(teststr:String)
    {
        var out = "";

        out += "function() {";
        out += "var wtimer__ = null;";
        out += "function watch_timer__(){";
        out +=     "if(" + teststr + "){";
        out +=         this.make_loader(this.escape_code(this.code));
        out +=         "window.clearInterval(wtimer__);";
        out +=     "}";
        out += "}";
        out += "wtimer__ = window.setInterval(watch_timer__, 1000);";
        out += "}";

        return out;
    }

    private function make_loader(code:String)
    {
        var out = "";

        out += "(function(){";
        out +=     "var inject__ = document.createElement('script');";
        out +=     "inject__.setAttribute('type', 'text/javascript');";
        out +=     "inject__.textContent = " + code + ";";
        out +=     "document.body.appendChild(inject__);";
        out +=     "document.body.removeChild(inject__);";
        out += "})();";

        return out;
    }

    public function generate():String
    {
        return this.make_loader(this.attach_loader());
    }
}
