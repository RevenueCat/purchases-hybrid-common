require 'xcodeproj'

project = Xcodeproj::Project.new(File.join(__dir__, 'CocoaPodsInstallation.xcodeproj'))
app = project.new_target(:application, 'CocoaPodsInstallation', :ios, '15.0')
tests = project.new_target(:unit_test_bundle, 'CocoaPodsInstallationTests', :ios, '15.0')
tests.add_dependency(app)

app.add_file_references([project.main_group.new_file('App.swift')])
tests.add_file_references([project.main_group.new_file('InstallationTests.swift')])

[app, tests].each do |target|
  target.build_configurations.each do |configuration|
    configuration.build_settings['SWIFT_VERSION'] = '5.0'
    configuration.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    configuration.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.revenuecat.#{target.name}"
    configuration.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  end
end

app.build_configurations.each do |configuration|
  configuration.build_settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
end

tests.build_configurations.each do |configuration|
  configuration.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/CocoaPodsInstallation.app/CocoaPodsInstallation'
  configuration.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
end

project.save
scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(app, tests)
scheme.save_as(project.path, 'CocoaPodsInstallation', true)
