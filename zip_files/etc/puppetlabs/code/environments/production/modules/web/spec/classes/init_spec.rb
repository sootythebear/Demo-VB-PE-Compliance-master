require 'spec_helper'
describe 'simple2' do
  context 'with default values for all parameters' do
    it { should contain_class('simple2') }
  end
end
