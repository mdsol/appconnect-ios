if File.exist?('local.yaml')
    require 'yaml'
    content = YAML.load(File.open('local.yaml'))
    username = content['ARTIFACTORY_USERNAME'] || raise("You must set an artifactory username using the variable ARTIFACTORY_USERNAME.")
    password = content['ARTIFACTORY_PASSWORD'] || raise("You must set an artifactory password using the variable ARTIFACTORY_PASSWORD.")
else
    username = ENV['ARTIFACTORY_USERNAME'] || raise("You must set an artifactory username using the environment variable ARTIFACTORY_USERNAME.")
    password = ENV['ARTIFACTORY_PASSWORD'] || raise("You must set an artifactory password using the environment variable ARTIFACTORY_PASSWORD.")
end

Pod::Spec.new do |s|
    s.name               = "Babbage"
    s.version            = "2016.1.0.18"
    s.summary            = "The Medidata Patient Cloud SDK"
    s.homepage           = "https://github.com/mdsol/babbage"
    s.license            = { type: "Proprietary", text: "TBD" }
    s.author             = "Medidata Solutions, Inc."

    s.source             = { http: "https://#{username}:#{password}@etlhydra-artifactory-sandbox.imedidata.net/artifactory/p-cloud-release/com/mdsol/babbage/ios/2016.1.0/babbage-2016.1.0.18.zip" }
    s.source_files       = "artifacts/include/babbage/*.h"
    s.vendored_libraries = "artifacts/libBabbage.a"

    s.library            = "c++"
    s.platform           = :ios
    s.requires_arc       = true
    s.ios.deployment_target = '7.0'

    s.dependency         'AFNetworking', '2.5.3'
    s.dependency         'HTMLReader', '~> 0.7.1'
    s.dependency         'UICKeyChainStore', '2.0.6' # 2.0.7 does not build with XCode 6.4
    s.dependency         'OpenSSL-Universal', '~> 1.0.1j'
end