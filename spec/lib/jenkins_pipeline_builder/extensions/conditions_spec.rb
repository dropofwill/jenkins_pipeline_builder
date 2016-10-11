require File.expand_path('../../spec_helper', __FILE__)
require 'pry'

describe 'conditions' do
  after :each do
    JenkinsPipelineBuilder.registry.clear_versions
  end

  before :all do
    JenkinsPipelineBuilder.credentials = {
      server_ip: '127.0.0.1',
      server_port: 8080,
      username: 'username',
      password: 'password',
      log_location: '/dev/null'
    }
  end

  before :each do
    builder = Nokogiri::XML::Builder.new { |xml| xml.conditions}
    @n_xml = builder.doc
  end

  after :each do |example|
    name = example.description.tr ' ', '_'
    require 'fileutils'
    FileUtils.mkdir_p 'out/xml'
    File.open("./out/xml/conditions_#{name}.xml", 'w') { |f| @n_xml.write_xml_to f }
  end

  context 'generic' do
    it 'can register a condition' do
      result = condition do
        name :test_generic
        plugin_id :foo
        xml do
          foo :bar
        end
      end
      JenkinsPipelineBuilder.registry.registry[:job][:conditions].delete :test_generic
      expect(result).to be true
    end

    it 'fails to register an invalid condition' do
      result = condition do
        name :test_generic
      end
      JenkinsPipelineBuilder.registry.registry[:job][:conditions].delete :test_generic
      expect(result).to be false
    end
  end

  context 'type: manual' do
    before :each do 
      allow(JenkinsPipelineBuilder.client).to receive(:plugin).and_return double(
        list_installed: { 'promoted_builds' => '2.31' }
      )
    end

    it 'generates manual configuration' do 
      params = { conditions: [ { manual: { users: 'authorized' } } ] }
      
      JenkinsPipelineBuilder.registry.traverse_registry_path('job', params, @n_xml)
      
      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.ManualCondition/users').text).to eq('authorized')
    end

    it 'generates a self promotion configuration' do 
      params = { conditions: [ { self_promotion: { even_if_unstable: true } } ] }
      
      JenkinsPipelineBuilder.registry.traverse_registry_path('job', params, @n_xml)
      
      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.SelfPromotionCondition/even_if_unstable').text).to eq('true')
    end

    it 'generates a parameterized self promotion configuration' do 
      params = { conditions: [ { parameterized_self_promotion: { parameter_name: 'SOME_ENV_CHAR', parameter_value: true, even_if_unstable: true } } ] }
      
      JenkinsPipelineBuilder.registry.traverse_registry_path('job', params, @n_xml)

      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.ParameterizedSelfPromotionCondition/parameter_name').text).to eq('SOME_ENV_CHAR')
      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.ParameterizedSelfPromotionCondition/parameter_value').text).to eq('true')
      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.ParameterizedSelfPromotionCondition/even_if_unstable').text).to eq('true')
    end

    it 'generates a downstream pass configuration' do 
      params = { conditions: [ downstream_pass: { jobs: "Worst-Commit-Ever", even_if_unstable: true } ] }
      
      JenkinsPipelineBuilder.registry.traverse_registry_path('job', params, @n_xml)
      
      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.DownstreamPassCondition/jobs').text).to eq('Worst-Commit-Ever')
      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.DownstreamPassCondition/even_if_unstable').text).to eq('true')
    end

    it 'generates a upstream promotion configuration' do 
      params = { conditions: [ upstream_promotion: { promotion_name: 'Never-Promotes' } ] }
      
      JenkinsPipelineBuilder.registry.traverse_registry_path('job', params, @n_xml)
      
      expect(@n_xml.at('//hudson.plugins.promoted__builds.conditions.UpstreamPromotionCondition/promotion_name').text).to eq('Never-Promotes')
    end
  end
end
