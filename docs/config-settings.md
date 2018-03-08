### Calling ENV, secrets, custom settings via unified wrapper `Barong.config..`

1. There are several backends for storing configuration settings: 
- `env`  - ENV variables, 
- `db` database table `config_settings`, ability to dynamically write to this backend is present (configurable).
- `yaml` -  values taken from `config_settings_seed.yml` primarily for seeding `db` backend
- `secrets` - values is taken from `config/secrets.yml`
- `memory` - values taken from in-memory object

2. The values will be searched in _backends_ in particular order via wrapper i.e.`Barong.config.rails_max_threads` for mandatory values. With error raised if value not present. For optional values syntax `Barong.config[:rails_max_threads]` could be used, returning `nil` if value not present.

3. There's an ability to construct more complex configurations. See `email` section in `config/config_settings_seed.yml`

4. There's an ability to _validate_ or _modify_ the values (including complex config structures) by writing `casts`. See `config/config_settings_casts`