## Encryption

Data sensitivity will be defined as follow:\
**Low**: IP address\
**Medium**: Email address, Location data\
**High**: Full name, Street address, phone number, date of birth\
**Very High**: Passport number, Driver’s license number

Low and Medium will not be masked on the UI.

| Field | Mask |  Comment |
|---|---|---|
| Street address | No mask  | No need  |
| First Name | No mask | No need  |
| Last Name | B****** | Display first letter  |
| Phone Number | +380 **** 4556 | Display country code and last 4 digits  |
| Date of birth | 1980-01-** | Hide day |
| Document Number | FG****64 | First 2 number and last 2 digits |

### Approach
Rails offers a handy ActiveSupport::MessageEncryptor class, that hides away all the complexity of data encryption, and was wrapped in a simple to use service object or reusable module.

Service object class doing the actual heavy lifting, but only exposing two straightforward public class methods encrypt and decrypt.

System have weekly salt rotation, so encrypted keys in DB will be prepended with salt, which will be mix of year and week number starting from 0.

Make sure to store `SECRET_KEY_BASE` somewhere safe otherwise, you would not be able to decrypt your secure data, also you need to have this ENV variable at the start of your application as it will not create models (Profile, Phone, Documents) which have encrypted fields.

#### Searching by encrypted values

To have ability to search by encrypted fields, system implements additional field named `attribute_index` which use [crc32 algorithm](http://www.sunshine2k.de/articles/coding/crc/understanding_crc.html) for storing attribute value.

Make sure you have `BARONG_CRC32_SALT` to make algrithm more powerful.

#### Rotation

To update all encrypted fields to latest key values (salt will be "#{current_year}#{current_week}"), you can use following rake tasks:

`rake rotate:phones`
`rake rotate:profiles`
`rake rotate:documents`

### Fields masking on user API

Sensitive data fields like `last name`, `dob`, `phone number`, `document number` are masked in user API by default.
You can disable this masking by changing the environment variable `BARONG_API_DATA_MASKING_ENABLED` to `false`.
