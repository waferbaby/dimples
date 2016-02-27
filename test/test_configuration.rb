$:.unshift(__dir__)

require 'helper'

describe "Configuration" do
  it "uses the passed-in custom settings" do
    custom_settings = {
      'paths' => {
        'archives' => 'arc'
      },

      'layouts' => {
        'category' => 'cat'
      }
    }

    @config = Dimples::Configuration.new(custom_settings)

    @config["paths"]["archives"].must_equal("arc")
    @config["layouts"]["category"].must_equal("cat")
  end
end