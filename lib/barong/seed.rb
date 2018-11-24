module Barong
  class Seed
    def initialize
    end

    def seeds
      YAML.safe_load(
        ERB.new(
          File.read(
            ENV.fetch('SEEDS_FILE', Rails.root.join('config', 'seeds.yml'))
          )
        ).result
      )
    end

    def logger
      @logger ||= Logger.new(STDERR, progname: 'db:seed')
    end

    def seed_levels
      logger.info 'Seeding levels'
      seeds['levels'].each do |level_data|
        logger.info '---'
        if Level.find_by(key: level_data['key'], value: level_data['value']).present?
          logger.info "Level '#{level_data['key']}:#{level_data['value']}' already exists"
          next
        end
        Level.create!(level_data)
      end
    end

    def seed_users
      logger.info 'Seeding users'
      seeds['users'].each do |seed|
        logger.info '---'

        # Skip existing users
        if User.kept.find_by(email: seed['user']['email']).present?
          logger.info "User '#{seed['user']['email']}' already exists"
          result[:users].push(email: seed['user']['email'])
          next
        end

        admin = User.new(seed['user'])
        admin.password ||= SecureRandom.base64(30)

        if admin.save
          logger.info "Created user for '#{admin.email}'"

          # Set correct level with labels
          Level.where(id: 1..admin.level).find_each do |level|
            admin.add_level_label(level.key, level.value)
          end

          # Confirm the email
          if admin.update(confirmed_at: Time.current)
            admin.add_level_label('email')
            logger.info("Confirmed email for '#{admin.email}'")
          end

          # Create a Profile using defaults where values are not set in seeds.yml
          if seed['phone']
            phone = Phone.new(seed['phone'])
            phone.user = admin

            if phone.save && phone.update(validated_at: Time.current)
              logger.info "Created phone for '#{admin.email}'"
            else
              logger.error "Can't create phone for '#{admin.email}': #{phone.errors.full_messages.join('; ')}"
            end
          end

          # Create a Profile using defaults where values are not set in seeds.yml
          if seed['profile']
            profile = Profile.new(seed['profile'])
            profile.user = admin

            if profile.save
              logger.info "Created profile for '#{admin.email}'"
            else
              logger.error "Can't create profile for '#{admin.email}': #{profile.errors.full_messages.join('; ')}"
            end
          end

          result[:users].push(email: admin.email, password: admin.password, level: admin.level)
        else
          logger.error "Can't create admin '#{admin.email}': #{admin.errors.full_messages.join('; ')}"
        end
      end
    end
  end
end
