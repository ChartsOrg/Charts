def type
  :project # set `:project` for xcodeproj and `:workspace` for xcworkspace
end

def project_name
  "Charts.xcodeproj"
end

def configuration
  "Debug"
end

def test_platforms
  [
    :ios,
    :tvos
  ]
end

def schemes
  [
    "ChartsTests"
  ]
end

def devices
  {
    ios: { 
      sdk: "iphonesimulator", 
      device: "name='iPhone 7'", 
      uuid: "5F911B30-5F23-403B-9697-1DFDC24773C8" 
    },
    macos: { 
      sdk: "macosx", 
      device: "arch='x86_64'", 
      uuid: nil 
    },
    tvos: { 
      sdk: "appletvsimulator", 
      device: "name='Apple TV 1080p'", 
      uuid: "273D776F-196E-4F2A-AEF2-E1E3EAE99B47" 
    }
  }
end

def open_simulator_and_sleep(uuid)
  return if uuid.nil? # Don't need a sleep on macOS because it runs first.
  sh "xcrun instruments -w '#{uuid}' || sleep 15"
end

def xcodebuild(type, name, scheme, configuration, sdk, destination, tasks, xcprety_args: '')

  # set either workspace or project flag for xcodebuild
  case type
  when :project
    project_type = "-project"
  when :workspace
    project_type = "-workspace"
  else
    abort "Invalid project type, use `:project` for xcodeproj and `:workspace` for xcworkspace."
  end

  sh "set -o pipefail && xcodebuild #{project_type} '#{name}' -scheme '#{scheme}' -configuration '#{configuration}' -sdk #{sdk} -destination #{destination} #{tasks} | bundle exec xcpretty -c #{xcprety_args}"

end

def run_xcodebuild(schemes, tasks, destination, is_test, xcprety_args)
  sdk = destination[:sdk]
  device = destination[:device]
  uuid = destination[:uuid]

  if is_test
    open_simulator_and_sleep uuid
  end

  schemes.each do |scheme| 
    xcodebuild type, project_name, scheme, configuration, sdk, device, tasks, xcprety_args
  end

  if is_test
    sh "killall Simulator"
  end
end

def execute(tasks, platform, xcprety_args)

  is_test = tasks.include?("test")

  # platform specific settings
  destination = devices[platform]

  # check if xcodebuild needs to be run on multiple devices
  if destination.is_a?(Array)
    destination.each do |destination|
        run_xcodebuild schemes, tasks, destination, is_test, xcprety_args
    end
  else 
    run_xcodebuild schemes, tasks, destination, is_test, xcprety_args
  end
end

desc "Build, then run tests."
task :test do

  test_platforms.each do |platform|
    execute "build test", platform, xcprety_args: "--test"
  end

end
