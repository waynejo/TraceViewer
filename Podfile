source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.11'
inhibit_all_warnings!
use_frameworks!

target 'TraceViewer' do
  pod 'SnapKit', '~> 4.0.0'

  # target "MyAppTests" do
  #   inherit! :search_paths
  #   pod 'OCMock', '~> 2.0.1'
  # end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts "#{target.name}"
  end
end