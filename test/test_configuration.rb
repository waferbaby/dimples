# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Configuration' do
  describe 'with passed-in values' do
    subject do
      custom_settings = {
        'paths' => {
          'archives' => 'arc'
        },

        'layouts' => {
          'category' => 'cat'
        }
      }

      Dimples::Configuration.new(custom_settings)
    end

    it 'overrides the defaults' do
      subject['paths']['archives'].must_equal('arc')
      subject['layouts']['category'].must_equal('cat')
    end
  end
end
