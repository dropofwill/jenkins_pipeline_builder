condition do
  name :manual
  plugin_id 'promoted-builds'
  parameters [
    :users
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.ManualCondition') do
      users params[:users]
    end
  end
end

condition do
  name :self_promotion
  plugin_id 'promoted-builds'
  parameters [
    :even_if_unstable
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.SelfPromotionCondition') do
      even_if_unstable true if params[:even_if_unstable].nil?
      even_if_unstable params[:even_if_unstable]
    end
  end
end

condition do
  name :parameterized_self_promotion
  plugin_id 'promoted-builds'
  parameters [
    :parameter_name,
    :parameter_value,
    :even_if_unstable
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.ParameterizedSelfPromotionCondition') do
      parameter_name params[:parameter_name]
      parameter_value true if params[:parameter_value].nil?
      even_if_unstable true if params[:even_if_unstable].nil?
      parameter_value params[:parameter_value]
      even_if_unstable params[:even_if_unstable]
    end
  end
end

condition do
  name :downstream_pass
  plugin_id 'promoted-builds'
  parameters [
    :jobs,
    :even_if_unstable
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.DownstreamPassCondition') do
      jobs params[:jobs] || '{{Example}}-Commit'
      even_if_unstable true if params[:even_if_unstable].nil?
      even_if_unstable params[:even_if_unstable]
    end
  end
end

condition do
  name :upstream_promotion
  plugin_id 'promoted-builds'
  parameters [
    :promotion_name
  ]

  xml do |params|
    send('hudson.plugins.promoted__builds.conditions.UpstreamPromotionCondition') do
      promotion_name '01. Staging Promotion' if params[:promotion_name].nil?
      promotion_name params[:promotion_name]
    end
  end
end
