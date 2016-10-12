condition do
  name :manual
  plugin_id 'promoted_builds'
  parameters [
    :users
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.ManualCondition') do
      users params[:users] || 'authorized'
    end
  end
end

condition do
  name :self_promotion
  plugin_id 'promoted_builds'
  parameters [
    :even_if_unstable
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.SelfPromotionCondition') do
      even_if_unstable params[:even_if_unstable] || false
    end
  end
end

condition do
  name :parameterized_self_promotion
  plugin_id 'promoted_builds'
  parameters [
    :parameter_name,
    :parameter_value,
    :even_if_unstable
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.ParameterizedSelfPromotionCondition') do
      parameter_name params[:parameter_name]
      parameter_value params[:parameter_value] || false
      even_if_unstable params[:even_if_unstable] || false
    end
  end
end

condition do
  name :downstream_pass
  plugin_id 'promoted_builds'
  parameters [
    :jobs,
    :even_if_unstable
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.DownstreamPassCondition') do
      jobs params[:jobs] || '{{Example}}-Commit'
      even_if_unstable params[:even_if_unstable] || false
    end
  end
end

condition do
  name :upstream_promotion
  plugin_id 'promoted_builds'
  parameters [
    :promotion_name
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.UpstreamPromotionCondition') do
      promotion_name params[:promotion_name] || '01. Staging Promotion'
    end
  end
end
