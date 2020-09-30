## Encryption

Data sensitivity will be defined as follow:\
**Low**: IP address\
**Medium**: Email address, Location data\
**High**: Full name, Street address, phone number, date of birth\
**Very High**: Passport number, Driver’s license number

Low and Medium will not be masked on the UI.
High and very high must be masked and encrypted in database.

### Approach
Rails offers a handy ActiveSupport::MessageEncryptor class, that hides away all the complexity of data encryption, and was wrapped in a simple to use service object or reusable module.

Service object class doing the actual heavy lifting, but only exposing two straightforward public class methods encrypt and decrypt.

Make sure to store `SECRET_KEY_BASE` somewhere safe otherwise, you would not be able to decrypt your secure data, also you need to have this ENV variable at the start of your application as it will not create models (Profile, Phone, Documents) which have encrypted fields.

#### Searching by encrypted values

To have ability to search by encrypted fields, system implements additional field named `attribute_index` which use [crc32 algorithm](http://www.sunshine2k.de/articles/coding/crc/understanding_crc.html) for storing attribute value.

Make sure you have `BARONG_CRC32_SALT` to make algrithm more powerful.