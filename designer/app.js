lbs.apploader.register('designer', function () {
    var self = this;
    //config
    self.config = {
        dataSources: [
            {type:'activeInspector', alias: "inspector"}
        ],
        resources: {
            scripts: ["editor.js", "parser.js", "appstore.js", "widget.js", "element.js"],
            styles: ["designer.css"],
            libs: ["underscore-min.js"]
        }
    };
    //initialize
    self.initialize = function (node,viewModel) {
        //alert(lbs.limeDataConnection.ActiveInspector.Class.Name);
        //alert(JSON.stringify(viewModel.inspector));
        //alert(lbs.loader.loadLocalFileToString(lbs.limeDataConnection.ActiveInspector.Class.Name+".html"));
        editor.setup();
        $("#template").text(lbs.loader.loadLocalFileToString(lbs.limeDataConnection.ActiveInspector.Class.Name+".html"));
        editor.load();

        return viewModel;
    }
});

