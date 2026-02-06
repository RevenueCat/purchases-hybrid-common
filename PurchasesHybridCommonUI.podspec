Pod::Spec.new do |s|
  s.name             = "PurchasesHybridCommonUI"
  s.version          = "17.33.1"
  s.summary          = "Common files for hybrid SDKs for RevenueCat UI"

  s.description      = <<-DESC
                       Save yourself the hastle of implementing a subscriptions backend. Use RevenueCat instead https://www.revenuecat.com/
                       DESC

  s.homepage         = "https://www.revenuecat.com/"
  s.license          =  { :type => 'MIT' }
  s.author           = { "RevenueCat, Inc." => "support@revenuecat.com" }
  s.source           = { :git => "https://github.com/revenuecat/purchases-hybrid-common.git", :tag => s.version.to_s }
  s.documentation_url = "https://docs.revenuecat.com/"

  s.framework      = 'StoreKit'
  s.framework      = 'SwiftUI'

  s.dependency 'RevenueCatUI', '5.57.2'
  s.dependency 'PurchasesHybridCommon', s.version.to_s
  s.swift_version = '5.7'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.visionos.deployment_target = '1.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.source_files = ['ios/PurchasesHybridCommon/PurchasesHybridCommonUI/**/*.{h,m,swift}']

  s.public_header_files = [
    'ios/PurchasesHybridCommon/PurchasesHybridCommonUI/*.h'
  ]

end
