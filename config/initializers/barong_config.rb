# FIXME BarongConfig should be a feature of Barong::App
class BarongConfig
  class << self

    def list
      @hash ||= read_from_yaml
    end

    private

    def read_from_yaml
      conf = YAML.safe_load(
        ERB.new(
          File.read(Rails.root.join('config', Barong::App.config.barong_config))
        ).result
      )
      conf['activation_requirements'] = {'email' => 'verified'} unless conf['activation_requirements']
      conf
    end
  end
end
