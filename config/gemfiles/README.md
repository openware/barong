## HOWTO install different gem subsets dynamically

 1. Create a subfolder under `config/gemfiles` let's say `config/gemfiles/gems-1`
 2. Create a `Gemfile` in `config/gemfiles/gems-1` 
 3. To `install` gems from this subfolder issue `cd ./config/gemfiles/gems-1/ && bundle install --gemfile=Gemfile`
 4. To `update` gems issue: `cd ./config/gemfiles/gems-1/ && bundle update <gem-name>`. The `Gemfile` from current folder will be used.
 5. By analogy `any` other `bundler` command will work.