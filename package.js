Package.describe({
  summary: "Experimental Routing"
});

Package.on_use(function (api, where) {
  api.use(['coffeescript', 'standard-app-packages', 'core-lib']);
  api.add_files('alpha-router.coffee', 'client');
});

Package.on_test(function (api) {
  api.use('alpha-router');

  api.add_files('alpha-router_tests.js', ['client', 'server']);
});
