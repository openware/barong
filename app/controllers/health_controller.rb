# frozen_string_literal: true

class HealthController < ApplicationController
  def alive
    render_health_status HealthChecker.alive?
  end

  def ready
    render_health_status HealthChecker.ready?
  end

private

  def render_health_status(health)
    head health ? 200 : 503
  end
end
