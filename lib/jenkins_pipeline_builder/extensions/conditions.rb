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
      if params[:even_if_unstable].nil?
        even_if_unstable true
      end
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
      if params[:parameter_value].nil?
        parameter_value true
      end
      if params[:even_if_unstable].nil?
        even_if_unstable true
      end
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
      if params[:even_if_unstable].nil?
        even_if_unstable true
      end
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
      if params[:promotion_name].nil?
        promotion_name '01. Staging Promotion'
      end
      promotion_name params[:promotion_name]
    end
  end
end
