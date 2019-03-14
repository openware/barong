# frozen_string_literal: true

# Base Application Controller
class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
end
