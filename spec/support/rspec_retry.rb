require 'rspec/retry'

# See https://github.com/NoRedInk/rspec-retry

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # run retry only on features
  config.around :each  do |ex|
    ex.run_with_retry retry: 3
  end

  # callback to be run between retries
  #config.retry_callback = proc do |ex|
    # run some additional clean up task - can be filtered by example metadata
  #  if ex.metadata[:js]
  #  end
  #end
end
