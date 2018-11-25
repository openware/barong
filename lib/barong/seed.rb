module Barong
  class Seed
    class ConfigError < RuntimeError; end

    def initialize
      @result = []
    end

    def seeds
      YAML.safe_load(
        ERB.new(
          File.read(
            ENV.fetch("SEEDS_FILE", Rails.root.join("config", "seeds.yml"))
          )
        ).result
      )
    end

    def show_seeded_users
      puts "Seeded users:"
      @result.each do |user|
        puts "Email: #{user[:email]}, password: #{user[:password]}"
      end
    end

    def logger
      @logger ||= Logger.new(STDERR, progname: "db:seed")
    end

    def seed_levels
      logger.info "Seeding levels"
      seeds["levels"].each_with_index do |level, index|
        logger.info "---"
        if Level.find_by(key: level["key"], value: level["value"]).present?
          logger.info "Level '#{level['key']}:#{level['value']}' already exists"
          next
        end
        level[:id] = index+1
        Level.create!(level)
      end
    end

    def seed_users
      logger.info "Seeding users"
      seeds["users"].each do |seed|
        logger.info "---"

        raise ConfigError.new("Email missing in users seed") if seed["email"].to_s.empty?
        raise ConfigError.new("Level is missing for user #{seed["email"]}") unless seed["level"].is_a?(Integer)

        # Skip existing users
        if User.find_by(email: seed["email"]).present?
          logger.info "User '#{seed['email']}' already exists"
          @result.push(email: seed["email"])
          next
        end

        user = User.new(seed)
        user.password ||= SecureRandom.base64(30)

        if user.save
          logger.info "Created user for '#{user.email}'"

          # Set correct level with labels
          levels = levels = Level.where(id: 1..user.level)
          raise ConfigError.new("No enough levels found in database to grant the user to level #{user.level}") if levels.count < user.level
          levels.find_each do |level|
            user.add_level_label(level.key, level.value)
          end

          # Confirm the email
          if user.update(updated_at: Time.current)
            user.add_level_label("email")
            logger.info("Confirmed email for '#{user.email}'")
          end

          # Create a Profile using defaults where values are not set in seeds.yml
          if seed["phone"]
            phone = Phone.new(seed["phone"])
            phone.user = user

            if phone.save && phone.update(validated_at: Time.current)
              logger.info "Created phone for '#{user.email}'"
            else
              logger.error "Can't create phone for '#{user.email}': #{phone.errors.full_messages.join('; ')}"
            end
          end

          # Create a Profile using defaults where values are not set in seeds.yml
          if seed["profile"]
            profile = Profile.new(seed["profile"])
            profile.user = user

            if profile.save
              logger.info "Created profile for '#{user.email}'"
            else
              logger.error "Can't create profile for '#{user.email}': #{profile.errors.full_messages.join('; ')}"
            end
          end

          @result.push(email: user.email, password: user.password, level: user.level)
        else
          logger.error "Can't create user '#{user.email}': #{user.errors.full_messages.join('; ')}"
        end
      end
    end
  end
end
