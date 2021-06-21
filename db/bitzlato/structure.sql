SET search_path TO "p2p",public;
create schema "p2p";
DROP TABLE IF EXISTS "user_features";
CREATE TABLE "p2p"."user_features" (
    "user_id" integer NOT NULL,
    "feature_code" character varying(63) NOT NULL,
    CONSTRAINT "user_features_pkey" PRIMARY KEY ("user_id", "feature_code")
) WITH (oids = false);

DROP TABLE IF EXISTS "user_profile";
DROP SEQUENCE IF EXISTS user_profile_id_seq;
CREATE SEQUENCE user_profile_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE TABLE "p2p"."user_profile" (
    "id" integer DEFAULT nextval('user_profile_id_seq') NOT NULL,
    "lang" character varying(2) NOT NULL,
    "user_id" integer NOT NULL,
    "currency" character varying(5) NOT NULL,
    "cryptocurrency" character varying(256) NOT NULL,
    "start_of_use_date" timestamp DEFAULT now(),
    "rating" numeric NOT NULL,
    "lastactivity" timestamp DEFAULT now() NOT NULL,
    "blocked_by_admin" boolean DEFAULT false NOT NULL,
    "cancreateadvert_status" boolean,
    "verified" boolean DEFAULT false NOT NULL,
    "about_user" text DEFAULT '',
    "telegram_name" character varying,
    "user_info" text,
    "licensing_agreement_accepted" boolean DEFAULT false NOT NULL,
    "greeting" text,
    "safe_mode_enabled" boolean DEFAULT true NOT NULL,
    "pass_safety_wizard" boolean DEFAULT false NOT NULL,
    "suspicious" boolean DEFAULT false NOT NULL,
    "copilka" numeric,
    "merged" boolean DEFAULT false NOT NULL,
    "public_name" character varying,
    "lang_web" character varying(2),
    "verification_date" timestamp,
    "accept_marketing_emails" boolean DEFAULT true NOT NULL,
    "generated_name" character varying(20) NOT NULL,
    "phone" character varying(20),
    "is_muted" boolean DEFAULT false NOT NULL,
    "timezone" character varying(100),
    "pass_merge_wizard" boolean DEFAULT false NOT NULL,
    "safetyIndex_modifier" integer DEFAULT '0' NOT NULL,
    "avatar" character varying(40),
    CONSTRAINT "user_profile_generated_name_key" UNIQUE ("generated_name"),
    CONSTRAINT "user_profile_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "user_profile_public_name_key" UNIQUE ("public_name"),
    CONSTRAINT "user_profile_uniqie" UNIQUE ("user_id"),
    CONSTRAINT "user_profile_user_id_key" UNIQUE ("user_id")
  ) WITH (oids = false);

DROP TABLE IF EXISTS "users";
DROP SEQUENCE IF EXISTS users_id_seq;
CREATE SEQUENCE users_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1;

CREATE TABLE "public"."users" (
    "id" integer DEFAULT nextval('users_id_seq') NOT NULL,
    "subject" character varying(510) NOT NULL,
    "username" character varying(510) NOT NULL,
    "email_verified" boolean NOT NULL,
    "chat_enabled" boolean NOT NULL,
    "email_auth_enabled" boolean NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL,
    "telegram_id" character varying(256),
    "auth0_id" character varying,
    "ref_parent_user_id" integer DEFAULT currval('users_id_seq'),
    "referrer" integer,
    "country" character varying,
    "real_email" text,
    "2fa_enabled" boolean DEFAULT false NOT NULL,
    "authority_can_make_deal" boolean DEFAULT true NOT NULL,
    "authority_can_make_order" boolean DEFAULT true NOT NULL,
    "authority_can_make_voucher" boolean DEFAULT true NOT NULL,
    "authority_can_make_withdrawal" boolean DEFAULT true NOT NULL,
    "authority_is_admin" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "users_ref_parent_user_id_fkey" FOREIGN KEY (ref_parent_user_id) REFERENCES users(id) NOT DEFERRABLE
) WITH (oids = false);
