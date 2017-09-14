require 'bundler'
Bundler.require

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
