# TODO: Technically triggered_job takes multiple jobs in the xml
# Since Nokogiri builders don't allow modifying existing nodes this is not
# straightforward to abstract away the underlying XML from the user.
#
# * So either we need to only accept 1 triggered job per promotion process OR
# * Make it take array of triggered jobs
#
# This is very similar to the implementation for :blocking_downstream, but
# unfortunately sharing code between extensions doesn't seem to be possible

build_step do
  name :triggered_job
  plugin_id 'parameterized-trigger'
  parameters [
    :name,
    # block_condition: {  }
    # or
    # block_condition: _ # for the defaults
    :block_condition,
    # build_state: [
    # [ :current, _ ],
    # [ :predefined, {val: x, val2: y} ],
    # [ :file, 'filpath' ] ]
    :build_state,
  ]

  xml do |state|
    send('hudson.plugins.parameterizedtrigger.TriggerBuilder',
      'plugin' => 'parameterized-trigger@2.31') do

      configs do
        send('hudson.plugins.parameterizedtrigger.BlockableBuildTriggerConfig') do

          if state[:build_state].present? && state[:build_state].respond_to?(:each)
            configs do
              state[:build_state].each do |param_key, param_val|
                case param_key
                when /current/i, :current
                  send('hudson.plugins.parameterizedtrigger.CurrentBuildParameters')

                when /predefined/i, :predefined
                  send('hudson.plugins.parameterizedtrigger.PredefinedBuildParameters') do
                    properties param_val.map { |k, v| "#{k.upcase}=#{v}" }.join(" ")
                  end

                when /file/i, :file
                  send('hudson.plugins.parameterizedtrigger.FileBuildParameters') do
                    propertiesFile param_val
                    failTriggerOnMissing false
                    useMatrixChild false
                    onlyExactRuns false
                  end
                end
              end
            end
          else
            configs(class: 'empty-list') {}
          end

          projects state[:name]
          condition 'ALWAYS'
          triggerWithNoParameters false

          block do
            buildStepFailureThreshold do
              state.generate_for_threshold(self,
                state.resolve_block_condition(:build_step_failure_threshold) || :failure)
            end
            unstableThreshold do
              state.generate_for_threshold(self,
                state.resolve_block_condition(:unstable_threshold) || :unstable)
            end
            failureThreshold do
              state.generate_for_threshold(self,
                state.resolve_block_condition(:failure_threshold) || :failure)
            end
          end if state.has_block_condition?

          buildAllNodesWithLabel false
        end
      end
    end
  end
end

build_step do
  name :keep_builds_forever
  plugin_id 'promoted-builds'

  xml do |params|
    send('hudson.plugins.promoted__builds.KeepBuildForeverAction')
  end
end
