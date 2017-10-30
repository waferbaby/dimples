# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Category do
  before do
    @site = Dimples::Site.new(test_configuration)
  end

  describe 'with a custom name in the configuration' do
    before { @category = Dimples::Category.new(@site, 'mac') }

    it 'uses the custom name' do
      @category.name.must_equal('Macintosh')
    end

    it 'returns the correct value when inspected' do
      @category.inspect.must_equal(
        '#<Dimples::Category @slug=mac @name=Macintosh>'
      )
    end
  end

  describe 'without a custom name in the configuration' do
    before { @category = Dimples::Category.new(@site, 'windows') }

    it 'capitalises the name' do
      @category.name.must_equal('Windows')
    end

    it 'returns the correct value when inspected' do
      @category.inspect.must_equal(
        '#<Dimples::Category @slug=windows @name=Windows>'
      )
    end
  end
end
