Package.describe({
  summary: "Experimental Routing",
  version: "0.0.1",
  name: "bads:alpha-router"
});

Package.on_use(function (api, where) {
  api.versionsFrom("METEOR-CORE@0.9.0-atm");
  api.use([
    'bads:alpha-template',
    'bads:core-lib',
    'reactive-dict',
    'coffeescript',
    'standard-app-packages'
  ]);
  api.add_files('alpha-router.coffee', 'client');
});

Package.on_test(function (api) {
  api.use("bads:alpha-router");

  api.add_files('alpha-router_tests.js', ['client', 'server']);
});
