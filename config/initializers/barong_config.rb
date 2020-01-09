# FIXME BarongConfig should be a feature of Barong::App
class BarongConfig
  class << self

    def list
      @hash ||= read_from_yaml
    end

    private

    def read_from_yaml
      conf = YAML.load_file(Barong::App.config.config)
      conf['activation_requirements'] = {'email' => 'verified'} unless conf['activation_requirements']
      conf
    end
  end
end
