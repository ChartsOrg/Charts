def type
  :project # set `:project` for xcodeproj and `:workspace` for xcworkspace
end

def project_name
  "Charts.xcodeproj"
end

def configuration
  "Debug"
end

def test_targets
  [
    :ios,
    :tvos
  ]
end

def schemes
  {
    ios: 'Charts',
    tvos: 'Charts',
    osx: 'Charts'
  }
end

def sdks
  {
    ios: 'iphonesimulator',
    osx: 'macosx',
    tvos: 'appletvsimulator'
  }
end

def devices
  {
    ios: "name='iPhone 7'",
    osx: "arch='x86_64'",
    tvos: "name='Apple TV 1080p'"
  }
end

# UUIDs of the Xcode 8 simulators from Travis CI
def uuids
  {
    ios: '5F911B30-5F23-403B-9697-1DFDC24773C8', # iPhone 7
    tvos: '273D776F-196E-4F2A-AEF2-E1E3EAE99B47' # Apple TV 1080p
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

  sh "set -o pipefail && xcodebuild #{project_type} '#{name}' -scheme '#{scheme}' -configuration '#{configuration}' -sdk #{sdk} -destination #{destination} #{tasks} | xcpretty -c #{xcprety_args}"

end

def execute(tasks, platform, xcprety_args)

  # platform specific settings
  sdk = sdks[platform]
  scheme = schemes[platform]
  destination = devices[platform]

  open_simulator_and_sleep(uuids[platform])

  # check if xcodebuild needs to be run on multiple devices
  if destination.respond_to?('map')
    destination.map do |destination|
      xcodebuild type, project_name, scheme, configuration, sdk, destination, tasks, xcprety_args
    end
  else
    xcodebuild type, project_name, scheme, configuration, sdk, destination, tasks, xcprety_args
  end

end

desc 'Build, then run tests.'
task :test do

  test_targets.map do |platform|
    execute 'build test', platform, xcprety_args: '--test'
  end

  sh "killall Simulator"

end
