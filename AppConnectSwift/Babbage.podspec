RELEASE = "2017.1.0"
VERSION = "#{RELEASE}.57"

if File.exist?('local.yaml')
require 'yaml'
content = YAML.load_file('local.yaml')
artifactory_server = content['ARTIFACTORY_SERVER'] || raise("You must set an artifactory server using the variable ARTIFACTORY_SERVER in the local.yaml file.")
username = content['ARTIFACTORY_USERNAME'] || raise("You must set an artifactory username using the variable ARTIFACTORY_USERNAME in the local.yaml file.")
password = content['ARTIFACTORY_PASSWORD'] || raise("You must set an artifactory password using the variable ARTIFACTORY_PASSWORD in the local.yaml file.")
else
artifactory_server = ENV['ARTIFACTORY_SERVER'] || raise("You must set an artifactory server using the environment variable ARTIFACTORY_SERVER.")
username = ENV['ARTIFACTORY_USERNAME'] || raise("You must set an artifactory username using the environment variable ARTIFACTORY_USERNAME.")
password = ENV['ARTIFACTORY_PASSWORD'] || raise("You must set an artifactory password using the environment variable ARTIFACTORY_PASSWORD.")
end

Pod::Spec.new do |s|
s.name               = "Babbage"
s.version            = VERSION
s.summary            = "The Medidata Patient Cloud SDK"
s.homepage           = "https://github.com/mdsol/babbage"
s.license            = { type: "Proprietary", text: "TBD" }
s.author             = "Medidata Solutions, Inc."

s.source             = { http: "https://#{username}:#{password}@#{artifactory_server}/artifactory/p-cloud-release/com/mdsol/babbage/ios/#{RELEASE}/babbage-#{VERSION}.zip" }

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
