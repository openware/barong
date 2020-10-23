# Barong

## Profiles story and administration

This document explain original profiles submit-n-verify process and possible customizations.

## Version

Story described in the document actual for latest 2.5 stable version and higher.

## User side of the story

`Comment`: Previously (in 2.3 and lower) user was able to submit only 1 profile, and all later modifications affect it. Starting from 2.4 we changed `user has_one profile` relation to `user has many profiles`. This was done first of all to be able to track history of modifications and to be able to control changes from admin panel. Meanwhile, it also brought additional manual verification step in the legacy KYC process.

`Story`:
User can submit profile with following fields (all are optional by default):   (via `POST /resource/profiles`) 

```
    t.string "first_name"
    t.string "last_name"
    t.date "dob"
    t.string "address"
    t.string "postcode"
    t.string "city"
    t.string "country"
    t.text "metadata"
```

Profile creates with `drafted` state in database. At this point user can edit the information (via `PUT /resource/profiles`), and administrators will not review it yet. 
Once all the information is edited and validated by user correctly, he can submit profile for verification (via `PUT /resource/profiles`) by passing `confirmation: true` in the params. Profile state changes to "submitted" in database and from now on this profile is pending for admin verification.

Meanwhile, there is a possibility to skip this "edit" step and create a profile directly with `submitted` state. For this user need to pass `confirmation: true` parameter directly in `POST /resource/profiles`.

After admin will verify the profile and mark it as `"verified"` or `"rejected"` user will be able to create a new profile with `drafted/submitted` state, if he need it. Flow mostly controls by a `server-side rule`: user can have `ANY` amount of profiles, but `ONLY ONE` of `drafted/submitted` at a time.

## Admin side of the story

Once user sumbit a profile (with state submitted) admin can verify or reject it, by changing a profile state and creating a correct label. Usually its `key: profile, value: verified/rejected'.

Also administrator has an access to the full profiles history, so he can check and compare new changes with old profiles, if the exist. As well he has an information about previous decisions about profile verification per each request.

Once profile is rejected or verified, admin can create new profile for user (via `POST admin/profiles`).
In this case, profile will have a 'submitted' state and 'author' field with admin UID in DB. 

`!!!Attention` By default, if admin creates a profile for user, the same admin account cant approve or reject this profile, he need to wait for second admin approval. However, this can be changed by env `BARONG_PROFILE_DOUBLE_VERIFICATION` which can receive 2 value: `true` for enabling and `false` for disabling the feature
