# frozen_string_literal: true

seeds = YAML.safe_load(
  ERB.new(
    File.read(
      ENV.fetch('SEEDS_FILE', Rails.root.join('config', 'seeds.yml'))
    )
  ).result
)

logger = Logger.new(STDERR, progname: 'db:seed')
result = { accounts: [], applications: [] }

logger.info 'Seeding accounts'
seeds['accounts'].each do |seed|
  logger.info '---'

  # Skip existing accounts
  if Account.kept.find_by(email: seed['account']['email']).present?
    logger.info "Account '#{seed['account']['email']}' already exists"
    result[:accounts].push(email: seed['account']['email'])
    next
  end

  admin = Account.new(seed['account'])
  admin.password ||= SecureRandom.hex(20)

  if admin.save
    logger.info "Created account for '#{admin.email}'"

    # Confirm the email
    admin.update(confirmed_at: Time.now, level: 1) && logger.info("Confirmed email for '#{admin.email}'")

    # Create a Profile using defaults where values are not set in seeds.yml
    if seed['phone']
      phone = Phone.new(seed['phone'])
      phone.account = admin

      if phone.save && phone.update(validated_at: Time.now)
        logger.info "Created phone for '#{admin.email}'"
      else
        logger.error "Can't create phone for '#{admin.email}': #{phone.errors.full_messages.join('; ')}"
      end
    end

    # Create a Profile using defaults where values are not set in seeds.yml
    if seed['profile']
      profile = Profile.new(seed['profile'])
      profile.account = admin

      if profile.save
        logger.info "Created profile for '#{admin.email}'"
      else
        logger.error "Can't create profile for '#{admin.email}': #{profile.errors.full_messages.join('; ')}"
      end
    end

    result[:accounts].push(email: admin.email, password: admin.password)
  else
    logger.error "Can't create admin '#{admin.email}': #{admin.errors.full_messages.join('; ')}"
  end
end

# Create applications
logger.info '---'
logger.info 'Seeding applications'
seeds['applications'].each do |seed|
  logger.info '---'
  if Doorkeeper::Application.find_by(uid: seed['name']).present?
    logger.info "Application '#{seed['name']}' already exists"
    next
  end

  app = Doorkeeper::Application.create(seed)

  if app.errors.any?
    logger.error "Can't create application '#{app.name}': #{app.errors.full_messages.join('; ')}"
    next
  end

  logger.info "Created application '#{app.name}'"
  result[:applications].push(app.as_json(only: %i[name redirect_uri uid secret]))
end

logger.info '---'
logger.info 'Seeding levels'
seeds['levels'].each do |level_data|
  next if Level.exists?(level_data)
  Level.create!(level_data)
end

# print well-formated json to stderr (easy to read in the commant output)
logger.info "Result:\n#{JSON.pretty_generate(result)}"

# print json to stdout (can pipe to something else)
puts JSON.generate(result)
