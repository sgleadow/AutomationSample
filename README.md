# iOS Automation Sample

This is some sample code to go with a Cocoaheads talk I gave on a couple of automation tips for iOS projects. The [cocoaheads video of the talk is here](https://www.youtube.com/watch?v=ZTqsi1aNgnQ&index=3&list=UUpTDVzUkk9ieAyVyUi28bWw).

It's not an exhaustive list, it's just the tools and techniques I was currently using on my project at the time when I put the talk together.

## Local features toggles

We use feature toggles heavily, so that we can constantly merge to master, even when work is in progress. Remote features toggles are really powerful, but they're also more effort to maintain.

Here we use a very simple feature toggle mechanism that relies on build configurations for your target.

```swift
// Define the config as a Swift type
enum BuildConfig {
    case debug
    case release

    // Only use the build variables in one place as they're hard to test
    static var active: BuildConfig {
        #if DEBUG
            return .debug
        #else
            return .release
        #endif
    }
}

// Protocol for the toggles, so we can have fake ones in our tests
protocol ToggleType {
    var enabled: Bool { get }
}

// The actual implementation is just an array contains
struct Toggle: ToggleType {
    let enabled: Bool

    init(_ enabledConfigs: [BuildConfig], buildConfig: BuildConfig = BuildConfig.active) {
        enabled = enabledConfigs.contains(buildConfig)
    }
}

// Define the toggles and which configs they're enabled for
struct Toggles {
    static let shouldShowTheThang: ToggleType = Toggle([.debug])
}
```

## Verify no unwanted Xcode build settings

The Xcode project file is a pain to manage and merge in large teams, so we prefer to keep as little in there as possible, including managing all Xcode build settings in separate `xcconfig` files rather than in the editor in the IDE.

Once you're in this state, you want to ensure that build settings are in the right place.

The `Rakefile` has some ruby code that uses the [xcodeproj gem](https://github.com/cocoapods/xcodeproj) to check that the Xcode project file doesn't have any build settings defined in the actual project file, to ensure they're all in `xcconfig` files.

```ruby
desc "Check there are no build settings in the project file"
task :check_settings do
  projects = Dir.glob('*.xcodeproj').map do |project_file|
    Xcodeproj::Project.open(project_file)
  end

  projects.each do |project|
    project.build_configurations.each do |configuration|
      unless configuration.build_settings.empty?
        print_error "Project - #{configuration.name}", configuration
        raise "Build settings found in Xcode project file"
      end
    end

    project.targets.each do |target|
      target.build_configurations.each do |configuration|
        unless configuration.build_settings.empty?
          print_error "#{target.name} - #{configuration.name}", configuration
          raise "Build settings found in Xcode project file"
        end
      end
    end
  end

end

def print_error configuration_label, configuration
  STDERR.puts "Error: found build settings in Xcode when they should be in an xcconfig file"
  STDERR.puts "Configuration: #{configuration_label}"
  STDERR.puts "Settings:\n#{pretty_print_settings(configuration)}"
end

def pretty_print_settings configuration
  configuration.build_settings.map { |k,v| "\t#{k} = #{v}"}.join('\n')
end
```

## Basic API contracts with swagger/dredd

There are great tools out there for API contract testing, like [pact](https://docs.pact.io/). Here I show a really simple way of verifying that your API matches the expected schema using [swagger](https://swagger.io/) to define the documentation and contract itself and a tool called [dredd](https://github.com/apiaryio/dredd) to run requests against a sample API and verify the contract.

We have a [very simple sample endpoint](http://www.mocky.io/v2/59ba34c60f00002d01622725) on mocky.io, which returns a message object:

```bash
$ http http://www.mocky.io/v2/59ba34c60f00002d01622725
HTTP/1.1 200 OK
...
{
    "message": {
        "description": "how's it going",
        "title": "hi"
    }
}
```

The contract for this endpoint is defined in swagger, and we state that the message object must have the following schema:

```yaml
definitions:
  message:
    type: object
    required:
      - title
      - description
    properties:
      title:
        type: string
      description:
        type: string
```

We can then run dredd against the endpoint to verify it's correct. I have defined this inside the `package.json` to run using `npm run contract`, which under the hood is using dredd directly.

Dredd has quite noisy output, but the key output is shown below.

```bash
# should pass
$ dredd contract.yml http://www.mocky.io/v2/59ba34c60f00002d01622725
pass: GET (200) / duration: 1939ms

# should fail because a key has the wrong type
$ dredd contract.yml http://www.mocky.io/v2/59ba382b0f00005b01622730
fail: body: At '/message/description' Invalid type: number (expected string)

# should fail because of a missing required key
$ dredd contract.yml http://www.mocky.io/v2/59ba38970f00002401622732
fail: body: At '/message/description' Missing required property: description
```
