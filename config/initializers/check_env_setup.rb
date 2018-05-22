if Rails.env.production?
  specs_path = Rails.root.join('config', 'env_specs.yml')

  if File.exists?(specs_path)
    required_variables = YAML.safe_load(File.read(specs_path))

    unless required_variables.is_a?(Array)
      Kernel.abort("Yaml has invalid format. It must be an Array")
    end

    list = required_variables.reduce([]) do |array, var|
      array << var unless ENV[var]
      array
    end

    Kernel.abort("You are trying to run PRODUCTION environment without next required variables #{list.join(', ')}")
  end
end
