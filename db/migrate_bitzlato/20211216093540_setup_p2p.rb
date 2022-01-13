class SetupP2p < ActiveRecord::Migration[6.1]
  def up
    return unless Rails.env.development? || Rails.env.test?

    return if tables.count > 10 # Похоже натравили на существующую базу типа стейджа

    execute %[
    CREATE SCHEMA p2p;
    CREATE TABLE public.cryptocurrency (
        code character varying(4) NOT NULL,
        name character varying(256) NOT NULL,
        scale smallint DEFAULT 8 NOT NULL,
        weight smallint NOT NULL,
        CONSTRAINT cryptocurrency_code_check CHECK ((length((code)::text) > 0)),
        CONSTRAINT cryptocurrency_name_check CHECK ((length((name)::text) > 0))
    );

    ALTER TABLE ONLY public.cryptocurrency
        ADD CONSTRAINT cryptocurrency_name_key UNIQUE (name);


    --
    -- Name: cryptocurrency cryptocurrency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
    --

    ALTER TABLE ONLY public.cryptocurrency
        ADD CONSTRAINT cryptocurrency_pkey PRIMARY KEY (code);


    --
    CREATE TABLE public."user" (
        id integer NOT NULL,
        subject character varying(510) NOT NULL,
        nickname character varying(510),
        email_verified boolean NOT NULL,
        chat_enabled boolean NOT NULL,
        email_auth_enabled boolean NOT NULL,
        created_at timestamp without time zone DEFAULT now() NOT NULL,
        updated_at timestamp without time zone DEFAULT now() NOT NULL,
        telegram_id character varying(256),
        auth0_id character varying,
        ref_parent_user_id integer,
        referrer integer,
        country character varying,
        real_email text,
        "2fa_enabled" boolean DEFAULT false NOT NULL,
        authority_can_make_deal boolean DEFAULT true NOT NULL,
        authority_can_make_order boolean DEFAULT true NOT NULL,
        authority_can_make_voucher boolean DEFAULT true NOT NULL,
        authority_can_make_withdrawal boolean DEFAULT true NOT NULL,
        authority_is_admin boolean DEFAULT false NOT NULL,
        deleted_at timestamp without time zone,
        password_reset_at timestamp without time zone,
        sys_code character varying(63)
    );
    ALTER TABLE ONLY public."user"
        ADD CONSTRAINT users_pkey PRIMARY KEY (id);

    -- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
    --

    CREATE SEQUENCE public.users_id_seq
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;


    --
    -- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
    --

    ALTER SEQUENCE public.users_id_seq OWNED BY public."user".id;

    CREATE DOMAIN public.cryptocurrency_amount AS numeric(60,8)
      CONSTRAINT cryptocurrency_amount_check CHECK ((VALUE <> 'NaN'::numeric));


    --
    -- Name: cryptocurrency_code; Type: DOMAIN; Schema: public; Owner: -
    --

    CREATE DOMAIN public.cryptocurrency_code AS character varying(4)
      CONSTRAINT cryptocurrency_code_check1 CHECK ((length((VALUE)::text) >= 3));

    CREATE TABLE public.wallet (
        id integer NOT NULL,
        user_id integer NOT NULL,
        address character varying(800),
        balance public.cryptocurrency_amount DEFAULT 0 NOT NULL,
        hold_balance public.cryptocurrency_amount DEFAULT 0 NOT NULL,
        created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
        updated_at timestamp without time zone DEFAULT now() NOT NULL,
        debt public.cryptocurrency_amount DEFAULT 0 NOT NULL,
        cc_code public.cryptocurrency_code NOT NULL,
        CONSTRAINT balance_check CHECK (((balance)::numeric >= (0)::numeric)),
        CONSTRAINT debt_check CHECK (((debt)::numeric >= (0)::numeric)),
        CONSTRAINT hold_check CHECK (((hold_balance)::numeric >= (0)::numeric))
    );


    CREATE SEQUENCE public.wallets_id_seq
        AS integer
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;


    --
    -- Name: wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
    --

    ALTER SEQUENCE public.wallets_id_seq OWNED BY public.wallet.id;
    ALTER TABLE ONLY public.wallet
        ADD CONSTRAINT wallets_address_key UNIQUE (cc_code, address);

    ALTER TABLE ONLY public.wallet
        ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);

    CREATE INDEX wallet_user_id ON public.wallet USING btree (user_id);


    CREATE TABLE public.user_cryptocurrency_settings (
        user_id integer NOT NULL,
        cc_code public.cryptocurrency_code NOT NULL,
        trading_enabled boolean DEFAULT true NOT NULL
    );
    CREATE UNIQUE INDEX user_cryptocurrency_settings_user_id_cryptocurrency_code_idx ON public.user_cryptocurrency_settings USING btree (user_id, cc_code) WHERE trading_enabled;
    ALTER TABLE ONLY public.user_cryptocurrency_settings
        ADD CONSTRAINT user_cryptocurrency_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);

          CREATE TABLE p2p.cryptocurrency_settings (
              code public.cryptocurrency_code NOT NULL,
              ref_trader_bonus_percent real NOT NULL,
              trade_comission_percent real,
              hot_wallet_balance public.cryptocurrency_amount,
              cold_wallet_audit_adjust public.cryptocurrency_amount,
              withdraw_enabled boolean DEFAULT true NOT NULL,
              deposit_enabled boolean DEFAULT true NOT NULL,
              optimal_enabled boolean DEFAULT true NOT NULL,
              free_enabled boolean DEFAULT false NOT NULL,
              free_trades_enabled boolean DEFAULT false NOT NULL,
              min_withdrawal public.cryptocurrency_amount DEFAULT 0 NOT NULL,
              is_token boolean DEFAULT false NOT NULL,
              ref_ad_bonus_percent real NOT NULL,
              pay_many_stack integer DEFAULT 1 NOT NULL,
              minimum_ad_enabled_amount public.cryptocurrency_amount DEFAULT 0 NOT NULL,
              real_cold_wallet_balance public.cryptocurrency_amount DEFAULT 0 NOT NULL,
              freeze_amount public.cryptocurrency_amount DEFAULT '1'::numeric NOT NULL,
              trades_enabled boolean DEFAULT true NOT NULL,
              is_shitcoin boolean DEFAULT false NOT NULL,
              is_delisted boolean DEFAULT false NOT NULL,
              has_cold_wallet boolean DEFAULT false NOT NULL,
              cold_wallet_balance_updated_at timestamp without time zone,
              bot_name character varying(126),
              blockchain_url character varying(126),
              hot_wallet_unconfirmed_balance public.cryptocurrency_amount,
              min_acceptable_deposit public.cryptocurrency_amount,
              mature_trader_min_turnover public.cryptocurrency_amount,
              in_rating boolean DEFAULT false NOT NULL,
              debt numeric(60,8) DEFAULT 0 NOT NULL,
              audit_watchdog_deposit_interval interval,
              withdraw_amount_limit public.cryptocurrency_amount,
              custom jsonb,
              CONSTRAINT cryptocurrency_settings_check CHECK (((NOT is_delisted) OR (NOT (trades_enabled OR withdraw_enabled OR deposit_enabled)))),
              CONSTRAINT cryptocurrency_settings_debt_check CHECK ((debt >= (0)::numeric)),
              CONSTRAINT cryptocurrency_settings_min_acceptable_deposit_check CHECK (((min_acceptable_deposit)::numeric > (0)::numeric)),
              CONSTRAINT cryptocurrency_settings_withdraw_amount_limit_check CHECK (((withdraw_amount_limit)::numeric >= (min_withdrawal)::numeric))
          )
          WITH (fillfactor='85');

          CREATE TABLE p2p.rate (
            id integer NOT NULL,
            value numeric NOT NULL,
            url text NOT NULL,
            description text NOT NULL,
            currency_symbol character varying(5) NOT NULL,
            cc_code public.cryptocurrency_code NOT NULL,
            default_rate boolean DEFAULT false NOT NULL,
            updated_at timestamp without time zone DEFAULT now() NOT NULL,
            CONSTRAINT check_values CHECK ((value > (0)::numeric))
          );

          ALTER TABLE ONLY p2p.cryptocurrency_settings
              ADD CONSTRAINT cryptocurrency_settings_code_fkey FOREIGN KEY (code) REFERENCES public.cryptocurrency(code);
    ]
  end
end
