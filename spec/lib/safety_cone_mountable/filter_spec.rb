require 'spec_helper'

class ControllerClass < ActionController::Base
  include SafetyConeMountable::Filter
end

class RedisMock 
  def get(key); end
end

# Specs for SafetyConeMountable::Configuration
module SafetyConeMountable
  describe Filter do
    let(:redis) { RedisMock.new }
    let(:controller_instance) { ControllerClass.new }

    before do
      SafetyConeMountable.configure do |config|
        config.redis = redis

        config.add(
          controller: :static_pages,
          action: :home,
          name: 'Home Page'
        )
      end
    end

    # This requires a lot more improvements
    context 'Request to home page' do
      it 'fetches all the cones' do
        controller_instance.stub(:controller_name) { 'static_pages' }
        controller_instance.stub(:action_name) { 'home' }


        allow(redis).to receive(:get) { { message: 'foo', measure: 'quxx' }.to_json }

        allow(SafetyConeMountable).to receive(:cones) { { static_pages_home: { 
                                                     controller: :static_pages, 
                                                     action: :home, name: 'Home Page' } 
                                                   } }

        expect(SafetyConeMountable).to receive(:cones)

        controller_instance.fetch_cone
      end
    end

  end
end
