# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Logger do
  before { @output = StringIO.new }
  subject { Dimples::Logger.new(@output) }

  describe 'when showing an error' do
    before { subject.error('This is an error') }

    it 'shows the correctly formatted message' do
      @output.string.must_equal("\e[31mError:\e[0m This is an error\e[0m\n")
    end
  end

  describe 'when showing debugging' do
    before { subject.debug('This is a debug message') }

    it 'shows the correctly formatted message' do
      @output.string.must_equal("\e[93m- This is a debug message\e[0m\n")
    end
  end
end
