if (Raven) {
   dsn = document.querySelector('meta[name="sentry-dsn"]').getAttribute('content')
   if (dsn) {
     Raven.config(dsn).install()
  }
}
