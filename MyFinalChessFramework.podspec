
Pod::Spec.new do |spec|

spec.name = 'MyFinalChessFramework'
spec.version = '0.0.1'
spec.author = 'Lera O.'
spec.license = 'MIT'
spec.homepage = 'https://github.com/LeraOnishchenko/MyFinalChessFramework'
spec.source = { :git => 'https://github.com/LeraOnishchenko/MyFinalChessFramework.git', :tag => "v#{spec.version}"}
spec.summary = 'This is chess framework'

spec.swift_version = '5.7'
spec.platform = :ios, '13'

spec.source_files = 'Sources/MyFinalChessFramework/*'
 

end
