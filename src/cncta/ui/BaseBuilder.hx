package cncta.ui;

class BaseBuilder extends cncta.inject.ui.CustomWindow
{
    private var url_widget:cncta.inject.qx.Label;

    public override function new()
    {
        super("Base Builder");
        this.set({
            allowMaximize: false,
            allowMinimize: false,
            showMaximize: false,
            showMinimize: false,
            showStatusbar: false,
            movable: true,
            alwaysOnTop: true,
            showClose: true,
        });

        untyped __js__("this.setLayout(new qx.ui.layout.VBox())");

        this.url_widget = new cncta.inject.qx.Label();
        this.url_widget.setDecorator("pane-comment");
        this.url_widget.set({
            selectable: true,
            rich: true,
        });

        this.add(url_widget, {
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
        });

        this.addListener("appear", this.on_appear);
    }

    private function set_bbid(id:String)
    {
        var url = "http://cncbasebuilder.appspot.com/";
        url += "#" + id;

        var link = "<a href=\"#\" onClick=\"webfrontend.";
        link += "gui.Util.openLinkFromInnerHtml(this);\">";
        link += url;
        link += "</a>";

        this.url_widget.setValue(link);
    }

    private function structure2bb(building:Int)
    {
        var convertmap:IntHash<String> = new IntHash();
        convertmap.set(1,   "B");
        convertmap.set(2,   "8");
        convertmap.set(5,   "9");
        convertmap.set(10,  "7");
        convertmap.set(16,  "A");
        convertmap.set(24,  "B");
        convertmap.set(32,  "4");
        convertmap.set(34,  "D");
        convertmap.set(35,  "C");
        convertmap.set(36,  "E");
        convertmap.set(40,  "F");
        convertmap.set(42,  "G");
        convertmap.set(80,  "I");
        convertmap.set(81,  "J");
        convertmap.set(400, "4");
        convertmap.set(401, "5");

        var converted = convertmap.get(building);

        if (converted == null) {
            return "0";
        }

        return converted;
    }

    private function calculate_bbid():String
    {
        var bbmap = new Array<Int>();

        // prepopulate bbmap
        while (bbmap.length < 72)
            bbmap.push(0);

        var main = cncta.inject.MainData.GetInstance();
        var city = main.get_Cities().get_CurrentCity();
        var buildings = city.get_CityBuildingsData();

        for (building in buildings.m_Buildings.l) {
            var type = building.get_Type();
            var x = building.get_CoordX();
            var y = building.get_CoordY();

            // special case: harvester
            if (type == 32) {
                switch (building.get_ProductionModifierTypeDBId()) {
                    case 1: type = 400; // harvester tiberium
                    case 4: type = 401; // harvester crystal
                    default:
                }
            }

            bbmap[y * 9 + x] = type;
            trace("building: " + type + " -> (" + x + ", " + y + ")");
        }

        var bbid = "";
        for (building in bbmap) {
            bbid += this.structure2bb(building);
        }

        return bbid;
    }

    private function on_appear()
    {
        this.set_bbid(this.calculate_bbid());
        this.bringToFront();
    }
}