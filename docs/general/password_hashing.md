## Barong password hashing ##

### Overview ###

Barong since 2.0 version use OpenBSD bcrypt() password hashing algorithm, that allow us easily store a secure hash of users' passwords.

As a base Barong takes [bcrypt-ruby gem](https://github.com/codahale/bcrypt-ruby) - Ruby binding for the OpenBSD bcrypt()
With [rails 5 has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html) it gives us full power of algorithm

### How it works ###

Hash algorithms take a chunk of data (e.g., user's password) and create a "digital fingerprint," or hash, of it.
Because this process is not reversible, there's no way to go from the hash back to the password.

In other words:

    hash(p) #=> <unique gibberish>

We store the hash and check it against a hash made of a potentially valid password:

    <unique gibberish> =? hash(just_entered_password)

### Rainbow Tables

But even this has weaknesses -- attackers can just run lists of possible passwords through the same algorithm, store the
results in a big database, and then look up the passwords by their hash:

    PrecomputedPassword.find_by_hash(<unique gibberish>).password #=> "secret1"

Our solution to this is to add a small chunk of random data -- called a salt -- to the password before it's hashed:

    hash(salt + p) #=> <really unique gibberish>

The salt is then stored along with the hash in the database, and used to check potentially valid passwords:

    <really unique gibberish> =? hash(salt + just_entered_password)

bcrypt-ruby automatically handles the storage and generation of these salts for you.

Adding a salt means that an attacker has to have a gigantic database for each unique salt -- for a salt made of 4
letters, that's 456,976 different databases. Pretty much no one has that much storage space, so attackers try a
different, slower method -- throw a list of potential passwords at each individual password:

    hash(salt + "aadvark") =? <really unique gibberish>
    hash(salt + "abacus")  =? <really unique gibberish>
    etc.

This is much slower than the big database approach, but most hash algorithms are pretty quick -- and therein lies the
problem. Hash algorithms aren't usually designed to be slow, they're designed to turn gigabytes of data into secure
fingerprints as quickly as possible. `bcrypt()`, though, is designed to be computationally expensive:

    Ten thousand iterations:
                 user     system      total        real
    md5      0.070000   0.000000   0.070000 (  0.070415)
    bcrypt  22.230000   0.080000  22.310000 ( 22.493822)

If an attacker was using Ruby to check each password, they could check ~140,000 passwords a second with MD5 but only
~450 passwords a second with `bcrypt()`.

## More Information

`bcrypt()` is currently used as the default password storage hash in OpenBSD, widely regarded as the most secure operating
system available.

For a more technical explanation of the algorithm and its design criteria, please read Niels Provos and David Mazières'
Usenix99 paper:
https://www.usenix.org/events/usenix99/provos.html

If you'd like more down-to-earth advice regarding cryptography, I suggest reading <i>Practical Cryptography</i> by Niels
Ferguson and Bruce Schneier:
https://www.schneier.com/book-practical.html