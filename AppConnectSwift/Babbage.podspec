Pod::Spec.new do |s|
s.name               = "Babbage"
s.version            = "2018.2.0.9"
s.summary            = "The Medidata Patient Cloud SDK"
s.description        = "AppConnect SDK, built from hash 40209408"
s.homepage           = "https://github.com/mdsol/babbage"
s.license            = { type: "Proprietary", text: "TBD" }
s.author             = "Medidata Solutions, Inc."

s.source             = { http: 'https://s3.amazonaws.com/medidata/appconnect-sdk/release/ios/2018.2.0/babbage-2018.2.0.9.zip' }
s.source_files       = "artifacts/include/babbage/*.h"
s.vendored_libraries = "artifacts/libBabbage.a"

s.library            = 'c++', 'z'
s.platform           = :ios
s.requires_arc       = true
s.ios.deployment_target = '8.0'

s.dependency         'HTMLReader', '~> 0.7'
s.dependency         'UICKeyChainStore', '~> 2.0'
s.dependency         'AWSS3', '~> 2.3.5'
end
