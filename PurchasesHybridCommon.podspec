Pod::Spec.new do |s|
  s.name             = "PurchasesHybridCommon"
  s.version          = "17.33.1"
  s.summary          = "Common files for hybrid SDKs for RevenueCat's Subscription and in-app-purchase backend service."

  s.description      = <<-DESC
                       Save yourself the hastle of implementing a subscriptions backend. Use RevenueCat instead https://www.revenuecat.com/
                       DESC

  s.homepage         = "https://www.revenuecat.com/"
  s.license          =  { :type => 'MIT' }
  s.author           = { "RevenueCat, Inc." => "support@revenuecat.com" }
  s.source           = { :git => "https://github.com/revenuecat/purchases-hybrid-common.git", :tag => s.version.to_s }
  s.documentation_url = "https://docs.revenuecat.com/"

  s.framework      = 'StoreKit'

  s.dependency 'RevenueCat', '5.57.2'
  s.swift_version = '5.7'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.visionos.deployment_target = '1.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.source_files = ['ios/PurchasesHybridCommon/PurchasesHybridCommon/**/*.{h,m,swift}']

  s.public_header_files = [
    'ios/PurchasesHybridCommon/PurchasesHybridCommon/*.h'
  ]

  s.resource_bundles = {'PurchasesHybridCommon' => ['ios/PurchasesHybridCommon/PurchasesHybridCommon/PrivacyInfo.xcprivacy']}

end
