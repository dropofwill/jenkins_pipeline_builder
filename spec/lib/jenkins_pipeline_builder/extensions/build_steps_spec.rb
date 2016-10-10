require File.expand_path('../../spec_helper', __FILE__)

describe 'build_steps' do
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
    builder = Nokogiri::XML::Builder.new { |xml| xml.buildSteps }
    @n_xml = builder.doc
  end

  after :each do |example|
    name = example.description.tr ' ', '_'
    require 'fileutils'
    FileUtils.mkdir_p 'out/xml'
    File.open("./out/xml/build_steps_#{name}.xml", 'w') { |f| @n_xml.write_xml_to f }
  end

  context 'generic' do
    it 'can register a build_step' do
      result = build_step do
        name :test_generic
        plugin_id :foo
        xml do
          foo :bar
        end
      end
      JenkinsPipelineBuilder.registry.registry[:job][:build_steps].delete :test_generic
      expect(result).to be true
    end

    it 'fails to register an invalid build_step' do
      result = build_step do
        name :test_generic
      end
      JenkinsPipelineBuilder.registry.registry[:job][:build_steps].delete :test_generic
      expect(result).to be false
    end
  end

  context 'triggered_jobs' do
    before :each do
      allow(JenkinsPipelineBuilder.client).to receive(:plugin).and_return double(
        list_installed: { 'promoted_builds' => '2.31' }
      )
    end

    it 'generates a configuration' do
      params = { build_steps: {
        triggered_job: { name: 'ReleaseBuild' } } }

      JenkinsPipelineBuilder.registry.traverse_registry_path('job', params, @n_xml)

      expect(@n_xml
        .at('//hudson.plugins.parameterizedtrigger.TriggerBuilder/configs/projects')
        .text).to eq('ReleaseBuild')
    end
  end
end

