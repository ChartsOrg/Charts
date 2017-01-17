def type
  :project # set `:project` for xcodeproj and `:workspace` for xcworkspace
end

def project_name
  'Charts.xcodeproj'
end

def configuration
  'Debug'
end

def test_platforms
  [
    :iOS,
    :tvOS
  ]
end

def build_platforms
  [
    :macOS
  ]
end

def build_schemes
  %w(
    Charts
    ChartsRealm
  )
end

def test_schemes
  [
    'ChartsTests'
  ]
end

def devices
  {
    iOS: {
      sdk: 'iphonesimulator',
      device: "id='22FA2149-1241-469C-BF6D-462D3837DB72'",
      uuid: '22FA2149-1241-469C-BF6D-462D3837DB72'
    },
    macOS: {
      sdk: 'macosx',
      device: "arch='x86_64'",
      uuid: nil
    },
    tvOS: {
      sdk: 'appletvsimulator',
      device: "id='5761D8AB-2838-4681-A528-D0949FF240C5'",
      uuid: '5761D8AB-2838-4681-A528-D0949FF240C5'
    }
  }
end

def open_simulator_and_sleep(uuid)
  return if uuid.nil? # Don't need a sleep on macOS because it runs first.
  sh "xcrun instruments -w '#{uuid}' || sleep 15"
end

def xcodebuild(type, name, scheme, configuration, sdk, destination, tasks, xcprety_args)
  # set either workspace or project flag for xcodebuild
  case type
  when :project
    project_type = '-project'
  when :workspace
    project_type = '-workspace'
  else
    abort 'Invalid project type, use `:project` for xcodeproj and `:workspace` for xcworkspace.'
  end

  sh "set -o pipefail && xcodebuild #{project_type} '#{name}' -scheme '#{scheme}' -configuration '#{configuration}' -sdk #{sdk} -destination #{destination} #{tasks} | bundle exec xcpretty -c #{xcprety_args}"
end

def run_xcodebuild(schemes_to_execute, tasks, destination, is_test, xcprety_args)
  sdk = destination[:sdk]
  device = destination[:device]
  uuid = destination[:uuid]

  open_simulator_and_sleep uuid if is_test

  schemes_to_execute.each do |scheme|
    xcodebuild type, project_name, scheme, configuration, sdk, device, tasks, xcprety_args
  end

  sh 'killall Simulator' if is_test
end

def execute(tasks, platform, xcprety_args: '')
  is_test = tasks.include?('test')

  # platform specific settings
  destination = devices[platform]

  schemes = is_test ? test_schemes : build_schemes

  # check if xcodebuild needs to be run on multiple devices
  if destination.is_a?(Array)
    destination.each do |destination|
      run_xcodebuild schemes, tasks, destination, is_test, xcprety_args
    end
  else
    run_xcodebuild schemes, tasks, destination, is_test, xcprety_args
  end
end

def arg_to_key(string_key)
  case string_key.downcase
  when 'ios'
    :iOS
  when 'tvos'
    :tvOS
  when 'macos'
    :macOS
  when 'watchos'
    :watchOS
  else
    abort 'Invalid platform, use `iOS`, `tvOS`, `macOS` or `watchOS`'
  end
end

desc 'Run CI tasks. Build and test or build depending on the platform.'
task :ci, [:platform] do |_task, args|
  platform = arg_to_key(args[:platform]) if args.has_key?(:platform)

  if test_platforms.include?(platform)
    execute 'clean build test', platform
  elsif build_platforms.include?(platform)
    execute 'clean build', platform
  else
    test_platforms.each do |platform|
      execute 'clean build test', platform
    end
    build_platforms.each do |platform|
      execute 'clean build', platform
    end
  end
end

desc 'updated the podspec on cocoapods'
task :update_pod do 
  sh "bundle exec pod trunk push Charts.podspec --allow-warnings"
end