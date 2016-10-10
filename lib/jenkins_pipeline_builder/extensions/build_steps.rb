build_step do
  name :triggered_job
  plugin_id 'promoted_builds'
  parameters [
    :name,
    :block_condition,
  ]

  xml do |params|
    send('hudson.plugins.parameterizedtrigger.TriggerBuilder',
      'plugin' => 'parameterized-trigger@2.31') do
      configs do
        projects params[:name]
      end
    end
  end
end

build_step do
  name :keep_builds_forever
  plugin_id 'promoted_builds'
  parameters [
    :value,
  ]

  xml do |params|
    if params[:value]
      send('hudson.plugins.promoted__builds.KeepBuildForeverAction')
    end
  end
end
