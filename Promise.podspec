Pod::Spec.new do |s|
		s.name 				= "Promise"
		s.version 			= "1.2.0"
		s.summary         	= "Sort description of 'Promise' framework"
	    s.homepage        	= "https://github.com/amine2233/Promise"
	    s.license           = { type: 'MIT', file: 'LICENSE' }
	    s.author            = { 'Amine Bensalah' => 'amine.bensalah@outlook.com' }
	    s.ios.deployment_target = '10.0'
	    s.osx.deployment_target = '10.12'
	    s.tvos.deployment_target = '10.0'
	    s.watchos.deployment_target = '4.0'
	    s.requires_arc = true
	    s.source            = { :git => "https://github.com/amine2233/Promise.git", :tag => s.version.to_s }
	    s.source_files      = "Sources/**/*.swift"
	    s.exclude_files 	= "Sources/*.plist"
	    s.pod_target_xcconfig = {
    		'SWIFT_VERSION' => '4.2'
  		}
  		s.swift_version = '4.2'

  		s.module_name = s.name
  		
  		s.dependency 'Reactive', '~> 1.1.0'
  		s.dependency 'ResultKit', '~> 2.1.0'
	end
