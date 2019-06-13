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

    def inspect
      str = "Seeded users:\n"
      str += @result.map do |user|
        "Email: #{user[:email]}, password: #{user[:password]}"
      end.join("\n")
      return str
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

    def seed_permissions
      logger.info "Seeding permissions"
      seeds["permissions"].each do |perm|
        logger.info "---"
        if Permission.find_by(role: perm["role"], verb: perm["verb"], path: perm["path"], action: perm["action"]).present?
          logger.info "Permission for '#{perm['role']}' : '#{perm['verb']} to #{perm['path']}' already exists"
          next
        end

        permission = Permission.new(perm)

        unless permission.save
          raise ConfigError.new("Can't create permission: #{permission.errors.full_messages.join('; ')}")
        end
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

          @result.push(email: user.email, password: user.password, level: user.level)
        else
          logger.error "Can't create user '#{user.email}': #{user.errors.full_messages.join('; ')}"
        end
      end
    end
  end
end
