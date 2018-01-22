module SubMixer
  class Subtitle

    attr_accessor :text

    attr_accessor :start_time
    attr_accessor :end_time

    attr_accessor :metadata

    attr_accessor :priority
    attr_accessor :priority_flag

    def initialize(options={})
      options.each do |k, v|
        self.send("#{k}=", v)
      end
    end
  end
end
