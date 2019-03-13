Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           '1011189495074-5l4tfeuvdctvvo8g1sv7i5tjaib20b7c.apps.googleusercontent.com',
           '3IksaeAo4ml8CKzZfe2f55zB'
end
