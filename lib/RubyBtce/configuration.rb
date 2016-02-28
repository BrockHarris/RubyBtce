module RubyBtce
  class Configuration
    attr_accessor :key, :secret, :pairs, :default_precision
    attr_reader :specific_precision

    def initialize
      set_defaults
    end

    def valid?
      !(@key.nil? && @secret.nil? && @pairs.empty?)
    end

    def specific_precision=(value)
      @specific_precision = @specific_precision.merge(value)
    end

    def pair_precision(pair)
      return @default_precision unless @specific_precision.keys.include? pair.to_sym

      @specific_precision[pair.to_sym]
    end

    def load_from_file
      @yaml_paths.each do |path|
        next unless File.exist?(path)
        @config ||= YAML.load_file(path)
      end

      @key = @config['key']
      @secret = @config['secret']
    end

    private

    def set_defaults
      @default_precision = 4

      @pairs = [
        :btc_usd, :btc_eur, :btc_rur, :eur_usd, :eur_rur, :nvc_btc, :nvc_usd, :ppc_btc,
        :usd_rur, :ppc_usd, :ltc_rur, :nmc_btc, :ltc_btc, :ltc_eur, :ltc_usd, :nmc_usd
      ]

      @specific_precision = {
        btc_usd: 3,
        btc_eur: 3,
        ltc_btc: 5,
        ltc_eur: 6,
        ltc_usd: 6,
        nmc_usd: 6
      }

      @yaml_paths = [
        File.join(File.dirname(__FILE__), '..', 'config', 'btce_api.yml'),
        File.join(Rails.root, 'config', 'btce_api.yml')
      ]
    end
  end

  class ConfigurationException < Exception
    def message
      'Failed to load configuration'
    end
  end
end
