--
-- PostgreSQL database dump
--

-- Dumped from database version 13.3 (Ubuntu 13.3-1.pgdg18.04+1)
-- Dumped by pg_dump version 13.2 (Ubuntu 13.2-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.withdrawal DROP CONSTRAINT IF EXISTS withdrawal_blockchain_tx_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wallet_address_hist DROP CONSTRAINT IF EXISTS wallet_address_hist_wallet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wallet_address_hist DROP CONSTRAINT IF EXISTS wallet_address_hist_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.wallet_address_hist DROP CONSTRAINT IF EXISTS wallet_address_hist_cryptocurrency_code_fkey;
ALTER TABLE IF EXISTS ONLY public.wallet_address_hist DROP CONSTRAINT IF EXISTS wallet_address_hist_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY public."user" DROP CONSTRAINT IF EXISTS users_ref_parent_user_id_fkey;
ALTER TABLE IF EXISTS public.user_token_mfa DROP CONSTRAINT IF EXISTS user_tokens_mfa_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_cryptocurrency_settings DROP CONSTRAINT IF EXISTS user_cryptocurrency_settings_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_cryptocurrency_settings DROP CONSTRAINT IF EXISTS user_cryptocurrency_settings_cryptocurrency_code_fkey;
ALTER TABLE IF EXISTS ONLY public.user_auth_pub_key DROP CONSTRAINT IF EXISTS user_auth_pub_key_user_id_fkey;
ALTER TABLE IF EXISTS public.signed_operation_request DROP CONSTRAINT IF EXISTS signed_operation_request_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.withdrawal DROP CONSTRAINT IF EXISTS payments_wallet_id_fkey;
ALTER TABLE IF EXISTS ONLY public.withdrawal DROP CONSTRAINT IF EXISTS payments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.withdrawal DROP CONSTRAINT IF EXISTS payments_currency_fkey;
ALTER TABLE IF EXISTS ONLY public.deposit DROP CONSTRAINT IF EXISTS deposit_blockchain_tx_id_fkey;
ALTER TABLE IF EXISTS ONLY public.banned_user DROP CONSTRAINT IF EXISTS banned_user_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY public.admin_user DROP CONSTRAINT IF EXISTS admin_user_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account_swap_log DROP CONSTRAINT IF EXISTS account_swap_log_old_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account_swap_log DROP CONSTRAINT IF EXISTS account_swap_log_new_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account_swap_log DROP CONSTRAINT IF EXISTS account_swap_log_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY public.account_kyc_hist DROP CONSTRAINT IF EXISTS account_kyc_hist_acc_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.withdraw_voucher DROP CONSTRAINT IF EXISTS withdraw_vouchers_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.withdraw_voucher DROP CONSTRAINT IF EXISTS withdraw_vouchers_prime_time_event_name_fkey;
ALTER TABLE IF EXISTS ONLY p2p.withdraw_voucher DROP CONSTRAINT IF EXISTS withdraw_vouchers_payment_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.wallet_log DROP CONSTRAINT IF EXISTS wallet_log_wallet_id_fkey1;
ALTER TABLE IF EXISTS ONLY p2p."backup$wallet_log" DROP CONSTRAINT IF EXISTS wallet_log_wallet_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.voucher DROP CONSTRAINT IF EXISTS voucher_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.utm_statistic DROP CONSTRAINT IF EXISTS utm_statistic_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_2fa DROP CONSTRAINT IF EXISTS users_2fa_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_trust DROP CONSTRAINT IF EXISTS user_trust_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_trust DROP CONSTRAINT IF EXISTS user_trust_trusted_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_settings DROP CONSTRAINT IF EXISTS user_settings_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_rate DROP CONSTRAINT IF EXISTS user_rates_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_rate DROP CONSTRAINT IF EXISTS user_rates_rate_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_lang_web_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_lang_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_currency_symbol_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_cryptocurrency_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_note DROP CONSTRAINT IF EXISTS user_notes_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_note DROP CONSTRAINT IF EXISTS user_notes_for_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_feature DROP CONSTRAINT IF EXISTS user_features_feature_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_block DROP CONSTRAINT IF EXISTS user_block_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_block DROP CONSTRAINT IF EXISTS user_block_blocked_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_ad_filter DROP CONSTRAINT IF EXISTS user_ad_filter_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_action_freeze DROP CONSTRAINT IF EXISTS user_actions_freeze_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.user_action_freeze DROP CONSTRAINT IF EXISTS user_action_freeze_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.untrusted_user DROP CONSTRAINT IF EXISTS untrusted_user_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade DROP CONSTRAINT IF EXISTS trades_crypto_seller_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade DROP CONSTRAINT IF EXISTS trades_crypto_buyer_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade DROP CONSTRAINT IF EXISTS trades_ad_paymethod_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade DROP CONSTRAINT IF EXISTS trades_ad_initiator_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade DROP CONSTRAINT IF EXISTS trades_ad_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic DROP CONSTRAINT IF EXISTS trade_statistic_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic_log DROP CONSTRAINT IF EXISTS trade_statistic_log_ts_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic_log DROP CONSTRAINT IF EXISTS trade_statistic_log_admin_code_fkey1;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic_log DROP CONSTRAINT IF EXISTS trade_statistic_log_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic DROP CONSTRAINT IF EXISTS trade_statistic_cryptocurrency_fkey1;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic DROP CONSTRAINT IF EXISTS trade_statistic_cryptocurrency_fkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_history DROP CONSTRAINT IF EXISTS trade_history_trade_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.requisite DROP CONSTRAINT IF EXISTS requisites_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.referal_bonus DROP CONSTRAINT IF EXISTS referal_bonuses_trade_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.referal_bonus DROP CONSTRAINT IF EXISTS referal_bonuses_referal_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.referal_bonus DROP CONSTRAINT IF EXISTS referal_bonuses_ref_parent_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.referal_bonus DROP CONSTRAINT IF EXISTS referal_bonuses_cryptocurrency_fkey;
ALTER TABLE IF EXISTS ONLY p2p.rating_change_log DROP CONSTRAINT IF EXISTS rating_change_log_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.rate DROP CONSTRAINT IF EXISTS rates_currency_symbol_fkey;
ALTER TABLE IF EXISTS ONLY p2p.rate DROP CONSTRAINT IF EXISTS rates_cryptocurrency_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.rate_plan_withdraw DROP CONSTRAINT IF EXISTS rate_plan_withdraw_cc_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_list_precalculation DROP CONSTRAINT IF EXISTS payments_list_precalculation_payments_group_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_list_precalculation DROP CONSTRAINT IF EXISTS payments_list_precalculation_payment_method_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_group_multilang DROP CONSTRAINT IF EXISTS payments_group_multilang_payments_group_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method DROP CONSTRAINT IF EXISTS payment_method_payments_group_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method_hist DROP CONSTRAINT IF EXISTS payment_method_hist_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method_hist DROP CONSTRAINT IF EXISTS payment_method_hist_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method_global DROP CONSTRAINT IF EXISTS payment_method_global_payments_group_fkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method DROP CONSTRAINT IF EXISTS payment_method_currency_fkey;
ALTER TABLE IF EXISTS ONLY p2p.old_data_profile DROP CONSTRAINT IF EXISTS old_data_profile_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.notification_token DROP CONSTRAINT IF EXISTS notification_token_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.notebook DROP CONSTRAINT IF EXISTS notebook_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.muted_user DROP CONSTRAINT IF EXISTS muted_user_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.merge DROP CONSTRAINT IF EXISTS merges_web_account_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.merge DROP CONSTRAINT IF EXISTS merges_telegram_account_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.merge_token DROP CONSTRAINT IF EXISTS merge_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.identity_verification_attempt DROP CONSTRAINT IF EXISTS identity_verification_attempt_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.feedback DROP CONSTRAINT IF EXISTS feedbacks_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.feature DROP CONSTRAINT IF EXISTS features_required_feature_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute DROP CONSTRAINT IF EXISTS disputes_trade_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute DROP CONSTRAINT IF EXISTS disputes_seller_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute DROP CONSTRAINT IF EXISTS disputes_buyer_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute_video DROP CONSTRAINT IF EXISTS dispute_video_dispute_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute_video DROP CONSTRAINT IF EXISTS dispute_video_admin_code_fkey1;
ALTER TABLE IF EXISTS ONLY p2p.dispute_video DROP CONSTRAINT IF EXISTS dispute_video_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute_decision DROP CONSTRAINT IF EXISTS dispute_decisions_trade_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute_decision DROP CONSTRAINT IF EXISTS dispute_decisions_dispute_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute_decision DROP CONSTRAINT IF EXISTS dispute_decision_admin_code_fkey1;
ALTER TABLE IF EXISTS ONLY p2p.dispute_decision DROP CONSTRAINT IF EXISTS dispute_decision_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute DROP CONSTRAINT IF EXISTS dispute_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.deep_link_referal_action DROP CONSTRAINT IF EXISTS deep_link_referal_action_parent_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.deep_link_referal_action DROP CONSTRAINT IF EXISTS deep_link_referal_action_deep_link_action_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.debt DROP CONSTRAINT IF EXISTS debts_wallet_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.debt DROP CONSTRAINT IF EXISTS debt_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.debt DROP CONSTRAINT IF EXISTS debt_action_admin_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.cryptocurrency_settings DROP CONSTRAINT IF EXISTS cryptocurrency_settings_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.cryptocurrency_rate_source DROP CONSTRAINT IF EXISTS cryptocurrency_rate_source_rate_source_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.cryptocurrency_rate_source DROP CONSTRAINT IF EXISTS cryptocurrency_rate_source_cryptocurrency_code_fkey;
ALTER TABLE IF EXISTS ONLY p2p.chat DROP CONSTRAINT IF EXISTS chat_trade_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.chat DROP CONSTRAINT IF EXISTS chat_author_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.chat DROP CONSTRAINT IF EXISTS chat_admin_file_uploaded_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.ad DROP CONSTRAINT IF EXISTS ads_user_id_fkey;
ALTER TABLE IF EXISTS ONLY p2p.ad DROP CONSTRAINT IF EXISTS ads_paymethod_fkey;
ALTER TABLE IF EXISTS ONLY p2p.ad DROP CONSTRAINT IF EXISTS ads_cryptocurrency_fkey;
DROP TRIGGER IF EXISTS global_paymethods_update_handler ON p2p.payment_method_global;
DROP TRIGGER IF EXISTS global_paymethods_insert_handler ON p2p.payment_method_global;
DROP TRIGGER IF EXISTS global_paymethods_delete_handler ON p2p.payment_method_global;
DROP TRIGGER IF EXISTS check_two_user_rates_trigger_before_insert ON p2p.user_rate;
DROP TRIGGER IF EXISTS check_two_trades_trigger_after_insert ON p2p.trade;
DROP INDEX IF EXISTS public.wallet_user_id;
DROP INDEX IF EXISTS public.users_username_idx1;
DROP INDEX IF EXISTS public.users_telegram_id_idx1;
DROP INDEX IF EXISTS public.users_telegram_id_idx;
DROP INDEX IF EXISTS public.users_subject_idx1;
DROP INDEX IF EXISTS public.users_subject_idx;
DROP INDEX IF EXISTS public.users_ref_parent_user_id_idx;
DROP INDEX IF EXISTS public.users_real_email_idx;
DROP INDEX IF EXISTS public.user_cryptocurrency_settings_user_id_cryptocurrency_code_idx;
DROP INDEX IF EXISTS public.transactions_user_id_idx;
DROP INDEX IF EXISTS public.transactions_txid_idx;
DROP INDEX IF EXISTS public.transactions_created_at_idx;
DROP INDEX IF EXISTS public.transactions_address_idx;
DROP INDEX IF EXISTS public."signed_operation_request$20211216_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211215_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211214_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211213_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211212_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211211_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211210_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211209_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211208_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211207_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211206_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211205_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211204_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211203_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211202_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211201_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211130_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211129_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211128_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211127_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211126_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211125_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211124_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211123_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211122_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211121_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211120_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211119_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211118_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211117_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211116_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211115_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211114_id_idx";
DROP INDEX IF EXISTS public."signed_operation_request$20211113_id_idx";
DROP INDEX IF EXISTS public.signed_operation_request_id_idx;
DROP INDEX IF EXISTS public.payments_user_id_idx;
DROP INDEX IF EXISTS public.payments_transaction_id_idx;
DROP INDEX IF EXISTS public.payments_status_idx;
DROP INDEX IF EXISTS public.payments_created_at_id_idx;
DROP INDEX IF EXISTS public.payments_cc_code_idx;
DROP INDEX IF EXISTS public.payments_amount_idx;
DROP INDEX IF EXISTS public.payments_address_idx;
DROP INDEX IF EXISTS public.flyway_schema_history_s_idx;
DROP INDEX IF EXISTS public.deposit_cc_code_idx;
DROP INDEX IF EXISTS public.admin_user_user_id_idx;
DROP INDEX IF EXISTS p2p.wallet_log_wallet_id_idx;
DROP INDEX IF EXISTS p2p.wallet_log_wallet_id;
DROP INDEX IF EXISTS p2p.wallet_log_date_idx1;
DROP INDEX IF EXISTS p2p.wallet_log_date_idx;
DROP INDEX IF EXISTS p2p.voucher_user_id_idx;
DROP INDEX IF EXISTS p2p.voucher_user_id_cc_code_idx;
DROP INDEX IF EXISTS p2p.voucher_cashed_at_idx;
DROP INDEX IF EXISTS p2p.user_rates_user_id_idx;
DROP INDEX IF EXISTS p2p.user_profile_verified_idx;
DROP INDEX IF EXISTS p2p.user_profile_verification_date_idx;
DROP INDEX IF EXISTS p2p.user_profile_telegram_name_idx_new;
DROP INDEX IF EXISTS p2p.user_profile_start_of_use_idx;
DROP INDEX IF EXISTS p2p.user_profile_rating;
DROP INDEX IF EXISTS p2p.user_profile_lastactivity_idx;
DROP INDEX IF EXISTS p2p.user_profile_blocked_by_admin;
DROP INDEX IF EXISTS p2p.user_block_blocked_user_id_idx;
DROP INDEX IF EXISTS p2p.trgm_idx_wallet_log_cause;
DROP INDEX IF EXISTS p2p.trades_trade_initiator_idx;
DROP INDEX IF EXISTS p2p.trades_status_idx;
DROP INDEX IF EXISTS p2p.trades_status_advanced_idx;
DROP INDEX IF EXISTS p2p.trades_cryptocurrency_idx;
DROP INDEX IF EXISTS p2p.trades_crypto_seller_idx;
DROP INDEX IF EXISTS p2p.trades_crypto_buyer_idx;
DROP INDEX IF EXISTS p2p.trades_created_at_idx;
DROP INDEX IF EXISTS p2p.trades_comission_idx;
DROP INDEX IF EXISTS p2p.trades_amount_idx;
DROP INDEX IF EXISTS p2p.trades_ad_user_id_idx;
DROP INDEX IF EXISTS p2p.trades_ad_paymethod_idx;
DROP INDEX IF EXISTS p2p.trade_statistic_idx;
DROP INDEX IF EXISTS p2p.trade_statistic_cryptocurrency_user_id_idx;
DROP INDEX IF EXISTS p2p.trade_history_trade_id_idx;
DROP INDEX IF EXISTS p2p.trade_history_status;
DROP INDEX IF EXISTS p2p.trade_history_date_idx;
DROP INDEX IF EXISTS p2p.trade_crypto_seller_ad_paymethod_status_idx;
DROP INDEX IF EXISTS p2p.sell_ads_mview_cc_code_idx;
DROP INDEX IF EXISTS p2p.sell_ads_mview_aid_idx;
DROP INDEX IF EXISTS p2p.referal_bonuses_ref_parent_user_id_idx;
DROP INDEX IF EXISTS p2p.rates_default_rate_idx;
DROP INDEX IF EXISTS p2p.rates_currency_symbol_idx;
DROP INDEX IF EXISTS p2p.rates_cryptocurrency_code_idx;
DROP INDEX IF EXISTS p2p.rates_cryptocurrency_code_currency_symbol_idx;
DROP INDEX IF EXISTS p2p.payments_list_precalculation_currency_idx;
DROP INDEX IF EXISTS p2p.payments_list_precalculation_cryptocurrency_idx;
DROP INDEX IF EXISTS p2p.payments_list_precalculation_ads_type_idx;
DROP INDEX IF EXISTS p2p.payment_method_i18n_idx;
DROP INDEX IF EXISTS p2p.payment_method_description_idx;
DROP INDEX IF EXISTS p2p.payment_method_currency_idx;
DROP INDEX IF EXISTS p2p.old_data_profile_user_id_idx;
DROP INDEX IF EXISTS p2p.notifications_receiver_user_id_idx;
DROP INDEX IF EXISTS p2p.notifications_name;
DROP INDEX IF EXISTS p2p.merges_web_account_user_id_idx;
DROP INDEX IF EXISTS p2p.feedbacks_type_idx;
DROP INDEX IF EXISTS p2p.feedbacks_trade_id_idx;
DROP INDEX IF EXISTS p2p.feedbacks_for_user_id_idx;
DROP INDEX IF EXISTS p2p.dust_aggregation_status_idx;
DROP INDEX IF EXISTS p2p.disputes_seller_id_idx;
DROP INDEX IF EXISTS p2p.disputes_resolution_idx;
DROP INDEX IF EXISTS p2p.disputes_buyer_id_idx;
DROP INDEX IF EXISTS p2p.disputes_admin_idx;
DROP INDEX IF EXISTS p2p.chat_trade_id_idx;
DROP INDEX IF EXISTS p2p.chat_to_idx;
DROP INDEX IF EXISTS p2p.chat_from_admin_idx;
DROP INDEX IF EXISTS p2p.chat_author_id_idx;
DROP INDEX IF EXISTS p2p.buy_ads_mview_cc_code_idx;
DROP INDEX IF EXISTS p2p.buy_ads_mview_aid_idx;
DROP INDEX IF EXISTS p2p.audit_date_idx;
DROP INDEX IF EXISTS p2p.ads_user_id_idx;
DROP INDEX IF EXISTS p2p.ads_status_idx;
DROP INDEX IF EXISTS p2p.ads_rate_value_idx;
DROP INDEX IF EXISTS p2p.ads_paymethod_idx;
DROP INDEX IF EXISTS p2p.ads_cryptocurrency_idx2;
DROP INDEX IF EXISTS p2p.ads_cryptocurrency_idx1;
DROP INDEX IF EXISTS p2p.ads_cryptocurrency_idx;
ALTER TABLE IF EXISTS ONLY public.wallet DROP CONSTRAINT IF EXISTS wallets_pkey;
ALTER TABLE IF EXISTS ONLY public.wallet DROP CONSTRAINT IF EXISTS wallets_address_key;
ALTER TABLE IF EXISTS ONLY public.wallet_address_hist DROP CONSTRAINT IF EXISTS wallet_address_hist_pkey;
ALTER TABLE IF EXISTS ONLY public."user" DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public."user_token_mfa$20211215" DROP CONSTRAINT IF EXISTS "user_token_mfa$20211215_pkey";
ALTER TABLE IF EXISTS ONLY public."user_token_mfa$20211214" DROP CONSTRAINT IF EXISTS "user_token_mfa$20211214_pkey";
ALTER TABLE IF EXISTS ONLY public."user_token_mfa$20211213" DROP CONSTRAINT IF EXISTS "user_token_mfa$20211213_pkey";
ALTER TABLE IF EXISTS ONLY public."user_token_mfa$20211212" DROP CONSTRAINT IF EXISTS "user_token_mfa$20211212_pkey";
ALTER TABLE IF EXISTS ONLY public."user_token_mfa$20211211" DROP CONSTRAINT IF EXISTS "user_token_mfa$20211211_pkey";
ALTER TABLE IF EXISTS ONLY public."user_token_mfa$20211210" DROP CONSTRAINT IF EXISTS "user_token_mfa$20211210_pkey";
ALTER TABLE IF EXISTS ONLY public.user_token_mfa DROP CONSTRAINT IF EXISTS user_tokens_mfa_pkey;
ALTER TABLE IF EXISTS ONLY public."user" DROP CONSTRAINT IF EXISTS user_sys_code_key;
ALTER TABLE IF EXISTS ONLY public.wallet DROP CONSTRAINT IF EXISTS user_id_currency_unique;
ALTER TABLE IF EXISTS ONLY public.user_cryptocurrency_settings DROP CONSTRAINT IF EXISTS user_cryptocurrency_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.user_auth_pub_key DROP CONSTRAINT IF EXISTS user_auth_pub_key_pkey;
ALTER TABLE IF EXISTS ONLY public.user_auth_pub_key DROP CONSTRAINT IF EXISTS user_auth_pub_key_jwk_key;
ALTER TABLE IF EXISTS ONLY public.deposit DROP CONSTRAINT IF EXISTS txid_vout;
ALTER TABLE IF EXISTS ONLY public.deposit DROP CONSTRAINT IF EXISTS transactions_pkey;
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211216" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211216_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211215" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211215_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211214" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211214_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211213" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211213_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211212" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211212_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211211" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211211_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211210" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211210_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211209" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211209_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211208" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211208_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211207" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211207_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211206" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211206_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211205" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211205_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211204" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211204_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211203" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211203_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211202" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211202_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211201" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211201_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211130" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211130_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211129" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211129_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211128" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211128_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211127" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211127_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211126" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211126_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211125" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211125_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211124" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211124_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211123" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211123_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211122" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211122_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211121" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211121_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211120" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211120_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211119" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211119_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211118" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211118_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211117" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211117_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211116" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211116_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211115" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211115_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211114" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211114_pkey";
ALTER TABLE IF EXISTS ONLY public."signed_operation_request$20211113" DROP CONSTRAINT IF EXISTS "signed_operation_request$20211113_pkey";
ALTER TABLE IF EXISTS ONLY public.signed_operation_request DROP CONSTRAINT IF EXISTS signed_operation_request_pkey;
ALTER TABLE IF EXISTS ONLY public.withdrawal DROP CONSTRAINT IF EXISTS payments_wallet_id_address_created_at_key;
ALTER TABLE IF EXISTS ONLY public.withdrawal DROP CONSTRAINT IF EXISTS payments_pkey;
ALTER TABLE IF EXISTS ONLY public.withdrawal_log DROP CONSTRAINT IF EXISTS payment_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.flyway_schema_history DROP CONSTRAINT IF EXISTS flyway_schema_history_pk;
ALTER TABLE IF EXISTS ONLY public.event DROP CONSTRAINT IF EXISTS event_pkey;
ALTER TABLE IF EXISTS ONLY public.cryptocurrency DROP CONSTRAINT IF EXISTS cryptocurrency_pkey;
ALTER TABLE IF EXISTS ONLY public.cryptocurrency DROP CONSTRAINT IF EXISTS cryptocurrency_name_key;
ALTER TABLE IF EXISTS ONLY public.blockchain_tx DROP CONSTRAINT IF EXISTS blockchain_tx_pkey;
ALTER TABLE IF EXISTS ONLY public.blockchain_tx DROP CONSTRAINT IF EXISTS blockchain_tx_cc_code_txid_key;
ALTER TABLE IF EXISTS ONLY public.banned_user DROP CONSTRAINT IF EXISTS banned_users_pkey;
ALTER TABLE IF EXISTS ONLY public.admin_user DROP CONSTRAINT IF EXISTS admin_users_email_key;
ALTER TABLE IF EXISTS ONLY public.admin_user DROP CONSTRAINT IF EXISTS admin_user_pkey;
ALTER TABLE IF EXISTS ONLY public.account_swap_log DROP CONSTRAINT IF EXISTS account_swap_log_pkey;
ALTER TABLE IF EXISTS ONLY public.account DROP CONSTRAINT IF EXISTS account_pkey;
ALTER TABLE IF EXISTS ONLY public.account_kyc_hist DROP CONSTRAINT IF EXISTS account_kyc_hist_pkey;
ALTER TABLE IF EXISTS ONLY public.account_kyc_hist DROP CONSTRAINT IF EXISTS account_kyc_hist_acc_id_at_key;
ALTER TABLE IF EXISTS ONLY p2p.withdraw_voucher DROP CONSTRAINT IF EXISTS withdraw_vouchers_secret_key_ukey;
ALTER TABLE IF EXISTS ONLY p2p.withdraw_voucher_prime_time DROP CONSTRAINT IF EXISTS withdraw_vouchers_prime_time_pkey;
ALTER TABLE IF EXISTS ONLY p2p.withdraw_voucher DROP CONSTRAINT IF EXISTS withdraw_vouchers_pkey;
ALTER TABLE IF EXISTS ONLY p2p."backup$wallet_log" DROP CONSTRAINT IF EXISTS wallet_log_pkey;
ALTER TABLE IF EXISTS ONLY p2p.voucher DROP CONSTRAINT IF EXISTS voucher_secret_key_key;
ALTER TABLE IF EXISTS ONLY p2p.voucher DROP CONSTRAINT IF EXISTS voucher_pkey;
ALTER TABLE IF EXISTS ONLY p2p.utm_statistic DROP CONSTRAINT IF EXISTS utm_statistic_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.user_2fa DROP CONSTRAINT IF EXISTS users_2fa_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.user_2fa DROP CONSTRAINT IF EXISTS users_2fa_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_trust DROP CONSTRAINT IF EXISTS user_trust_user_id_trusted_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.user_trust DROP CONSTRAINT IF EXISTS user_trust_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_settings DROP CONSTRAINT IF EXISTS user_settings_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_rate DROP CONSTRAINT IF EXISTS user_rates_user_id_rate_id_key;
ALTER TABLE IF EXISTS ONLY p2p.user_rate DROP CONSTRAINT IF EXISTS user_rates_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_uniqie;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_public_name_key;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_profile DROP CONSTRAINT IF EXISTS user_profile_generated_name_key;
ALTER TABLE IF EXISTS ONLY p2p.user_note DROP CONSTRAINT IF EXISTS user_notes_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_feature DROP CONSTRAINT IF EXISTS user_features_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_block DROP CONSTRAINT IF EXISTS user_block_user_id_blocked_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.user_block DROP CONSTRAINT IF EXISTS user_block_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_ad_filter DROP CONSTRAINT IF EXISTS user_ad_filter_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.user_action_freeze DROP CONSTRAINT IF EXISTS user_action_freeze_pkey;
ALTER TABLE IF EXISTS ONLY p2p.untrusted_user DROP CONSTRAINT IF EXISTS untrusted_users_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_settings DROP CONSTRAINT IF EXISTS unique_settings;
ALTER TABLE IF EXISTS ONLY p2p.trade DROP CONSTRAINT IF EXISTS trades_pkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic DROP CONSTRAINT IF EXISTS trade_statistic_user_id_cryptocurrency_key;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic DROP CONSTRAINT IF EXISTS trade_statistic_pkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_statistic_log DROP CONSTRAINT IF EXISTS trade_statistic_log_pkey;
ALTER TABLE IF EXISTS ONLY p2p.trade_history DROP CONSTRAINT IF EXISTS trade_history_pkey;
ALTER TABLE IF EXISTS ONLY p2p.stablecoin_trade DROP CONSTRAINT IF EXISTS stablecoin_trade_name_unique;
ALTER TABLE IF EXISTS ONLY p2p.requisite DROP CONSTRAINT IF EXISTS requisites_pkey;
ALTER TABLE IF EXISTS ONLY p2p.referral_links_statistic DROP CONSTRAINT IF EXISTS referral_links_statistic_pkey;
ALTER TABLE IF EXISTS ONLY p2p.referal_bonus DROP CONSTRAINT IF EXISTS referal_bonuses_pkey;
ALTER TABLE IF EXISTS ONLY p2p.rating_change_log DROP CONSTRAINT IF EXISTS rating_change_log_pkey;
ALTER TABLE IF EXISTS ONLY p2p.rate DROP CONSTRAINT IF EXISTS rates_pkey;
ALTER TABLE IF EXISTS ONLY p2p.rate_fiat DROP CONSTRAINT IF EXISTS rates_fiat_pkey;
ALTER TABLE IF EXISTS ONLY p2p.rate DROP CONSTRAINT IF EXISTS rate_url_cryptocurrency_constraint;
ALTER TABLE IF EXISTS ONLY p2p.rate_source DROP CONSTRAINT IF EXISTS rate_source_pkey;
ALTER TABLE IF EXISTS ONLY p2p.user_rate DROP CONSTRAINT IF EXISTS rate_rate_id_constraint;
ALTER TABLE IF EXISTS ONLY p2p.rate_plan_withdraw DROP CONSTRAINT IF EXISTS rate_plan_withdraw_cc_code_act_during_op_amount_excl;
ALTER TABLE IF EXISTS ONLY p2p.payment_list_precalculation DROP CONSTRAINT IF EXISTS payments_list_precalculation_pkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_group DROP CONSTRAINT IF EXISTS payments_group_pkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_group_multilang DROP CONSTRAINT IF EXISTS payments_group_multilang_pkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method DROP CONSTRAINT IF EXISTS payment_method_pkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method_hist DROP CONSTRAINT IF EXISTS payment_method_hist_pkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method_global DROP CONSTRAINT IF EXISTS payment_method_global_pkey;
ALTER TABLE IF EXISTS ONLY p2p.merge DROP CONSTRAINT IF EXISTS p2p_merges_unique;
ALTER TABLE IF EXISTS ONLY p2p.config DROP CONSTRAINT IF EXISTS p2p_config_check_name_unique;
ALTER TABLE IF EXISTS ONLY p2p.old_data_profile DROP CONSTRAINT IF EXISTS old_data_profile_pkey;
ALTER TABLE IF EXISTS ONLY p2p.notification DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY p2p.notification_token DROP CONSTRAINT IF EXISTS notification_token_token_key;
ALTER TABLE IF EXISTS ONLY p2p.notification_token DROP CONSTRAINT IF EXISTS notification_token_device_id_key;
ALTER TABLE IF EXISTS ONLY p2p.notebook DROP CONSTRAINT IF EXISTS notebook_pkey;
ALTER TABLE IF EXISTS ONLY p2p.notebook DROP CONSTRAINT IF EXISTS notebook_address_key;
ALTER TABLE IF EXISTS ONLY p2p.forbidden_public_name DROP CONSTRAINT IF EXISTS name_unique_key;
ALTER TABLE IF EXISTS ONLY p2p.muted_user DROP CONSTRAINT IF EXISTS muted_users_pkey;
ALTER TABLE IF EXISTS ONLY p2p.merge DROP CONSTRAINT IF EXISTS merges_telegram_account_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.merge_token DROP CONSTRAINT IF EXISTS merge_tokens_user_id_key;
ALTER TABLE IF EXISTS ONLY p2p.merge_token DROP CONSTRAINT IF EXISTS merge_tokens_token_key;
ALTER TABLE IF EXISTS ONLY p2p.merge_token DROP CONSTRAINT IF EXISTS merge_tokens_pkey;
ALTER TABLE IF EXISTS ONLY p2p.lang DROP CONSTRAINT IF EXISTS lang_pkey;
ALTER TABLE IF EXISTS ONLY p2p.lang DROP CONSTRAINT IF EXISTS lang_description_key;
ALTER TABLE IF EXISTS ONLY p2p.identity_verification_attempt DROP CONSTRAINT IF EXISTS identity_verification_attempt_pkey;
ALTER TABLE IF EXISTS ONLY p2p.forbidden_public_name DROP CONSTRAINT IF EXISTS forbidden_public_names_pkey;
ALTER TABLE IF EXISTS ONLY p2p.feedback DROP CONSTRAINT IF EXISTS feedbacks_pkey;
ALTER TABLE IF EXISTS ONLY p2p.feature DROP CONSTRAINT IF EXISTS features_pkey;
ALTER TABLE IF EXISTS ONLY p2p.dust_aggregation DROP CONSTRAINT IF EXISTS dust_aggregation_tx_id_key;
ALTER TABLE IF EXISTS ONLY p2p.dust_aggregation DROP CONSTRAINT IF EXISTS dust_aggregation_pkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute DROP CONSTRAINT IF EXISTS disputes_pkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute_video DROP CONSTRAINT IF EXISTS dispute_video_pkey;
ALTER TABLE IF EXISTS ONLY p2p.dispute_video DROP CONSTRAINT IF EXISTS dispute_video_file_name_key;
ALTER TABLE IF EXISTS ONLY p2p.dispute_decision DROP CONSTRAINT IF EXISTS dispute_decisions_pkey;
ALTER TABLE IF EXISTS ONLY p2p.deep_link_action DROP CONSTRAINT IF EXISTS deep_link_action_pkey;
ALTER TABLE IF EXISTS ONLY p2p.payment_method DROP CONSTRAINT IF EXISTS currency_description_constraint;
ALTER TABLE IF EXISTS ONLY p2p.currency DROP CONSTRAINT IF EXISTS currencies_pkey;
ALTER TABLE IF EXISTS ONLY p2p.cryptocurrency_rate_source DROP CONSTRAINT IF EXISTS cryptocurrency_rate_source_pkey;
ALTER TABLE IF EXISTS ONLY p2p.cryptocurrency_rate_source DROP CONSTRAINT IF EXISTS cryptocurrency_rate_source_cryptocurrency_code_priority_key;
ALTER TABLE IF EXISTS ONLY p2p.cryptocurrency_settings DROP CONSTRAINT IF EXISTS cryptocurrency_pkey;
ALTER TABLE IF EXISTS ONLY p2p.config DROP CONSTRAINT IF EXISTS config_pkey;
ALTER TABLE IF EXISTS ONLY p2p.config_maintenance DROP CONSTRAINT IF EXISTS config_maintenance_pkey;
ALTER TABLE IF EXISTS ONLY p2p.report DROP CONSTRAINT IF EXISTS check_unique_report_and_format;
ALTER TABLE IF EXISTS ONLY p2p.chat DROP CONSTRAINT IF EXISTS chat_pkey;
ALTER TABLE IF EXISTS ONLY p2p.cc_settings_backup DROP CONSTRAINT IF EXISTS cc_settings_backup_pkey;
ALTER TABLE IF EXISTS ONLY p2p.audit DROP CONSTRAINT IF EXISTS audit_pkey;
ALTER TABLE IF EXISTS ONLY p2p.ad DROP CONSTRAINT IF EXISTS ads_pkey;
ALTER TABLE IF EXISTS ONLY p2p.admin_file_uploaded DROP CONSTRAINT IF EXISTS admin_file_uploded_pkey;
ALTER TABLE IF EXISTS public.withdrawal_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.withdrawal ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.wallet ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public."user" ALTER COLUMN ref_parent_user_id DROP DEFAULT;
ALTER TABLE IF EXISTS public."user" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.event ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.deposit ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.account_swap_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.withdraw_voucher ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.voucher ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_trust ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_rate ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_profile ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_note ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_block ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_action_freeze ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.user_2fa ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.untrusted_user ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.trade_statistic_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.trade_statistic ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.trade_history ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.trade ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.requisite ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.referral_links_statistic ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.referal_bonus ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.rating_change_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.rate ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.payment_method_global ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.payment_method ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.payment_group_multilang ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.payment_group ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.old_data_profile ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.notification ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.notebook ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.muted_user ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.merge_token ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.feedback ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.dispute_video ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.dispute_decision ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.dispute ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.deep_link_action ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.debt ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.chat ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p."backup$wallet_log" ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.audit ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.admin_file_uploaded ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS p2p.ad ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.wallets_id_seq;
DROP TABLE IF EXISTS public.wallet_address_hist;
DROP VIEW IF EXISTS public.vw_admin;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public."user_token_mfa$20211215";
DROP TABLE IF EXISTS public."user_token_mfa$20211214";
DROP TABLE IF EXISTS public."user_token_mfa$20211213";
DROP TABLE IF EXISTS public."user_token_mfa$20211212";
DROP TABLE IF EXISTS public."user_token_mfa$20211211";
DROP TABLE IF EXISTS public."user_token_mfa$20211210";
DROP TABLE IF EXISTS public.user_token_mfa;
DROP TABLE IF EXISTS public.user_auth_pub_key;
DROP SEQUENCE IF EXISTS public.transactions_id_seq;
DROP TABLE IF EXISTS public."signed_operation_request$20211216";
DROP TABLE IF EXISTS public."signed_operation_request$20211215";
DROP TABLE IF EXISTS public."signed_operation_request$20211214";
DROP TABLE IF EXISTS public."signed_operation_request$20211213";
DROP TABLE IF EXISTS public."signed_operation_request$20211212";
DROP TABLE IF EXISTS public."signed_operation_request$20211211";
DROP TABLE IF EXISTS public."signed_operation_request$20211210";
DROP TABLE IF EXISTS public."signed_operation_request$20211209";
DROP TABLE IF EXISTS public."signed_operation_request$20211208";
DROP TABLE IF EXISTS public."signed_operation_request$20211207";
DROP TABLE IF EXISTS public."signed_operation_request$20211206";
DROP TABLE IF EXISTS public."signed_operation_request$20211205";
DROP TABLE IF EXISTS public."signed_operation_request$20211204";
DROP TABLE IF EXISTS public."signed_operation_request$20211203";
DROP TABLE IF EXISTS public."signed_operation_request$20211202";
DROP TABLE IF EXISTS public."signed_operation_request$20211201";
DROP TABLE IF EXISTS public."signed_operation_request$20211130";
DROP TABLE IF EXISTS public."signed_operation_request$20211129";
DROP TABLE IF EXISTS public."signed_operation_request$20211128";
DROP TABLE IF EXISTS public."signed_operation_request$20211127";
DROP TABLE IF EXISTS public."signed_operation_request$20211126";
DROP TABLE IF EXISTS public."signed_operation_request$20211125";
DROP TABLE IF EXISTS public."signed_operation_request$20211124";
DROP TABLE IF EXISTS public."signed_operation_request$20211123";
DROP TABLE IF EXISTS public."signed_operation_request$20211122";
DROP TABLE IF EXISTS public."signed_operation_request$20211121";
DROP TABLE IF EXISTS public."signed_operation_request$20211120";
DROP TABLE IF EXISTS public."signed_operation_request$20211119";
DROP TABLE IF EXISTS public."signed_operation_request$20211118";
DROP TABLE IF EXISTS public."signed_operation_request$20211117";
DROP TABLE IF EXISTS public."signed_operation_request$20211116";
DROP TABLE IF EXISTS public."signed_operation_request$20211115";
DROP TABLE IF EXISTS public."signed_operation_request$20211114";
DROP TABLE IF EXISTS public."signed_operation_request$20211113";
DROP TABLE IF EXISTS public.signed_operation_request;
DROP SEQUENCE IF EXISTS public.payments_id_seq;
DROP SEQUENCE IF EXISTS public.payment_logs_id_seq;
DROP TABLE IF EXISTS public.withdrawal_log;
DROP VIEW IF EXISTS public.lock_monitor;
DROP TABLE IF EXISTS public.flyway_schema_history;
DROP SEQUENCE IF EXISTS public.event_id_seq;
DROP TABLE IF EXISTS public.event;
DROP TABLE IF EXISTS public.banned_user;
DROP TABLE IF EXISTS public.admin_user;
DROP SEQUENCE IF EXISTS public.account_swap_log_id_seq;
DROP TABLE IF EXISTS public.account_swap_log;
DROP TABLE IF EXISTS public.account_kyc_hist;
DROP TABLE IF EXISTS public.account;
DROP SEQUENCE IF EXISTS p2p.withdraw_vouchers_id_seq;
DROP TABLE IF EXISTS p2p.withdraw_voucher_prime_time;
DROP TABLE IF EXISTS p2p.withdraw_voucher;
DROP SEQUENCE IF EXISTS p2p.wallet_log_id_seq;
DROP TABLE IF EXISTS p2p.wallet_log;
DROP VIEW IF EXISTS p2p.vw_user_voucher;
DROP VIEW IF EXISTS p2p.vw_user_notification_alarm_mode;
DROP VIEW IF EXISTS p2p.vw_inappropriate_ads;
DROP VIEW IF EXISTS p2p.vw_disputes_list;
DROP VIEW IF EXISTS p2p.vw_audit_watchdog;
DROP VIEW IF EXISTS p2p.vw_audit_source;
DROP TABLE IF EXISTS public.withdrawal;
DROP TABLE IF EXISTS public."user";
DROP TABLE IF EXISTS public.deposit;
DROP TABLE IF EXISTS public.blockchain_tx;
DROP VIEW IF EXISTS p2p.vw_audit_latest;
DROP VIEW IF EXISTS p2p.vw_audit;
DROP SEQUENCE IF EXISTS p2p.voucher_id_seq;
DROP TABLE IF EXISTS p2p.voucher;
DROP TABLE IF EXISTS p2p.utm_statistic;
DROP SEQUENCE IF EXISTS p2p.users_2fa_id_seq;
DROP SEQUENCE IF EXISTS p2p.user_trust_id_seq;
DROP TABLE IF EXISTS p2p.user_trust;
DROP SEQUENCE IF EXISTS p2p.user_settings_id_seq;
DROP TABLE IF EXISTS p2p.user_settings;
DROP SEQUENCE IF EXISTS p2p.user_rates_id_seq;
DROP TABLE IF EXISTS p2p.user_rate;
DROP SEQUENCE IF EXISTS p2p.user_profile_id_seq;
DROP SEQUENCE IF EXISTS p2p.user_notes_id_seq;
DROP TABLE IF EXISTS p2p.user_note;
DROP TABLE IF EXISTS p2p.user_feature;
DROP SEQUENCE IF EXISTS p2p.user_block_id_seq;
DROP TABLE IF EXISTS p2p.user_block;
DROP TABLE IF EXISTS p2p.user_ad_filter;
DROP SEQUENCE IF EXISTS p2p.user_actions_freeze_id_seq;
DROP TABLE IF EXISTS p2p.user_action_freeze;
DROP TABLE IF EXISTS p2p.user_2fa;
DROP SEQUENCE IF EXISTS p2p.untrusted_users_id_seq;
DROP TABLE IF EXISTS p2p.untrusted_user;
DROP SEQUENCE IF EXISTS p2p.trades_id_seq;
DROP SEQUENCE IF EXISTS p2p.trade_statistic_log_id_seq;
DROP TABLE IF EXISTS p2p.trade_statistic_log;
DROP SEQUENCE IF EXISTS p2p.trade_statistic_id_seq;
DROP SEQUENCE IF EXISTS p2p.trade_history_id_seq;
DROP TABLE IF EXISTS p2p.trade_history;
DROP TABLE IF EXISTS p2p.trade;
DROP TABLE IF EXISTS p2p.stablecoin_trade;
DROP VIEW IF EXISTS p2p.sell_ads_view;
DROP MATERIALIZED VIEW IF EXISTS p2p.sell_ads_mview;
DROP SEQUENCE IF EXISTS p2p.requisites_id_seq;
DROP TABLE IF EXISTS p2p.requisite;
DROP TABLE IF EXISTS p2p.report;
DROP SEQUENCE IF EXISTS p2p.referral_links_statistic_id_seq;
DROP TABLE IF EXISTS p2p.referral_links_statistic;
DROP SEQUENCE IF EXISTS p2p.referal_bonuses_id_seq;
DROP TABLE IF EXISTS p2p.referal_bonus;
DROP SEQUENCE IF EXISTS p2p.rating_change_log_id_seq;
DROP TABLE IF EXISTS p2p.rating_change_log;
DROP SEQUENCE IF EXISTS p2p.rates_id_seq;
DROP TABLE IF EXISTS p2p.rate_source;
DROP TABLE IF EXISTS p2p.rate_plan_withdraw;
DROP TABLE IF EXISTS p2p.rate_fiat;
DROP SEQUENCE IF EXISTS p2p.payments_group_multilang_id_seq;
DROP SEQUENCE IF EXISTS p2p.payments_group_id_seq;
DROP SEQUENCE IF EXISTS p2p.payment_method_id_seq;
DROP TABLE IF EXISTS p2p.payment_method_hist;
DROP SEQUENCE IF EXISTS p2p.payment_method_global_id_seq;
DROP TABLE IF EXISTS p2p.payment_method_global;
DROP TABLE IF EXISTS p2p.payment_list_precalculation;
DROP TABLE IF EXISTS p2p.payment_group_multilang;
DROP TABLE IF EXISTS p2p.payment_group;
DROP SEQUENCE IF EXISTS p2p.old_data_profile_id_seq;
DROP TABLE IF EXISTS p2p.old_data_profile;
DROP SEQUENCE IF EXISTS p2p.notifications_id_seq;
DROP TABLE IF EXISTS p2p.notification_token;
DROP TABLE IF EXISTS p2p.notification;
DROP SEQUENCE IF EXISTS p2p.notebook_id_seq;
DROP TABLE IF EXISTS p2p.notebook;
DROP SEQUENCE IF EXISTS p2p.muted_users_id_seq;
DROP TABLE IF EXISTS p2p.muted_user;
DROP SEQUENCE IF EXISTS p2p.merge_tokens_id_seq;
DROP TABLE IF EXISTS p2p.merge_token;
DROP TABLE IF EXISTS p2p.merge;
DROP TABLE IF EXISTS p2p.lang;
DROP TABLE IF EXISTS p2p.identity_verification_attempt;
DROP TABLE IF EXISTS p2p.forbidden_public_name;
DROP SEQUENCE IF EXISTS p2p.feedbacks_id_seq;
DROP TABLE IF EXISTS p2p.feedback;
DROP TABLE IF EXISTS p2p.feature;
DROP TABLE IF EXISTS p2p.dust_aggregation;
DROP SEQUENCE IF EXISTS p2p.disputes_id_seq;
DROP SEQUENCE IF EXISTS p2p.dispute_video_id_seq;
DROP TABLE IF EXISTS p2p.dispute_video;
DROP SEQUENCE IF EXISTS p2p.dispute_decisions_id_seq;
DROP TABLE IF EXISTS p2p.dispute_decision;
DROP TABLE IF EXISTS p2p.dispute;
DROP TABLE IF EXISTS p2p.deeplink_utm;
DROP TABLE IF EXISTS p2p.deep_link_referal_action;
DROP SEQUENCE IF EXISTS p2p.deep_link_action_id_seq;
DROP TABLE IF EXISTS p2p.deep_link_action;
DROP SEQUENCE IF EXISTS p2p.debts_id_seq;
DROP TABLE IF EXISTS p2p.debt;
DROP TABLE IF EXISTS p2p.currency;
DROP TABLE IF EXISTS p2p.cryptocurrency_rate_source;
DROP TABLE IF EXISTS p2p.config_maintenance;
DROP TABLE IF EXISTS p2p.config;
DROP SEQUENCE IF EXISTS p2p.chat_id_seq;
DROP TABLE IF EXISTS p2p.chat;
DROP TABLE IF EXISTS p2p.cc_settings_backup;
DROP VIEW IF EXISTS p2p.buy_ads_view;
DROP MATERIALIZED VIEW IF EXISTS p2p.buy_ads_mview;
DROP TABLE IF EXISTS public.user_cryptocurrency_settings;
DROP TABLE IF EXISTS p2p.user_profile;
DROP TABLE IF EXISTS p2p.trade_statistic;
DROP TABLE IF EXISTS p2p.cryptocurrency_settings;
DROP TABLE IF EXISTS p2p."backup$wallet_log";
DROP SEQUENCE IF EXISTS p2p.audit_id_seq;
DROP TABLE IF EXISTS p2p.audit;
DROP SEQUENCE IF EXISTS p2p.ads_id_seq;
DROP SEQUENCE IF EXISTS p2p.admin_file_uploded_id_seq;
DROP TABLE IF EXISTS p2p.admin_file_uploaded;
DROP TABLE IF EXISTS public.cryptocurrency;
DROP TABLE IF EXISTS p2p.rate;
DROP AGGREGATE IF EXISTS public.last(anyelement);
DROP AGGREGATE IF EXISTS public.first(anyelement);
DROP FUNCTION IF EXISTS public.release_banned_balances();
DROP FUNCTION IF EXISTS public.register_dispute_video(p_admin_code public.text_code, p_dispute_id integer, p_file_name character varying, OUT r_local_file_name text);
DROP FUNCTION IF EXISTS public.null_txids_for_internal_txes();
DROP FUNCTION IF EXISTS public.move_money(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying);
DROP FUNCTION IF EXISTS public.move_money(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, platform character varying);
DROP FUNCTION IF EXISTS public.mark_as_sent_and_release_hold(payment_id integer);
DROP FUNCTION IF EXISTS public.mark_as_sent_and_release();
DROP FUNCTION IF EXISTS public.maintain_partitions_for_dates(p_retain_days integer, p_in_advance_days integer, p_table text);
DROP FUNCTION IF EXISTS public.last_agg(anyelement, anyelement);
DROP FUNCTION IF EXISTS public.hold_to_balance(payment_id integer);
DROP FUNCTION IF EXISTS public.get_partitions_for_date(p_table character varying);
DROP FUNCTION IF EXISTS public.first_agg(anyelement, anyelement);
DROP FUNCTION IF EXISTS public.drop_partition_for_date(p_date date, p_table character varying);
DROP FUNCTION IF EXISTS public.create_partition_for_date(p_date date, p_table character varying);
DROP FUNCTION IF EXISTS public.base58_encode(num integer);
DROP FUNCTION IF EXISTS public.array_sort_unique(anyarray);
DROP FUNCTION IF EXISTS public.add_fake_balance(userid integer, cc integer, amount bigint);
DROP FUNCTION IF EXISTS p2p.to_seconds(t text);
DROP FUNCTION IF EXISTS p2p.store_audit_json();
DROP FUNCTION IF EXISTS p2p.set_merged_after_merge();
DROP FUNCTION IF EXISTS p2p.rep_wallet_history_103(p_user_id integer);
DROP FUNCTION IF EXISTS p2p.rep_vouchers_102(p_user_id integer);
DROP FUNCTION IF EXISTS p2p.rep_trade_history_101(p_user_id integer);
DROP FUNCTION IF EXISTS p2p.rep_referral_104(rep_user_id integer);
DROP FUNCTION IF EXISTS p2p.rep_finance_movement_100(p_user_id integer);
DROP FUNCTION IF EXISTS p2p.remote_rate_value(p_user_id integer, p_currency character varying, p_cc_code public.cryptocurrency_code);
DROP FUNCTION IF EXISTS p2p.release_debts();
DROP FUNCTION IF EXISTS p2p.release_debt(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying);
DROP FUNCTION IF EXISTS p2p.release_debt(user_from integer, user_to integer, cc integer, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying);
DROP FUNCTION IF EXISTS p2p.release_banned_balances(up_to_date timestamp without time zone);
DROP FUNCTION IF EXISTS p2p.recreate_payment(payment_id integer);
DROP FUNCTION IF EXISTS p2p.move_user(from_id integer, to_id integer);
DROP FUNCTION IF EXISTS p2p.move_money(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying);
DROP FUNCTION IF EXISTS p2p.move_money(user_from integer, user_to integer, cc integer, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying);
DROP FUNCTION IF EXISTS p2p.move_money(user_from integer, user_to integer, cc integer, amount bigint, cause text);
DROP FUNCTION IF EXISTS p2p.money_to_hold(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying);
DROP FUNCTION IF EXISTS p2p.hold_to_null(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying);
DROP FUNCTION IF EXISTS p2p.hold_to_null(user_from integer, currency integer, amount bigint, cause text);
DROP FUNCTION IF EXISTS p2p.hold_to_balance(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying);
DROP FUNCTION IF EXISTS p2p.heal_vouchers_after_merge();
DROP FUNCTION IF EXISTS p2p.heal_reg_after_merge();
DROP FUNCTION IF EXISTS p2p.heal_old_data_after_merge();
DROP FUNCTION IF EXISTS p2p.handle_features_adding(codes character varying[]);
DROP FUNCTION IF EXISTS p2p.global_paymethods_update();
DROP FUNCTION IF EXISTS p2p.global_paymethods_insert();
DROP FUNCTION IF EXISTS p2p.global_paymethods_delete();
DROP FUNCTION IF EXISTS p2p.get_withdrawal_fee_range(p_cc_code character varying);
DROP FUNCTION IF EXISTS p2p.get_withdrawal_fee_and_limits(p_cc_code character varying, p_balance numeric, p_amount_to_withdraw numeric, OUT p_min_fee_amount numeric, OUT p_max_fee_amount numeric, OUT p_fee_amount numeric, OUT p_max_withdrawal_amount numeric);
DROP FUNCTION IF EXISTS p2p.get_user_trading_stat_in_fiat_equiv(p_user_id integer, p_currency character varying);
DROP FUNCTION IF EXISTS p2p.disable_ads();
DROP FUNCTION IF EXISTS p2p.create_rate_plan_withdraw_item(p_cc_code character varying, p_fee_amount numeric, p_amount_from numeric, p_amount_till numeric, p_amount_bounds character varying, p_act_from timestamp with time zone, p_act_till timestamp with time zone, p_act_bounds character varying);
DROP FUNCTION IF EXISTS p2p.check_two_user_rates();
DROP FUNCTION IF EXISTS p2p.check_two_trades();
DROP FUNCTION IF EXISTS p2p.cancel_payment(pay_id integer, cause text);
DROP FUNCTION IF EXISTS p2p.base58_encode(num integer);
DROP FUNCTION IF EXISTS p2p.balance_to_null(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying);
DROP FUNCTION IF EXISTS p2p.balance_to_hold(wallet_from integer, wallet_to integer, amount bigint, cause text);
DROP FUNCTION IF EXISTS p2p.ads_filter(ad p2p.ad, wallet public.wallet, trade_comission_percent real);
DROP TABLE IF EXISTS public.wallet;
DROP TABLE IF EXISTS p2p.ad;
DROP FUNCTION IF EXISTS p2p.adm_create_fiat_currency(p_symbol character varying, p_name character varying, p_sign character varying, p_free_trade_enabled boolean, p_max_commission_sum numeric);
DROP TABLE IF EXISTS p2p.payment_method;
DROP FUNCTION IF EXISTS p2p.add_rating_after_merge();
DROP TYPE IF EXISTS public.withdrawal_status;
DROP TYPE IF EXISTS public.wallet_address_change_reason;
DROP DOMAIN IF EXISTS public.text_code;
DROP TYPE IF EXISTS public.oauth_aud;
DROP TYPE IF EXISTS public.kyc_status;
DROP TYPE IF EXISTS public.kyc_provider;
DROP TYPE IF EXISTS public.event_type;
DROP TYPE IF EXISTS public.entity;
DROP TYPE IF EXISTS public.deposit_status;
DROP DOMAIN IF EXISTS public.cryptocurrency_code;
DROP DOMAIN IF EXISTS public.cryptocurrency_amount;
DROP TYPE IF EXISTS public.blockchain_tx_status;
DROP TYPE IF EXISTS public.ban_action;
DROP TYPE IF EXISTS public.admin_role;
DROP TYPE IF EXISTS p2p.voucher_status_type;
DROP TYPE IF EXISTS p2p.user_trade_status;
DROP TYPE IF EXISTS p2p.trade_type;
DROP TYPE IF EXISTS p2p.trade_status_advanced;
DROP TYPE IF EXISTS p2p.trade_state;
DROP TYPE IF EXISTS p2p.referral_type;
DROP TYPE IF EXISTS p2p.ref_type;
DROP TYPE IF EXISTS p2p.pair_status;
DROP TYPE IF EXISTS p2p.operation_type;
DROP TYPE IF EXISTS p2p.operation_source;
DROP TYPE IF EXISTS p2p.feedback_type;
DROP TYPE IF EXISTS p2p.dust_category;
DROP TYPE IF EXISTS p2p.dust_aggregation_status;
DROP TYPE IF EXISTS p2p.dispute_decisions_type;
DROP TYPE IF EXISTS p2p.deep_link_action_type;
DROP TYPE IF EXISTS p2p.audit_rec;
DROP TYPE IF EXISTS p2p.advert_creating_block_reason;
DROP TYPE IF EXISTS p2p.ads_type;
DROP TYPE IF EXISTS p2p.ads_status;
DROP SCHEMA IF EXISTS public;
DROP SCHEMA IF EXISTS p2p;
--
-- Name: p2p; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA p2p;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;
	CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public; 
	CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public; 
	


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: ads_status; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.ads_status AS ENUM (
    'active',
    'pause',
    'paused_automatically',
    'banned'
);


--
-- Name: ads_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.ads_type AS ENUM (
    'purchase',
    'selling'
);


--
-- Name: advert_creating_block_reason; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.advert_creating_block_reason AS ENUM (
    'not-enough-trades',
    'blocked'
);


--
-- Name: audit_rec; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.audit_rec AS (
	"totalIn" numeric,
	"totalOut" numeric,
	"totalAudit" numeric,
	"totalWallets" numeric,
	"coldWalletAdjust" numeric,
	"totalBalancesFree" numeric,
	"systemWalletBalance" numeric,
	"totalBalancesHolded" numeric,
	"realColdWalletBalance" numeric,
	"systemHotWalletBalance" numeric,
	"totalWalletsColdAndHot" numeric,
	"hotWalletUnconfirmedBalance" numeric,
	"pendingPayments" numeric,
	"totalNetworkFee" numeric
);


--
-- Name: deep_link_action_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.deep_link_action_type AS ENUM (
    'referal',
    'cheque'
);


--
-- Name: dispute_decisions_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.dispute_decisions_type AS ENUM (
    'approve',
    'cancel'
);


--
-- Name: dust_aggregation_status; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.dust_aggregation_status AS ENUM (
    'dust_collected',
    'fee_settled'
);


--
-- Name: dust_category; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.dust_category AS ENUM (
    'bolsh_c',
    'bolsh_b',
    'bolsh_a',
    'sredne_b',
    'sredne_a',
    'dust_c',
    'dust_b',
    'dust_a'
);


--
-- Name: feedback_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.feedback_type AS ENUM (
    'thumb-up',
    'relieved',
    'weary',
    'rage',
    'hankey'
);


--
-- Name: operation_source; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.operation_source AS ENUM (
    'trade',
    'order',
    'referral',
    'voucher',
    'direct',
    'commission',
    'deposit',
    'withdraw',
    'tips',
    'debt',
    'beton',
    'invoice',
    'merchantPay',
    'cancel_withdraw',
    'deposit_seizure'
);


--
-- Name: operation_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.operation_type AS ENUM (
    'hold',
    'unhold',
    'incoming',
    'outgoing',
    'deposit',
    'withdraw'
);


--
-- Name: pair_status; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.pair_status AS ENUM (
    'active',
    'frozen'
);


--
-- Name: ref_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.ref_type AS ENUM (
    'SHORT',
    'LONG',
    'NUMBERS',
    'LETTERS'
);


--
-- Name: referral_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.referral_type AS ENUM (
    'independent',
    'ref_link_bot',
    'ref_link_web',
    'ad_bot',
    'ad_web',
    'voucher_bot',
    'voucher_web'
);


--
-- Name: trade_state; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.trade_state AS ENUM (
    'trade-created',
    'confirm-trade',
    'payment',
    'confirm-payment',
    'dispute',
    'cancel',
    'completed'
);


--
-- Name: trade_status_advanced; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.trade_status_advanced AS ENUM (
    'cancel-created-user',
    'cancel-created-auto',
    'cancel-confirmed-user',
    'cancel-confirmed-auto',
    'cancel-payment-auto',
    'cancel-dispute-admin',
    'cancel-reopen-admin',
    'dispute-reopen',
    'confirm-payment-dispute-user',
    'confirm-payment-dispute-admin',
    'confirm-payment-reopen-user',
    'confirm-payment-reopen-admin'
);


--
-- Name: trade_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.trade_type AS ENUM (
    'ONLINE_BUY',
    'ONLINE_SELL',
    'LOCAL_SELL',
    'LOCAL_BUY'
);


--
-- Name: user_trade_status; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.user_trade_status AS ENUM (
    'active',
    'pause'
);


--
-- Name: voucher_status_type; Type: TYPE; Schema: p2p; Owner: -
--

CREATE TYPE p2p.voucher_status_type AS ENUM (
    'active',
    'cashed'
);


--
-- Name: admin_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.admin_role AS ENUM (
    'superuser',
    'finadmin',
    'admin',
    'operator',
    'user'
);


--
-- Name: ban_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ban_action AS ENUM (
    'ban',
    'unban'
);


--
-- Name: blockchain_tx_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.blockchain_tx_status AS ENUM (
    'initial',
    'pending',
    'confirmed'
);


--
-- Name: cryptocurrency_amount; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.cryptocurrency_amount AS numeric(60,8)
	CONSTRAINT cryptocurrency_amount_check CHECK ((VALUE <> 'NaN'::numeric));


--
-- Name: cryptocurrency_code; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.cryptocurrency_code AS character varying(4)
	CONSTRAINT cryptocurrency_code_check1 CHECK ((length((VALUE)::text) >= 3));


--
-- Name: deposit_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.deposit_status AS ENUM (
    'pending',
    'aml-check',
    'aml-seizure',
    'dust-seizure',
    'success'
);


--
-- Name: entity; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entity AS ENUM (
    'user',
    'wallet',
    'profile',
    'order',
    'trade',
    'advert'
);


--
-- Name: event_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.event_type AS ENUM (
    'created',
    'updated',
    'deleted'
);


--
-- Name: kyc_provider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.kyc_provider AS ENUM (
    'LEGACY',
    'SUMSUB'
);


--
-- Name: kyc_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.kyc_status AS ENUM (
    'NONE',
    'APPROVED',
    'REJECTED',
    'BAN'
);


--
-- Name: oauth_aud; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oauth_aud AS ENUM (
    'usr',
    'mob'
);


--
-- Name: text_code; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.text_code AS character varying(63)
	CONSTRAINT text_code_check CHECK ((length((VALUE)::text) > 0));


--
-- Name: wallet_address_change_reason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.wallet_address_change_reason AS ENUM (
    'merge',
    'admin_reset',
    'migration'
);


--
-- Name: withdrawal_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.withdrawal_status AS ENUM (
    'pending',
    'processed',
    'cancelled',
    'in_progress',
    'failed',
    'cancelled_by_admin'
);


--
-- Name: add_rating_after_merge(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.add_rating_after_merge() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  tgid character varying(256);
BEGIN

FOR tgid IN SELECT regexp_replace(telegram_id, 'deleted_{?(\d+)}?', '\1') as tgid
            FROM public.users
            WHERE telegram_id LIKE 'deleted_%' AND NOT telegram_id LIKE '%todel' LOOP

  UPDATE p2p.user_profile
  SET rating = rating + 10
  WHERE user_id=(SELECT id FROM public.users WHERE telegram_id=tgid);

  RAISE NOTICE 'Add 10 rating for tgid=%', tgid;

END LOOP;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: payment_method; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.payment_method (
    id integer NOT NULL,
    currency character varying(8) NOT NULL,
    description character varying(2048) NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    payment_group integer DEFAULT 1 NOT NULL,
    i18n jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: adm_create_fiat_currency(character varying, character varying, character varying, boolean, numeric); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.adm_create_fiat_currency(p_symbol character varying, p_name character varying, p_sign character varying, p_free_trade_enabled boolean DEFAULT false, p_max_commission_sum numeric DEFAULT 200000) RETURNS SETOF p2p.payment_method
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'p2p'
    AS $$
insert into currency(symbol, name, sign, free_trade_enabled, max_commission_sum)
values (p_symbol, p_name, p_sign, p_free_trade_enabled, p_max_commission_sum);

with global_paymethod as (
    select label, payments_group
    from payment_method_global
)
insert
into payment_method(currency, description, weight, payment_group, i18n)
select p_symbol,
       global_paymethod.label,
       0,
       global_paymethod.payments_group,
       json_build_object('ru', global_paymethod.label)
from global_paymethod
returning *;

$$;


--
-- Name: ad; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.ad (
    id integer NOT NULL,
    user_id integer NOT NULL,
    type p2p.ads_type NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    paymethod integer NOT NULL,
    rate_value numeric NOT NULL,
    min_amount numeric NOT NULL,
    max_amount numeric NOT NULL,
    terms character varying(3000),
    details character varying(1500),
    status p2p.ads_status NOT NULL,
    ratepercent numeric,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    min_partner_trades_amount numeric,
    max_limit_for_new_trader numeric,
    verified_only boolean DEFAULT false,
    liquidity_limit boolean,
    CONSTRAINT check_max CHECK ((max_amount > (0)::numeric)),
    CONSTRAINT check_min CHECK ((min_amount > (0)::numeric)),
    CONSTRAINT max_amount_check CHECK ((max_amount > 0.0001)),
    CONSTRAINT min_amount_check CHECK ((min_amount > 0.0001))
)
WITH (fillfactor='85', autovacuum_enabled='on', autovacuum_vacuum_cost_delay='20');


--
-- Name: wallet; Type: TABLE; Schema: public; Owner: -
--

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


--
-- Name: ads_filter(p2p.ad, public.wallet, real); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.ads_filter(ad p2p.ad, wallet public.wallet, trade_comission_percent real) RETURNS integer
    LANGUAGE plpgsql
    AS $$        DECLARE res int;
        DEClARE remoteRateValue numeric;
        BEGIN
                -- raise notice 'ads: %', ad.id;

                -- find rate. TODO: add user rates
                SELECT "value" INTO remoteRateValue
                FROM p2p.rate r
                JOIN p2p.payment_method p on p.id = ad.paymethod
                WHERE r.cc_code = ad.cc_code
                AND r.currency_symbol = p.currency
                AND r.default_rate = TRUE LIMIT 1;

                -- filter 20% from top and button from remote rate
                IF ad.rate_value > remoteRateValue + remoteRateValue * 0.5::numeric OR ad.rate_value < remoteRateValue - remoteRateValue * 0.5::numeric
                THEN
                  RETURN 3;
                END IF;

                IF ad.type = 'purchase'::p2p.ads_type
                THEN
                  RETURN 1;
                END IF;

                IF wallet IS NULL
                THEN
                  RETURN 0;
                END IF;

                -- filter via balance
                IF wallet.balance < ad.min_amount / ad.rate_value + ad.min_amount / ad.rate_value * trade_comission_percent::numeric * 1::numeric
                THEN
                  RETURN 2;
                END IF;

                RETURN 1;
        END;
$$;


--
-- Name: balance_to_hold(integer, integer, bigint, text); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.balance_to_hold(wallet_from integer, wallet_to integer, amount bigint, cause text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
BEGIN
  EXECUTE 'UPDATE public.wallets
           SET balance = balance - $2
           WHERE id = $1'
  USING wallet_from, amount;

  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
  VALUES (wallet_from,
          format('Withdraw manually %s satoshi to wallet %s hold', amount, wallet_to),
          (SELECT balance FROM public.wallets WHERE id = wallet_from),
          (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
          cause);

  EXECUTE 'UPDATE public.wallets
           SET hold_balance = hold_balance + $2
           WHERE id = $1'
  USING wallet_to, amount;

  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
  VALUES (wallet_to,
          format('Add manually %s satoshi from wallet %s', amount, wallet_from),
          (SELECT balance FROM public.wallets WHERE id = wallet_to),
          (SELECT hold_balance FROM public.wallets WHERE id = wallet_to),
          cause);
END;
$_$;


--
-- Name: balance_to_null(integer, public.cryptocurrency_code, numeric, text, p2p.operation_source, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.balance_to_null(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet integer;

BEGIN
  SELECT id
  FROM public.wallets
  WHERE user_id = userid
    AND cc_code = cc
  INTO wallet;

  UPDATE public.wallets
  SET balance = balance - amount
  WHERE id = wallet;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet,
    (SELECT balance FROM public.wallets WHERE id = wallet),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet),
    cause,
    amount,
    cc,
    source_type,
    'outgoing',
    platform
  );

END;
$$;


--
-- Name: base58_encode(integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.base58_encode(num integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

DECLARE
  alphabet   VARCHAR(255);
  base_count INT DEFAULT 0;
  encoded    VARCHAR(255);
  divisor    DECIMAL(10, 4);
  mod        INT DEFAULT 0;

BEGIN
  alphabet := '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  base_count := char_length(alphabet);
  encoded := '';

  WHILE num >= base_count LOOP
    divisor := num / base_count;
    mod := (num - (base_count * trunc(divisor, 0)));
    encoded := concat(substring(alphabet FROM mod + 1 FOR 1), encoded);
    num := trunc(divisor, 0);
  END LOOP;

  encoded = concat(substring(alphabet FROM num + 1 FOR 1), encoded);

  RETURN (encoded);

END; $$;


--
-- Name: cancel_payment(integer, text); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.cancel_payment(pay_id integer, cause text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  payment RECORD;
  system_wallet_id integer;
  voucher_id integer;
  cc_code character varying(4);
BEGIN
  SELECT wallet_id, currency, amount, fee
  INTO payment
  FROM public.payments
  WHERE id = pay_id;

  SELECT code
  FROM public.cryptocurrency
  WHERE int_code = payment.currency
  INTO cc_code;

  SELECT w.id
  INTO system_wallet_id
  FROM public.wallets w
  JOIN public.users u
  ON u.id = w.user_id
  WHERE u.username = 'system'
  AND w.currency = payment.currency;

  UPDATE public.wallets
  SET balance = balance + payment.amount + payment.fee
  WHERE id = payment.wallet_id;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    payment.wallet_id,
    (SELECT balance FROM public.wallets WHERE id = payment.wallet_id),
    (SELECT hold_balance FROM public.wallets WHERE id = payment.wallet_id),
    cause,
    ((payment.amount + payment.fee) / 100000000::numeric)::numeric(1000, 10),
    cc_code,
    'withdraw',
    pay_id,
    'incoming',
    'wallet'
  );

  SELECT id
  INTO voucher_id
  FROM p2p.withdraw_vouchers wv
  WHERE wv.payment_id = pay_id;

  IF voucher_id IS NOT NULL THEN
    UPDATE p2p.withdraw_vouchers SET payment_id = NULL, used_at = NULL WHERE id = voucher_id;
  ELSE
    UPDATE public.wallets
    SET balance = balance - payment.fee
    WHERE id = system_wallet_id;

    INSERT INTO p2p.wallet_log(
      wallet_id,
      balance_at_the_moment,
      hold_balance_at_moment,
      cause,
      amount,
      currency,
      source_type,
      source_id,
      operation_type,
      platform
    ) VALUES (
      system_wallet_id,
      (SELECT balance FROM public.wallets WHERE id = system_wallet_id),
      (SELECT hold_balance FROM public.wallets WHERE id = system_wallet_id),
      cause,
      ((payment.amount + payment.fee) / 100000000::numeric)::numeric(1000, 10),
      cc_code,
      'withdraw',
      pay_id,
      'outgoing',
      'wallet'
    );
  END IF;

  DELETE FROM public.txs
  WHERE payments_id = pay_id;

  DELETE FROM public.payments
  WHERE id = pay_id;
END;
$$;


--
-- Name: check_two_trades(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.check_two_trades() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DEClARE result int;
BEGIN

    select into result count(*)
    FROM p2p.trade
    WHERE p2p.trade.status = 'trade-created'
      AND p2p.trade.amount = NEW.amount
      AND p2p.trade.crypto_seller = NEW.crypto_seller
      AND p2p.trade.crypto_buyer = NEW.crypto_buyer
      AND p2p.trade.cc_code = NEW.cc_code
      AND p2p.trade.created_at + INTERVAL '1 minute' > now();
    IF (result > 1) THEN
        RAISE 'Wait 5 minutes for insert';
    END IF;
    return NEW;
END
$$;


--
-- Name: check_two_user_rates(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.check_two_user_rates() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DEClARE result boolean;
BEGIN

                select into result exists (select 1
                FROM p2p.user_rate
                WHERE p2p.user_rate.user_id = NEW.user_id
                AND p2p.user_rate.rate_id = NEW.rate_id);
                IF (result) THEN
                    RAISE 'User rates already exists';
                END IF;
                return NEW;

END
$$;


--
-- Name: create_rate_plan_withdraw_item(character varying, numeric, numeric, numeric, character varying, timestamp with time zone, timestamp with time zone, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.create_rate_plan_withdraw_item(p_cc_code character varying, p_fee_amount numeric, p_amount_from numeric, p_amount_till numeric, p_amount_bounds character varying DEFAULT '[)'::character varying, p_act_from timestamp with time zone DEFAULT '2021-01-01 00:00:00+00'::timestamp with time zone, p_act_till timestamp with time zone DEFAULT 'infinity'::timestamp with time zone, p_act_bounds character varying DEFAULT '[)'::character varying) RETURNS void
    LANGUAGE sql
    SET search_path TO 'p2p'
    AS $$
insert into rate_plan_withdraw(cc_code, act_during, op_amount, fee_amount)
values (p_cc_code,
        tsrange(p_act_from::timestamp, p_act_till::timestamp, p_act_bounds),
        numrange(p_amount_from, p_amount_till, p_amount_bounds),
        p_fee_amount)
$$;


--
-- Name: disable_ads(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.disable_ads() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  c character varying(5);
  cc character varying(256);
  cryptocurrencies varchar(256)[] := array['BTC'];
BEGIN

FOR c IN SELECT symbol FROM p2p.currencies LOOP
  FOREACH cc IN ARRAY cryptocurrencies LOOP

  UPDATE p2p.ads SET status='pause'
  WHERE cryptocurrency=cc
    AND paymethod IN (SELECT id FROM p2p.payment_method WHERE currency=c)
    AND (rate_value > (SELECT value FROM p2p.rates r WHERE r.default_rate=true AND r.cryptocurrency_code=cc AND r.currency_symbol=c) * 1.2
      OR rate_value < (SELECT value FROM p2p.rates r WHERE r.default_rate=true AND r.cryptocurrency_code=cc AND r.currency_symbol=c) * 0.8);

  END LOOP;
END LOOP;

END;
$$;


--
-- Name: get_user_trading_stat_in_fiat_equiv(integer, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.get_user_trading_stat_in_fiat_equiv(p_user_id integer, p_currency character varying) RETURNS TABLE(cc_code character varying, sold numeric, bought numeric, deposit numeric, withdrawal numeric, saved_by_free_trade numeric, saved_by_vouchers numeric, total_deals integer, success_deals integer)
    LANGUAGE sql
    SET search_path TO 'p2p', 'public'
    AS $$
select cc_code,
       sold * fiat.value                sold,
       bought * fiat.value              bought,
       deposit * fiat.value             deposit,
       withdrawal * fiat.value          withdrawal,
       saved_by_free_trade * fiat.value saved_by_free_trade,
       saved_by_wvouchers * fiat.value  saved_by_vouchers,
       total_count                      total_deals,
       success_deals                    success_deals
from trade_statistic ts
         join cryptocurrency_settings cs
              on ts.cc_code = cs.code
                  and not cs.is_delisted
         left join lateral (select value
                            from rate r
                                     left join user_rate ur
                                               on r.id = ur.rate_id
                                                   and ur.user_id = ts.user_id
                            where r.currency_symbol = p_currency
                              and (ur.user_id notnull or default_rate)
                              and r.cc_code = ts.cc_code
                            order by ur.user_id nulls last
                            limit 1
    ) fiat on true
where ts.user_id = p_user_id;
$$;


--
-- Name: get_withdrawal_fee_and_limits(character varying, numeric, numeric); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.get_withdrawal_fee_and_limits(p_cc_code character varying, p_balance numeric, p_amount_to_withdraw numeric, OUT p_min_fee_amount numeric, OUT p_max_fee_amount numeric, OUT p_fee_amount numeric, OUT p_max_withdrawal_amount numeric) RETURNS record
    LANGUAGE sql
    SET search_path TO 'p2p'
    AS $$
with x as materialized (
    select numrange(lower(op_amount), p_balance - fee_amount, '(]') + op_amount can_withdraw,
           p_balance - fee_amount                                               max_withdraw,
           fee_amount
    from rate_plan_withdraw rpw
    where act_during @> localtimestamp
      and rpw.cc_code = p_cc_code
      and p_balance > fee_amount
      and (p_balance >= p_amount_to_withdraw or p_amount_to_withdraw is null)
      and numrange(0, p_balance - fee_amount, '(]') && op_amount
)
select min(fee_amount),
       max(fee_amount),
       max(fee_amount) filter ( where p_amount_to_withdraw <@ can_withdraw ),
       min(max_withdraw)
from x;
$$;


--
-- Name: get_withdrawal_fee_range(character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.get_withdrawal_fee_range(p_cc_code character varying) RETURNS TABLE(min numeric, max numeric)
    LANGUAGE sql
    SET search_path TO 'p2p'
    AS $$
select min(fee_amount), max(fee_amount)
from rate_plan_withdraw
where cc_code = p_cc_code
  and localtimestamp <@ act_during
$$;


--
-- Name: global_paymethods_delete(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.global_paymethods_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
		delete from p2p.payment_method where description = OLD.label;
		return OLD;

END $$;


--
-- Name: global_paymethods_insert(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.global_paymethods_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 rc record;
BEGIN
	FOR rc IN SELECT symbol FROM p2p.currencies
	LOOP
		INSERT INTO p2p.payment_method (currency, description, i18n, weight, payments_group)
		VALUES (rc.symbol, NEW.label, json_build_object('ru', NEW.label), 0, NEW.payments_group) ON CONFLICT DO NOTHING;
	END LOOP;
	return NEW;

END $$;


--
-- Name: global_paymethods_update(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.global_paymethods_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
		update p2p.payment_method SET description = NEW.label, i18n = json_build_object('ru', NEW.label) where description = OLD.label;
		return NEW;

END $$;


--
-- Name: handle_features_adding(character varying[]); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.handle_features_adding(codes character varying[]) RETURNS TABLE(codes_to_add character varying[], error_code_required character varying[], error_code_second_level character varying[])
    LANGUAGE sql
    SET search_path TO 'p2p'
    AS $$
with to_add as (
    select unnest(codes) code
)

select array_agg(distinct root.code)                                                codes_to_add,

       array_agg(distinct req.code)
       filter (where req.code is not null)                                          error_code_require,

       array_agg(req.required_feature_code)
       filter (where not req.required_feature_code = any(select * from to_add) )    error_code_second_level

from p2p.feature root
         left join p2p.feature req on root.required_feature_code = req.code

    and req.code not in (select * from to_add)

where root.code in (select * from to_add)
    ;
$$;


--
-- Name: heal_old_data_after_merge(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.heal_old_data_after_merge() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  tgid character varying(256);
  old_uid integer;
BEGIN

FOR old_uid, tgid IN SELECT id as old_uid, regexp_replace(telegram_id, 'deleted_{?(\d+)}?', '\1') as tgid
            FROM public.users
            WHERE telegram_id LIKE 'deleted_%' AND NOT telegram_id LIKE '%todel' LOOP

  UPDATE p2p.old_data_profile
  SET user_id=(SELECT id FROM public.users WHERE telegram_id=tgid)
  WHERE user_id=old_uid;

END LOOP;
END;
$$;


--
-- Name: heal_reg_after_merge(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.heal_reg_after_merge() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  tgid character varying(256);
  old_uid integer;
  new_uid integer;
  old_reg timestamp;
  new_reg timestamp;
BEGIN

  FOR old_uid, tgid IN SELECT id as old_uid, regexp_replace(telegram_id, 'deleted_{?(\d+)}?', '\1') as tgid
              FROM public.users
              WHERE telegram_id LIKE 'deleted_%' AND NOT telegram_id LIKE '%todel' LOOP
  
    SELECT id
    FROM public.users
    WHERE telegram_id = tgid
    INTO new_uid;

    SELECT start_of_use_date
    FROM p2p.user_profile
    WHERE user_id = old_uid
    INTO old_reg;
  
    SELECT start_of_use_date
    FROM p2p.user_profile
    WHERE user_id = new_uid
    INTO new_reg;

    RAISE NOTICE 'Old_uid %, New_uid % within % and % = %', old_uid, new_uid, old_reg, new_reg, least(old_reg, new_reg);


    UPDATE p2p.user_profile
    SET start_of_use_date = least(old_reg, new_reg)
    WHERE user_id=new_uid;
  END LOOP;
END;
$$;


--
-- Name: heal_vouchers_after_merge(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.heal_vouchers_after_merge() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  tgid character varying(256);
  old_uid integer;
BEGIN

FOR old_uid, tgid IN SELECT id as old_uid, regexp_replace(telegram_id, 'deleted_{?(\d+)}?', '\1') as tgid
            FROM public.users
            WHERE telegram_id LIKE 'deleted_%' AND NOT telegram_id LIKE '%todel' LOOP

  UPDATE p2p.voucher
  SET user_id=(SELECT id FROM public.users WHERE telegram_id=tgid)
  WHERE user_id=old_uid;

  UPDATE p2p.voucher
  SET cashed_by_user_id=(SELECT id FROM public.users WHERE telegram_id=tgid)
  WHERE cashed_by_user_id=old_uid;

END LOOP;
END;
$$;


--
-- Name: hold_to_balance(integer, public.cryptocurrency_code, numeric, text, p2p.operation_source, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.hold_to_balance(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_id integer;

BEGIN
  SELECT id
  FROM public.wallet
  WHERE user_id = userid
    AND cc_code = cc
  INTO wallet_id;

  UPDATE public.wallet
  SET balance = balance + amount
  WHERE id = wallet_id;

  UPDATE public.wallet
  SET hold_balance = hold_balance - amount
  WHERE id = wallet_id;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet_id,
    (SELECT balance FROM public.wallet WHERE id = wallet_id),
    (SELECT hold_balance FROM public.wallet WHERE id = wallet_id),
    cause,
    amount,
    cc,
    source_type,
    'unhold',
    platform
  );

END;
$$;


--
-- Name: hold_to_null(integer, integer, bigint, text); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.hold_to_null(user_from integer, currency integer, amount bigint, cause text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  wallet_from integer;
BEGIN
  EXECUTE 'SELECT id
           FROM public.wallets
           WHERE user_id = $1
           AND   currency = $2'
  INTO wallet_from
  USING user_from, currency;

  EXECUTE 'UPDATE public.wallets
           SET hold_balance = hold_balance - $2
           WHERE id = $1'
  USING wallet_from, amount;

  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
  VALUES (wallet_from,
          format('Release %s satoshi to null', amount),
          (SELECT balance FROM public.wallets WHERE id = wallet_from),
          (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
          cause);
END;
$_$;


--
-- Name: hold_to_null(integer, public.cryptocurrency_code, numeric, text, p2p.operation_source, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.hold_to_null(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet integer;

BEGIN
  SELECT id
  FROM public.wallets
  WHERE user_id = userid
    AND cc_code = cc
  INTO wallet;

  UPDATE public.wallets
  SET hold_balance = hold_balance - amount
  WHERE id = wallet;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet,
    (SELECT balance FROM public.wallets WHERE id = wallet),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet),
    cause,
    amount,
    cc,
    source_type,
    'outgoing',
    platform
  );

END;
$$;


--
-- Name: money_to_hold(integer, public.cryptocurrency_code, numeric, text, p2p.operation_source, integer, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.money_to_hold(userid integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_id integer;

BEGIN
  SELECT id
  FROM public.wallet
  WHERE user_id = userid
    AND cc_code = cc
  INTO wallet_id;

  UPDATE public.wallet
  SET balance = balance - amount
  WHERE id = wallet_id;

  UPDATE public.wallet
  SET hold_balance = hold_balance + amount
  WHERE id = wallet_id;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_id,
    (SELECT balance FROM public.wallet WHERE id = wallet_id),
    (SELECT hold_balance FROM public.wallet WHERE id = wallet_id),
    cause,
    amount,
    cc,
    source_type,
    source_id,
    'hold',
    platform
  );

END;
$$;


--
-- Name: move_money(integer, integer, integer, bigint, text); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.move_money(user_from integer, user_to integer, cc integer, amount bigint, cause text) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_from integer;
  wallet_to integer;
  cc_code varchar(10);

BEGIN
  SELECT code
  FROM public.cryptocurrency
  WHERE int_code = cc
  INTO cc_code;

  SELECT id
  FROM public.wallets
  WHERE user_id = user_from
    AND currency = cc
  INTO wallet_from;

  SELECT id
  FROM public.wallets
  WHERE user_id = user_to
    AND currency = cc
  INTO wallet_to;

  UPDATE public.wallets
  SET balance = balance - amount
  WHERE id = wallet_from;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    currency,
    amount,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet_from,
    (SELECT balance FROM public.wallets WHERE id = wallet_from),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
    cause,
    cc_code,
    (amount / 100000000::numeric)::numeric(1000, 10),
    'direct',
    'outgoing',
    'admin'
  );

  UPDATE public.wallets
  SET balance = balance + amount
  WHERE id = wallet_to;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    currency,
    amount,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet_to,
    (SELECT balance FROM public.wallets WHERE id = wallet_to),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_to),
    cause,
    cc_code,
    (amount / 100000000::numeric)::numeric(1000, 10),
    'direct',
    'incoming',
    'admin'
  );
END;
$$;


--
-- Name: move_money(integer, integer, integer, numeric, text, p2p.operation_source, integer, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.move_money(user_from integer, user_to integer, cc integer, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_from integer;
  wallet_to integer;
  cc_code character varying(4);

BEGIN
  SELECT id
  FROM public.wallets
  WHERE user_id = user_from
    AND currency = cc
  INTO wallet_from;

  SELECT id
  FROM public.wallets
  WHERE user_id = user_to
    AND currency = cc
  INTO wallet_to;

  SELECT code
  FROM public.cryptocurrency
  WHERE int_code = cc
  INTO cc_code;

  UPDATE public.wallets
  SET balance = balance - amount
  WHERE id = wallet_from;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_from,
    (SELECT balance FROM public.wallets WHERE id = wallet_from),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
    cause,
    (amount / 100000000::numeric)::numeric(1000, 10),
    cc_code,
    source_type,
    source_id,
    'outgoing',
    platform
  );

  UPDATE public.wallets
  SET balance = balance + amount
  WHERE id = wallet_to;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_to,
    (SELECT balance FROM public.wallets WHERE id = wallet_to),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_to),
    cause,
    (amount::numeric / 100000000::numeric)::numeric(1000, 10),
    cc_code,
    source_type,
    source_id,
    'incoming',
    platform
  );
END;
$$;


--
-- Name: move_money(integer, integer, public.cryptocurrency_code, numeric, text, p2p.operation_source, integer, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.move_money(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_from integer;
  wallet_to integer;

BEGIN
  SELECT id
  FROM public.wallets
  WHERE user_id = user_from
    AND cc_code = cc
  INTO wallet_from;

  SELECT id
  FROM public.wallets
  WHERE user_id = user_to
    AND cc_code = cc
  INTO wallet_to;

  UPDATE public.wallets
  SET balance = balance - amount
  WHERE id = wallet_from;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_from,
    (SELECT balance FROM public.wallets WHERE id = wallet_from),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
    cause,
    (amount / 100000000::numeric)::numeric(1000, 10),
    cc,
    source_type,
    source_id,
    'outgoing',
    platform
  );

  UPDATE public.wallets
  SET balance = balance + amount
  WHERE id = wallet_to;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_to,
    (SELECT balance FROM public.wallets WHERE id = wallet_to),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_to),
    cause,
    (amount::numeric / 100000000::numeric)::numeric(1000, 10),
    cc,
    source_type,
    source_id,
    'incoming',
    platform
  );
END;
$$;


--
-- Name: move_user(integer, integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.move_user(from_id integer, to_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  wallet RECORD;
  cc_stat RECORD;
  wallet_id integer;
  from_public_name character varying;
BEGIN

FOR wallet IN SELECT currency FROM public.wallets WHERE user_id = from_id LOOP

  SELECT id INTO wallet_id
  FROM public.wallets
  WHERE user_id = to_id AND currency = wallet.currency;

  IF wallet_id IS NULL THEN
    INSERT INTO public.wallets (user_id, currency) VALUES (to_id, wallet.currency);
  END IF;

  UPDATE public.wallets
  SET balance = balance + (SELECT balance + hold_balance
                           FROM public.wallets
                           WHERE user_id = from_id AND currency = wallet.currency)
  WHERE user_id = to_id AND currency = wallet.currency;

  UPDATE public.wallets
  SET balance = 0,
      hold_balance = 0
  WHERE user_id = from_id AND currency = wallet.currency;

END LOOP;

FOR cc_stat IN SELECT * FROM p2p.trade_statistic WHERE user_id = from_id LOOP

  INSERT INTO p2p.trade_statistic AS ts (user_id,
                                         cryptocurrency,
                                         total_count,
                                         total_amount,
                                         success_deals,
                                         canceled_deals,
                                         defeat_in_dispute,
                                         positive_feedbacks_count,
                                         negative_feedbacks_count)
  VALUES (to_id,
          cc_stat.cryptocurrency,
          cc_stat.total_count,
          cc_stat.total_amount,
          cc_stat.success_deals,
          cc_stat.canceled_deals,
          cc_stat.defeat_in_dispute,
          cc_stat.positive_feedbacks_count,
          cc_stat.negative_feedbacks_count)
  
  ON CONFLICT (user_id, cryptocurrency) DO UPDATE 
  SET total_count = ts.total_count + cc_stat.total_count,
      total_amount = ts.total_amount + cc_stat.total_amount,
      success_deals = ts.success_deals + cc_stat.success_deals,
      canceled_deals = ts.canceled_deals + cc_stat.canceled_deals,
      defeat_in_dispute = ts.defeat_in_dispute + cc_stat.defeat_in_dispute,
      positive_feedbacks_count = ts.positive_feedbacks_count + cc_stat.positive_feedbacks_count,
      negative_feedbacks_count = ts.negative_feedbacks_count + cc_stat.negative_feedbacks_count;

END LOOP;


UPDATE public.users
SET ref_parent_user_id = to_id
WHERE ref_parent_user_id = from_id AND id != ref_parent_user_id;

UPDATE public.users
SET ref_parent_user_id = (SELECT ref_parent_user_id FROM public.users WHERE id = from_id),
    created_at = (SELECT created_at FROM public.users WHERE id = from_id)
WHERE id = to_id;

UPDATE p2p.feedbacks
SET for_user_id = to_id
WHERE for_user_id = from_id;

UPDATE p2p.user_block
SET user_id = to_id
WHERE user_id = from_id;

UPDATE p2p.user_block
SET blocked_user_id = to_id
WHERE blocked_user_id = from_id;

UPDATE p2p.user_trust
SET user_id = to_id
WHERE user_id = from_id;

UPDATE p2p.user_trust
SET trusted_user_id = to_id
WHERE trusted_user_id = from_id;

UPDATE p2p.notebook
SET user_id = to_id
WHERE user_id = from_id;

UPDATE p2p.withdraw_vouchers
SET user_id = to_id
WHERE user_id = from_id
  AND used_at IS NULL
  AND expire_at > now();

UPDATE p2p.user_profile
SET about_user = concat('Перенесён с ', from_id, '. ', (SELECT about_user FROM p2p.user_profile WHERE user_id = from_id), ' ', about_user),
    rating = rating + (SELECT rating FROM p2p.user_profile WHERE user_id = from_id),
    start_of_use_date = (SELECT start_of_use_date FROM p2p.user_profile WHERE user_id = from_id)
WHERE user_id = to_id;

UPDATE p2p.user_profile
SET about_user = concat('Перенесён на ', to_id, '.', about_user)
WHERE user_id = from_id;

SELECT public_name
FROM p2p.user_profile
WHERE user_id = from_id
INTO from_public_name;

IF from_public_name IS NOT NULL THEN
  UPDATE p2p.user_profile SET public_name = NULL WHERE user_id = from_id;
  UPDATE p2p.user_profile SET public_name = from_public_name WHERE user_id = to_id;
END IF;

END;
$$;


--
-- Name: recreate_payment(integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.recreate_payment(payment_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  amount bigint;
  wallet_id integer;
BEGIN

  EXECUTE 'SELECT wallet_id, amount + fee FROM public.payments WHERE status = 5 AND id = $1'
  INTO wallet_id, amount
  USING payment_id;

  EXECUTE 'UPDATE public.wallets 
           SET hold_balance = hold_balance + $1
           WHERE id = $2'
  USING amount, wallet_id;

  EXECUTE 'UPDATE public.payments
           SET status = 1
           WHERE id = $1'
  USING payment_id;

  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
  VALUES (wallet_id,
          format('Get %s hold back and restart payment %s', amount, payment_id),
          (SELECT balance FROM public.wallets WHERE id = wallet_id),
          (SELECT hold_balance FROM public.wallets WHERE id = wallet_id),
          format('Restart payment'));
END;
$_$;


--
-- Name: release_banned_balances(timestamp without time zone); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.release_banned_balances(up_to_date timestamp without time zone DEFAULT now()) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  wallet RECORD;
  system_uid integer;
BEGIN

  SELECT id
  FROM public.users
  WHERE username = 'system'
  INTO system_uid;

  FOR wallet IN SELECT w.id,
                       w.currency,
                       w.balance,
                       w.hold_balance
                FROM public.wallets w
                INNER JOIN p2p.user_profile up
                        ON w.user_id = up.user_id
                WHERE up.blocked_by_admin = true
                  AND w.balance > 0
                  AND up.lastactivity < up_to_date LOOP

    UPDATE public.wallets
    SET balance = 0
    WHERE id = wallet.id;

    INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
    VALUES (wallet.id,
            format('Withdraw from wallet balance %s in satoshi', wallet.balance),
            0,
            wallet.hold_balance,
            'Releasing balances of blocked users');

    UPDATE public.wallets
    SET balance = balance + wallet.balance
    WHERE user_id = system_uid
      AND currency = wallet.currency;

    INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
    VALUES ((SELECT id FROM public.wallets WHERE user_id = system_uid AND currency = wallet.currency),
            format('Add to wallet balance %s in satoshi', wallet.balance),
            (SELECT balance FROM public.wallets WHERE user_id = system_uid AND currency = wallet.currency),
            (SELECT hold_balance FROM public.wallets WHERE user_id = system_uid AND currency = wallet.currency),
            'Releasing balances of blocked users');
  END LOOP;
END;
$$;


--
-- Name: release_debt(integer, integer, integer, numeric, text, p2p.operation_source, integer, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.release_debt(user_from integer, user_to integer, cc integer, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_from integer;
  wallet_to integer;
  cc_code character varying(4);

BEGIN
  SELECT id
  FROM public.wallets
  WHERE user_id = user_from
    AND currency = cc
  INTO wallet_from;

  SELECT id
  FROM public.wallets
  WHERE user_id = user_to
    AND currency = cc
  INTO wallet_to;

  SELECT code
  FROM public.cryptocurrency
  WHERE int_code = cc
  INTO cc_code;

  UPDATE public.wallets
  SET hold_balance = hold_balance - amount
  WHERE id = wallet_from;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_from,
    (SELECT balance FROM public.wallets WHERE id = wallet_from),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
    cause,
    (amount / 100000000::numeric)::numeric(1000, 10),
    cc_code,
    source_type,
    source_id,
    'unhold',
    platform
  );

  UPDATE public.wallets
  SET balance = balance + amount
  WHERE id = wallet_to;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_to,
    (SELECT balance FROM public.wallets WHERE id = wallet_to),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_to),
    cause,
    (amount::numeric / 100000000::numeric)::numeric(1000, 10),
    cc_code,
    source_type,
    source_id,
    'incoming',
    platform
  );
END;
$$;


--
-- Name: release_debt(integer, integer, public.cryptocurrency_code, numeric, text, p2p.operation_source, integer, character varying); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.release_debt(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, source_id integer, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_from integer;
  wallet_to integer;

BEGIN
  SELECT id
  FROM public.wallets
  WHERE user_id = user_from
    AND cc_code = cc
  INTO wallet_from;

  SELECT id
  FROM public.wallets
  WHERE user_id = user_to
    AND cc_code = cc
  INTO wallet_to;

  UPDATE public.wallets
  SET hold_balance = hold_balance - amount
  WHERE id = wallet_from;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_from,
    (SELECT balance FROM public.wallets WHERE id = wallet_from),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
    cause,
    (amount / 100000000::numeric)::numeric(1000, 10),
    cc,
    source_type,
    source_id,
    'unhold',
    platform
  );

  UPDATE public.wallets
  SET balance = balance + amount
  WHERE id = wallet_to;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    source_id,
    operation_type,
    platform
  ) VALUES (
    wallet_to,
    (SELECT balance FROM public.wallets WHERE id = wallet_to),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_to),
    cause,
    (amount::numeric / 100000000::numeric)::numeric(1000, 10),
    cc,
    source_type,
    source_id,
    'incoming',
    platform
  );
END;
$$;


--
-- Name: release_debts(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.release_debts() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  wallet RECORD;
BEGIN
FOR wallet IN SELECT id, balance, hold_balance, debt 
              FROM public.wallets 
              WHERE debt > 0 AND debt = hold_balance LOOP

  UPDATE public.wallets
  SET debt = 0
  WHERE id=wallet.id;

  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
  VALUES (wallet.id,
          format('Holding debt=%s', wallet.debt),
          wallet.balance,
          wallet.hold_balance,
          format('Holding debt'));
END LOOP;
END;
$$;


--
-- Name: remote_rate_value(integer, character varying, public.cryptocurrency_code); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.remote_rate_value(p_user_id integer, p_currency character varying, p_cc_code public.cryptocurrency_code) RETURNS numeric
    LANGUAGE sql
    SET search_path TO 'public', 'p2p'
    AS $$

select r.value
from RATE r
         left join user_rate ur on r.id = ur.rate_id and ur.user_id = p_user_id
where r.currency_symbol = p_currency
  and r.cc_code = p_cc_code
  and (ur.user_id is not null or r.default_rate)
order by ur.user_id nulls last
limit 1;

$$;


--
-- Name: rep_finance_movement_100(integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.rep_finance_movement_100(p_user_id integer) RETURNS TABLE(amount numeric, cc_code character varying, operation_type character varying, source_type character varying, source_id character varying, date timestamp without time zone)
    LANGUAGE sql
    SET search_path TO 'p2p', 'public'
    AS $$
(
    select amount::numeric,
           t.cc_code,
           'Incoming',
           'Deposit',
           btx.txid,
           t.created_at
    from deposit t
    join blockchain_tx btx on blockchain_tx_id = btx.id
    where user_id = p_user_id
      and t.status = 'success'
)
union
(
    select amount::numeric,
           p.cc_code,
           'Outgoing',
           'Withdraw',
           btx.txid,
           p.created_at
    from withdrawal p
    left join blockchain_tx btx on blockchain_tx_id = btx.id
    where user_id = p_user_id
      and p.status = 'processed'
)
union
(
    select fee::numeric,
           p2.cc_code,
           'Outgoing',
           'Withdraw Fee',
           btx.txid,
           p2.created_at
    from withdrawal p2
    left join blockchain_tx btx on blockchain_tx_id = btx.id
    where user_id = p_user_id
      and p2.status = 'processed'
      and fee > 0
)
union
(
    select amount,
           cc_code,
           case when user_id = p_user_id then 'Outgoing' else 'Incoming' end,
           'Voucher',
           'c_' || secret_key,
           cashed_at
    from voucher
    where (user_id = p_user_id or cashed_by_user_id = p_user_id)
      and deleted_at is null
      and cashed_at is not null
)
union
(
    select crypto_amount,
           cc_code,
           'Incoming',
           'Referral Bonus',
           case
               when trade_id is not null then 'Trade id #' || trade_id
               else 'Order id #' || order_id
               end,
           date
    from referal_bonus rb
    where ref_parent_user_id = p_user_id
)
union
(
    select cryptoamount,
           cc_code,
           case when crypto_buyer = p_user_id then 'Incoming' else 'Outgoing' end,
           'Trade',
           id::varchar,
           trade.created_at
    from trade
    where status = 'confirm-payment'::trade_state
      and (crypto_buyer = p_user_id or crypto_seller = p_user_id)
)
union
(
    select tips_amount,
           cc_code,
           case
               when crypto_buyer = p_user_id and ad_type = 'purchase'::ads_type or
                    crypto_seller = p_user_id and ad_type = 'selling'::ads_type
                   then 'Incoming'
               else
                   'Outgoing' end,
           'Trade Tips',
           id::varchar,
           created_at
    from trade
    where status = 'confirm-payment'::trade_state
      and (crypto_buyer = p_user_id or
           crypto_seller = p_user_id)
      and tips_payed
)
union
(
    select amount,
           cc_code,
           'Incoming',
           'Payment from merchant',
           id::varchar,
           date
    from mer.payment
    where user_id = p_user_id and status = 'done'
)
order by 6 desc;
$$;


--
-- Name: rep_referral_104(integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.rep_referral_104(rep_user_id integer) RETURNS TABLE(type character varying, referral_id integer, referral_name character varying, amount_crypto numeric, cc_code character varying, amount_usd numeric, referral_type p2p.referral_type, date timestamp without time zone)
    LANGUAGE sql
    SET search_path TO 'p2p', 'public'
    AS $$
(
    select 'New referral',
           id,
           (select coalesce(public_name, generated_name) from p2p.user_profile p where p.user_id = u.id),
           0,
           '-',
           0,
           ref_type,
           (select date from (values (u.created_at, m.date_of_merge)) m(date) order by date)
    from "user" u
             left join p2p.merge m on u.id = m.telegram_account_user_id or u.id = m.web_account_user_id
    where ref_parent_user_id = rep_user_id
      and id != rep_user_id
      and u.deleted_at is null
)
UNION
(
    select 'Referral payment',
           p.user_id,
           coalesce(p.public_name, p.generated_name),
           rb.crypto_amount,
           rb.cc_code,
           rb.crypto_amount * r.value,
           (select ref_type from "user" u where u.id = p.user_id),
           rb.date
    from referal_bonus rb
             left join merge m on rb.referal_id = m.web_account_user_id or rb.referal_id = m.telegram_account_user_id
             left join user_profile p on
            p.user_id = m.web_account_user_id or p.user_id = m.telegram_account_user_id or p.user_id = rb.referal_id
             join rate r
                  on r.currency_symbol = 'USD' and r.cc_code = rb.cc_code and default_rate

    where rb.ref_parent_user_id = rep_user_id
)
ORDER BY 8 DESC;
$$;


--
-- Name: rep_trade_history_101(integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.rep_trade_history_101(p_user_id integer) RETURNS TABLE(id integer, crypto_amount numeric, fiat_amount numeric, exchange_rate numeric, buyer integer, seller integer, type p2p.ads_type, status p2p.trade_state, cc_code character varying, currency character varying, fee numeric, payment_method character varying, date timestamp without time zone)
    LANGUAGE sql
    SET search_path TO 'p2p', 'public'
    AS $$
select id,
       cryptoamount,
       amount,
       ad_rate,
       crypto_buyer,
       crypto_seller,
       ad_type,
       status,
       cc_code,
       currency,
       case
           when status != 'confirm-payment'::trade_state then 0
           when p_user_id = crypto_buyer then fee_buyer
           else fee_seller end,
       (select description from payment_method where id = t.ad_paymethod)                "paymethod",
       (select date from trade_history where trade_id = t.id order by date desc limit 1) "last_action_date"
from trade t
where crypto_buyer = p_user_id
   or crypto_seller = p_user_id
order by last_action_date desc, id desc;
$$;


--
-- Name: rep_vouchers_102(integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.rep_vouchers_102(p_user_id integer) RETURNS TABLE(amount numeric, cc_code character varying, currency character varying, giver integer, recipient integer, status character varying, voucher_code character varying, comment character varying, cashed_at timestamp without time zone, created_at timestamp without time zone)
    LANGUAGE sql
    SET search_path TO 'p2p', 'public'
    AS $$
select amount,
       cc_code,
       currency,
       user_id,
       cashed_by_user_id,
       case when cashed_at is null then 'created' else 'cashed' end,
       secret_key,
       case when p_user_id = cashed_by_user_id then comment_by_cashed_user else comment end,
       cashed_at,
       created_at
from voucher
where deleted_at is null
  and (user_id = p_user_id or cashed_by_user_id = p_user_id)
order by created_at desc, id desc
$$;


--
-- Name: rep_wallet_history_103(integer); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.rep_wallet_history_103(p_user_id integer) RETURNS TABLE(type character varying, amount numeric, cc_code character varying, fee numeric, address character varying, transaction character varying, comment character varying, date timestamp without time zone)
    LANGUAGE sql
    SET search_path TO 'p2p', 'public'
    AS $$
(
    select 'Receive',
           amount::numeric,
           t.cc_code,
           fee::numeric,
           address,
           txid,
           comment,
           t.created_at
    from deposit t
    join blockchain_tx btx on blockchain_tx_id = btx.id
    where user_id = p_user_id
      and t.status = 'success'
)
union all
(
    select 'Send',
           amount,
           p.cc_code,
           fee,
           address,
           txid,
           comment,
           p.created_at
    from withdrawal p
    left join blockchain_tx btx on blockchain_tx_id = btx.id
    where user_id = p_user_id
      and p.status = 'processed'
)
union all
(
    select 'Referral Payment',
           crypto_amount,
           cc_code,
           0,
           '',
           '',
           '',
           date
    from referal_bonus
    where ref_parent_user_id = p_user_id
)
union all
(
    select 'Tips ' || case when trade_initiator = p_user_id then 'outgoing' else 'incoming' end,
           tips_amount,
           cc_code,
           0,
           'Trade id #' || id,
           '',
           '',
           created_at
    from trade t
    where tips_payed
      and (crypto_seller = p_user_id or crypto_buyer = p_user_id)
)
union all
(
    select 'Payment via merchant',
           amount,
           cc_code,
           0,
           (select name
            from mer.merchant m
                     join mer.invoice i on i.merchant_id = m.id
            where i.id = mt.invoice_id),
           'Invoice ID ' || invoice_id,
           '',
           created_at
    from mer.invoice_transaction mt
    where user_id = p_user_id
)
union all
(
    select 'Payment from merchant',
           amount,
           cc_code,
           0,
           (select name from mer.merchant m where m.id = mp.merchant_id),
           '',
           '',
           date
    from mer.payment mp
    where user_id = p_user_id and status = 'done'
)
order by 8 desc;
$$;


--
-- Name: set_merged_after_merge(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.set_merged_after_merge() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  tgid character varying(256);
BEGIN

  FOR tgid IN SELECT regexp_replace(telegram_id, 'deleted_{?(\d+)}?', '\1') as tgid
              FROM public.users
              WHERE telegram_id LIKE 'deleted_%' AND NOT telegram_id LIKE '%todel' LOOP
  
    UPDATE p2p.user_profile
    SET merged=true
    WHERE user_id=(SELECT id FROM public.users WHERE telegram_id=tgid);
  END LOOP;
END;
$$;


--
-- Name: store_audit_json(); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.store_audit_json() RETURNS jsonb
    LANGUAGE sql
    SET search_path TO 'p2p', 'public'
    AS $$
insert into audit(audit_json)
select jsonb_object_agg(s.cryptocurrency,
                        jsonb_build_object(
                            'totalIn', s.total_in,
                            'totalDustIn', s.total_dust_in,
                            'totalOut', s.total_out,
                            'totalAudit', s.total_in - s.total_out - s.total_wallets,
                            'totalWallets', s.total_wallets,
                            'totalBalancesHolded', s.total_balances_holded,
                            'totalBalancesFree', s.total_balances_free,
                            'pendingPayments', s.pending_payments,
                            'totalNetworkFee', s.total_network_fee,
                            'systemWalletBalance', s.system_wallet_balance,
                            'realColdWalletBalance', s.real_cold_wallet_balance,
                            'systemHotWalletBalance', s.hot_wallet_balance,
                            'hotWalletUnconfirmedBalance', s.hot_wallet_unconfirmed_balance,
                            'totalWalletsColdAndHot',
                            s.hot_wallet_balance + s.real_cold_wallet_balance + s.cold_wallet_audit_adjust,
                            'coldWalletAdjust', s.cold_wallet_audit_adjust,
                            'debt', s.debt
                            )
           )
from vw_audit_source s
returning audit_json;
$$;


--
-- Name: to_seconds(text); Type: FUNCTION; Schema: p2p; Owner: -
--

CREATE FUNCTION p2p.to_seconds(t text) RETURNS integer
    LANGUAGE plpgsql
    AS $$ 
DECLARE 
    hs INTEGER;
    ms INTEGER;
    s INTEGER;
BEGIN
    SELECT (EXTRACT( HOUR FROM  t::time) * 60*60) INTO hs; 
    SELECT (EXTRACT (MINUTES FROM t::time) * 60) INTO ms;
    SELECT (EXTRACT (SECONDS from t::time)) INTO s;
    SELECT (hs + ms + s) INTO s;
    RETURN s;
END;
$$;


--
-- Name: add_fake_balance(integer, integer, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_fake_balance(userid integer, cc integer, amount bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  wallet RECORD;
BEGIN

  SELECT * INTO wallet
  FROM public.wallets w
  WHERE w.user_id = userid AND w.currency = cc;

  RAISE NOTICE 'new_balance = %', wallet.balance + amount;

  UPDATE public.wallets w
  SET balance = balance + amount
  WHERE w.id = wallet.id;

  INSERT into public.transactions (user_id, wallet_id, currency, address, amount, category, txid, balance_loaded)
  VALUES (userid, wallet.id, cc, '', amount, 2, '', true);

  UPDATE p2p.cryptocurrency_settings
  SET cold_wallet_audit_adjust = cold_wallet_audit_adjust + amount::numeric / 100000000
  WHERE code = (SELECT code FROM public.cryptocurrency WHERE int_code=cc);
END;
$$;


--
-- Name: array_sort_unique(anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.array_sort_unique(anyarray) RETURNS anyarray
    LANGUAGE sql
    AS $_$
  SELECT ARRAY(
    SELECT DISTINCT $1[s.i]
    FROM generate_series(array_lower($1,1), array_upper($1,1)) AS s(i)
    ORDER BY 1
  );
$_$;


--
-- Name: base58_encode(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.base58_encode(num integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

DECLARE
  alphabet   VARCHAR(255);
  base_count INT DEFAULT 0;
  encoded    VARCHAR(255);
  divisor    DECIMAL(10, 4);
  mod        INT DEFAULT 0;

BEGIN
  alphabet := '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  base_count := char_length(alphabet);
  encoded := '';

  WHILE num >= base_count LOOP
    divisor := num / base_count;
    mod := (num - (base_count * trunc(divisor, 0)));
    encoded := concat(substring(alphabet FROM mod + 1 FOR 1), encoded);
    num := trunc(divisor, 0);
  END LOOP;

  encoded = concat(substring(alphabet FROM num + 1 FOR 1), encoded);

  RETURN (encoded);

END; $$;


--
-- Name: create_partition_for_date(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_partition_for_date(p_date date, p_table character varying) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $_$
declare
    declare
    v_partition_name text := p_table || '$' || to_char(p_date, 'YYYYMMDD');
begin
    -- If partition does not exist...:
    if to_regclass(v_partition_name) is null then
        -- Generate a new table that acts as a partition:
        execute format('create table %I partition of %I for values in (%L)', v_partition_name, p_table, p_date);
        execute format('alter table %I set (autovacuum_enabled=false, fillfactor = 100)', v_partition_name);
    end if;
end;
$_$;


--
-- Name: drop_partition_for_date(date, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.drop_partition_for_date(p_date date, p_table character varying) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $_$
declare
    declare
    v_partition_name text := p_table || '$' || to_char(p_date, 'YYYYMMDD');
begin
    -- If partition exists...:
    if to_regclass(v_partition_name) is not null then
        -- Drop old partition
        execute format('drop table %I', v_partition_name);
    end if;
end;
$_$;


--
-- Name: first_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.first_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT $1;
$_$;


--
-- Name: get_partitions_for_date(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_partitions_for_date(p_table character varying) RETURNS TABLE(partition_name text, for_date date)
    LANGUAGE sql
    SET search_path TO 'public'
    AS $$
select partition_name::text, SUBSTRING(expr, 'FOR VALUES IN \((.*)\)')::date for_date
from (
         select pt.relname as                              partition_name,
                pg_get_expr(pt.relpartbound, pt.oid, true) expr
         from pg_class base_tb
                  join pg_inherits i on i.inhparent = base_tb.oid
                  join pg_class pt on pt.oid = i.inhrelid
         where base_tb.oid = p_table::regclass
     ) p

$$;


--
-- Name: hold_to_balance(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.hold_to_balance(payment_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  amount bigint;
  wallet_id integer;
BEGIN

  EXECUTE 'SELECT wallet_id, amount + fee FROM public.payments WHERE id = $1'
  INTO wallet_id, amount
  USING payment_id;

  EXECUTE 'UPDATE public.wallets 
           SET balance = balance + $1,
               hold_balance = hold_balance - $1
           WHERE id = $2'
  USING amount, wallet_id;

  EXECUTE 'UPDATE public.payments
           SET status = 5
           WHERE id = $1'
  USING payment_id;

  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
  VALUES (wallet_id,
          format('Move hold %s to balance for failed payment %s', amount, payment_id),
          (SELECT balance FROM public.wallets WHERE id = wallet_id),
          (SELECT hold_balance FROM public.wallets WHERE id = wallet_id),
          format('Revert payments'));
END;
$_$;


--
-- Name: last_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT $2;
$_$;


--
-- Name: maintain_partitions_for_dates(integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.maintain_partitions_for_dates(p_retain_days integer, p_in_advance_days integer, p_table text) RETURNS void
    LANGUAGE sql
    SET search_path TO 'public'
    AS $$
select create_partition_for_date(dt, p_table)
from (
         select current_date + delta.d dt
         from generate_series(0, p_in_advance_days) delta(d)
             except
         select for_date
         from get_partitions_for_date(p_table)
     ) to_create;

select drop_partition_for_date(for_date, p_table)
from get_partitions_for_date(p_table)
where for_date < current_date - p_retain_days ;
$$;


--
-- Name: mark_as_sent_and_release(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_as_sent_and_release() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  amount bigint;
  wallet_id integer;
  payment_id integer;
BEGIN

FOR payment_id IN SELECT p.id FROM public.payments p
  JOIN public.wallets w ON p.wallet_id=w.id
  WHERE p."status" = '2' 
  AND p."created_at" > '2018-12-01' 
  AND CAST(p."updated_at" AS text) LIKE '%2018-12-03%' 
  AND p.created_at < '2018-12-03 16:00'
  AND p."transaction_id" IS NULL
  AND p.id != 13489 AND w.balance >= p.amount + p.fee
LOOP

  EXECUTE 'SELECT wallet_id, amount + fee FROM public.payments WHERE id = $1'
  INTO wallet_id, amount
  USING payment_id;

  EXECUTE 'UPDATE public.wallets 
           SET balance = balance - $1,
               hold_balance = hold_balance + $1
           WHERE id = $2'
  USING amount, wallet_id;

  EXECUTE 'UPDATE public.payments
           SET status = 2
           WHERE id = $1'
  USING payment_id;
END LOOP;
END;
$_$;


--
-- Name: mark_as_sent_and_release_hold(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_as_sent_and_release_hold(payment_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
  amount bigint;
  wallet_id integer;
BEGIN

  EXECUTE 'SELECT wallet_id, amount + fee FROM public.payments WHERE id = $1'
  INTO wallet_id, amount
  USING payment_id;

  EXECUTE 'UPDATE public.wallets 
           SET hold_balance = hold_balance - $1
           WHERE id = $2'
  USING amount, wallet_id;

  EXECUTE 'UPDATE public.payments
           SET status = 2
           WHERE id = $1'
  USING payment_id;

  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
  VALUES (wallet_id,
          format('Release hold %s for already sent payment %s', amount, payment_id),
          (SELECT balance FROM public.wallets WHERE id = wallet_id),
          (SELECT hold_balance FROM public.wallets WHERE id = wallet_id),
          format('Sent payments release'));
END;
$_$;


--
-- Name: move_money(integer, integer, public.cryptocurrency_code, numeric, text, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.move_money(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_from integer;
  wallet_to integer;

BEGIN
  SELECT id
  FROM public.wallet
  WHERE user_id = user_from
    AND cc_code = cc
  INTO wallet_from;

  SELECT id
  FROM public.wallet
  WHERE user_id = user_to
    AND cc_code = cc
  INTO wallet_to;

  UPDATE public.wallet
  SET balance = balance - amount
  WHERE id = wallet_from;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet_from,
    (SELECT balance FROM public.wallet WHERE id = wallet_from),
    (SELECT hold_balance FROM public.wallet WHERE id = wallet_from),
    cause,
    amount,
    cc,
    'direct',
    'outgoing',
    platform
  );

  UPDATE public.wallet
  SET balance = balance + amount
  WHERE id = wallet_to;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet_to,
    (SELECT balance FROM public.wallet WHERE id = wallet_to),
    (SELECT hold_balance FROM public.wallet WHERE id = wallet_to),
    cause,
    amount,
    cc,
    'direct',
    'incoming',
    platform
  );
END;
$$;


--
-- Name: move_money(integer, integer, public.cryptocurrency_code, numeric, text, p2p.operation_source, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.move_money(user_from integer, user_to integer, cc public.cryptocurrency_code, amount numeric, cause text, source_type p2p.operation_source, platform character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
  wallet_from integer;
  wallet_to integer;

BEGIN
  SELECT id
  FROM public.wallets
  WHERE user_id = user_from
    AND cc_code = cc
  INTO wallet_from;

  SELECT id
  FROM public.wallets
  WHERE user_id = user_to
    AND cc_code = cc
  INTO wallet_to;

  UPDATE public.wallets
  SET balance = balance - amount
  WHERE id = wallet_from;

  INSERT INTO p2p.wallet_log(
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet_from,
    (SELECT balance FROM public.wallets WHERE id = wallet_from),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_from),
    cause,
    amount,
    cc,
    source_type,
    'outgoing',
    platform
  );

  UPDATE public.wallets
  SET balance = balance + amount
  WHERE id = wallet_to;

  INSERT INTO p2p.wallet_log (
    wallet_id,
    balance_at_the_moment,
    hold_balance_at_moment,
    cause,
    amount,
    currency,
    source_type,
    operation_type,
    platform
  ) VALUES (
    wallet_to,
    (SELECT balance FROM public.wallets WHERE id = wallet_to),
    (SELECT hold_balance FROM public.wallets WHERE id = wallet_to),
    cause,
    amount,
    cc,
    source_type,
    'incoming',
    platform
  );
END;
$$;


--
-- Name: null_txids_for_internal_txes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.null_txids_for_internal_txes() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  tx_id character varying(128);
BEGIN

FOR tx_id IN SELECT txid
            FROM public.transactions
            GROUP BY txid HAVING count(*)>1 LOOP

  UPDATE public.transactions
  SET txid='-'||tx_id
  WHERE txid=tx_id AND category=1;
END LOOP;

END;
$$;


--
-- Name: register_dispute_video(public.text_code, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.register_dispute_video(p_admin_code public.text_code, p_dispute_id integer, p_file_name character varying, OUT r_local_file_name text) RETURNS text
    LANGUAGE sql
    SET search_path TO 'public', 'p2p'
    AS $$
insert into dispute_video (id, admin_code, dispute_id, file_name)
select nextval(s), p_admin_code, p_dispute_id, currval(s) || '.' || p_file_name
from pg_get_serial_sequence('dispute_video', 'id') s
returning file_name;
$$;


--
-- Name: release_banned_balances(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.release_banned_balances() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  wallet RECORD;
  system_uid integer;
BEGIN

SELECT id
FROM public.users
WHERE username = 'system'
INTO system_uid;

FOR wallet IN SELECT wallets.id,
                     wallets.currency,
                     wallets.balance,
                     wallets.hold_balance
              FROM public.wallets
              INNER JOIN p2p.user_profile
                      ON public.wallets.user_id = p2p.user_profile.user_id
              WHERE p2p.user_profile.blocked_by_admin = true
                AND (public.wallets.balance != 0 OR public.wallets.hold_balance != 0) LOOP

    UPDATE public.wallets
    SET balance = 0,
        hold_balance = 0
    WHERE id = wallet.id;

--  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
--  VALUES (wallet.id,
--          format('Withdraw from wallet balance %s + %s (hold_balance) in satoshi', wallet.balance, wallet.hold_balance),
--          0,
--          0,
--          format('Releasing balances of blocked user wallet_id %s', wallet.id));
    INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment)
    VALUES (wallet.id,
            format('Withdraw from wallet balance %s + %s (hold_balance) in satoshi', wallet.balance, wallet.hold_balance),
            0,
            0);

    UPDATE public.wallets
    SET balance = balance + wallet.balance + wallet.hold_balance
    WHERE user_id = system_uid
      AND currency = wallet.currency;

--  INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment, cause)
--  VALUES (wallet.id,
--          format('Add to wallet balance %s and hold_balance %s in satoshi', wallet.balance, wallet.hold_balance),
--          (SELECT balance FROM public.wallets WHERE user_id = system_uid AND currency = wallet.currency),
--          (SELECT hold_balance FROM public.wallets WHERE user_id = system_uid AND currency = wallet.currency),
--          format('Releasing balances of blocked user wallet_id %s', wallet.id));
    INSERT INTO p2p.wallet_log (wallet_id, description, balance_at_the_moment, hold_balance_at_moment)
    VALUES (wallet.id,
            format('Add to wallet balance %s and hold_balance %s in satoshi', wallet.balance, wallet.hold_balance),
            (SELECT balance FROM public.wallets WHERE user_id = system_uid AND currency = wallet.currency),
            (SELECT hold_balance FROM public.wallets WHERE user_id = system_uid AND currency = wallet.currency));

END LOOP;

END;
$$;


--
-- Name: first(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.first(anyelement) (
    SFUNC = public.first_agg,
    STYPE = anyelement
);


--
-- Name: last(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.last(anyelement) (
    SFUNC = public.last_agg,
    STYPE = anyelement
);


--
-- Name: rate; Type: TABLE; Schema: p2p; Owner: -
--

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


--
-- Name: cryptocurrency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cryptocurrency (
    code character varying(4) NOT NULL,
    name character varying(256) NOT NULL,
    scale smallint DEFAULT 8 NOT NULL,
    weight smallint NOT NULL,
    CONSTRAINT cryptocurrency_code_check CHECK ((length((code)::text) > 0)),
    CONSTRAINT cryptocurrency_name_check CHECK ((length((name)::text) > 0))
);


--
-- Name: admin_file_uploaded; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.admin_file_uploaded (
    from_user integer NOT NULL,
    trade_id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    for_dispute boolean DEFAULT false NOT NULL,
    caption text
);


--
-- Name: admin_file_uploded_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.admin_file_uploded_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_file_uploded_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.admin_file_uploded_id_seq OWNED BY p2p.admin_file_uploaded.id;


--
-- Name: ads_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.ads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.ads_id_seq OWNED BY p2p.ad.id;


--
-- Name: audit; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.audit (
    id integer NOT NULL,
    date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    audit_json jsonb NOT NULL
);


--
-- Name: audit_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.audit_id_seq OWNED BY p2p.audit.id;


--
-- Name: backup$wallet_log; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p."backup$wallet_log" (
    id integer NOT NULL,
    wallet_id integer NOT NULL,
    description text,
    balance_at_the_moment bigint NOT NULL,
    hold_balance_at_moment bigint NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    cause text,
    currency character varying(10),
    amount numeric,
    source_type p2p.operation_source,
    source_id integer,
    operation_type p2p.operation_type,
    platform character varying(10)
);


--
-- Name: cryptocurrency_settings; Type: TABLE; Schema: p2p; Owner: -
--

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


--
-- Name: COLUMN cryptocurrency_settings.min_acceptable_deposit; Type: COMMENT; Schema: p2p; Owner: -
--

COMMENT ON COLUMN p2p.cryptocurrency_settings.min_acceptable_deposit IS 'Prevent deposits of dust (too small amounts)';


--
-- Name: trade_statistic; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.trade_statistic (
    user_id integer NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    total_count integer DEFAULT 0 NOT NULL,
    total_amount public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    success_deals integer DEFAULT 0 NOT NULL,
    canceled_deals integer DEFAULT 0 NOT NULL,
    defeat_in_dispute integer DEFAULT 0 NOT NULL,
    positive_feedbacks_count integer DEFAULT 0 NOT NULL,
    negative_feedbacks_count integer DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    bought public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    sold public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    deposit public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    withdrawal public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    saved_by_free_trade public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    saved_by_wvouchers public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    CONSTRAINT trade_statistic_bought_check CHECK (((bought)::numeric >= (0)::numeric)),
    CONSTRAINT trade_statistic_deposit_check CHECK (((deposit)::numeric >= (0)::numeric)),
    CONSTRAINT trade_statistic_saved_by_free_trade_check CHECK (((saved_by_free_trade)::numeric >= (0)::numeric)),
    CONSTRAINT trade_statistic_saved_by_wvouchers_check CHECK (((saved_by_wvouchers)::numeric >= (0)::numeric)),
    CONSTRAINT trade_statistic_sold_check CHECK (((sold)::numeric >= (0)::numeric)),
    CONSTRAINT trade_statistic_success_deals_check CHECK ((success_deals >= 0)),
    CONSTRAINT trade_statistic_total_count_check CHECK ((total_count >= 0)),
    CONSTRAINT trade_statistic_withdrawal_check CHECK (((withdrawal)::numeric >= (0)::numeric))
);


--
-- Name: user_profile; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_profile (
    id integer NOT NULL,
    lang character varying(2) NOT NULL,
    user_id integer NOT NULL,
    currency character varying(5) NOT NULL,
    cryptocurrency character varying(256) NOT NULL,
    start_of_use_date timestamp without time zone DEFAULT now(),
    rating numeric NOT NULL,
    lastactivity timestamp without time zone DEFAULT now() NOT NULL,
    blocked_by_admin boolean DEFAULT false NOT NULL,
    old_trade_status p2p.user_trade_status DEFAULT 'pause'::p2p.user_trade_status NOT NULL,
    cancreateadvert_status boolean,
    cancreateadvert_reason p2p.advert_creating_block_reason,
    verified boolean DEFAULT false NOT NULL,
    about_user text DEFAULT ''::text,
    telegram_name character varying,
    user_info text,
    licensing_agreement_accepted boolean DEFAULT false NOT NULL,
    greeting text,
    safe_mode_enabled boolean DEFAULT true NOT NULL,
    pass_safety_wizard boolean DEFAULT false NOT NULL,
    suspicious boolean DEFAULT false NOT NULL,
    copilka numeric,
    merged boolean DEFAULT false NOT NULL,
    public_name character varying(28),
    lang_web character varying(2),
    verification_date timestamp without time zone,
    accept_marketing_emails boolean DEFAULT true NOT NULL,
    generated_name character varying(28) NOT NULL,
    phone character varying(20),
    is_muted boolean DEFAULT false NOT NULL,
    timezone character varying(100),
    pass_merge_wizard boolean DEFAULT false NOT NULL,
    "safetyIndex_modifier" integer DEFAULT 0 NOT NULL,
    avatar character varying(40),
    self_frozen boolean DEFAULT false NOT NULL,
    CONSTRAINT user_profile_generated_name_check CHECK ((length((generated_name)::text) > 0)),
    CONSTRAINT user_profile_public_name_check CHECK ((length((public_name)::text) > 0))
)
WITH (fillfactor='85', autovacuum_enabled='on', autovacuum_vacuum_cost_delay='20');


--
-- Name: user_cryptocurrency_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_cryptocurrency_settings (
    user_id integer NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    trading_enabled boolean DEFAULT true NOT NULL
);


--
-- Name: buy_ads_mview; Type: MATERIALIZED VIEW; Schema: p2p; Owner: -
--

CREATE MATERIALIZED VIEW p2p.buy_ads_mview
WITH (fillfactor='70') AS
 WITH btc_min_ad_amount AS (
         SELECT cryptocurrency_settings.minimum_ad_enabled_amount AS amount
           FROM p2p.cryptocurrency_settings
          WHERE ((cryptocurrency_settings.code)::text = 'BTC'::text)
        )
 SELECT ad.id AS aid,
    ad.cc_code,
    pm.currency,
    ad.min_amount,
    ad.max_amount,
    ad.rate_value,
    pm.id AS pid,
    pm.i18n,
    pm.description,
    ad.user_id,
    up.lastactivity,
    up.verified,
    (up.verified AND (NOT up.suspicious)) AS is_it_safe,
    ad.max_limit_for_new_trader,
    w.balance,
    ad.verified_only,
    (((up.start_of_use_date + '2 mons'::interval) < now()) AND (stat.success_deals >= 20) AND ((stat.turnover >= (ccs.mature_trader_min_turnover)::numeric) OR (ccs.mature_trader_min_turnover IS NULL))) AS is_mature,
    up.start_of_use_date
   FROM ((((((((((p2p.ad
     CROSS JOIN btc_min_ad_amount)
     JOIN public.cryptocurrency cc ON (((cc.code)::text = (ad.cc_code)::text)))
     JOIN p2p.cryptocurrency_settings ccs ON ((((ccs.code)::text = (ad.cc_code)::text) AND ccs.trades_enabled AND (NOT ccs.is_delisted) AND (NOT ccs.is_shitcoin))))
     JOIN public.user_cryptocurrency_settings uccs ON ((((uccs.cc_code)::text = (cc.code)::text) AND (uccs.user_id = ad.user_id) AND uccs.trading_enabled)))
     JOIN p2p.payment_method pm ON ((pm.id = ad.paymethod)))
     JOIN p2p.user_profile up ON (((up.user_id = ad.user_id) AND (NOT up.blocked_by_admin) AND (NOT up.is_muted))))
     JOIN p2p.rate r ON ((((r.cc_code)::text = (ad.cc_code)::text) AND r.default_rate AND ((r.currency_symbol)::text = (pm.currency)::text))))
     JOIN public.wallet btcw ON (((btcw.user_id = ad.user_id) AND ((btcw.cc_code)::text = 'BTC'::text))))
     JOIN public.wallet w ON (((w.user_id = ad.user_id) AND ((w.cc_code)::text = (cc.code)::text))))
     CROSS JOIN LATERAL ( SELECT sum(trade_statistic.success_deals) AS success_deals,
            sum((trade_statistic.total_amount)::numeric) FILTER (WHERE ((trade_statistic.cc_code)::text = (ad.cc_code)::text)) AS turnover
           FROM p2p.trade_statistic
          WHERE (trade_statistic.user_id = ad.user_id)) stat)
  WHERE ((ad.deleted_at IS NULL) AND (ad.status = 'active'::p2p.ads_status) AND (ad.type = 'purchase'::p2p.ads_type) AND ((ad.rate_value >= (r.value * 0.5)) AND (ad.rate_value <= (r.value * 1.5))) AND ((((btcw.balance)::numeric + (btcw.hold_balance)::numeric) >= (btc_min_ad_amount.amount)::numeric) OR (((w.balance)::numeric + (w.hold_balance)::numeric) >= (ccs.minimum_ad_enabled_amount)::numeric)))
  WITH NO DATA;


--
-- Name: buy_ads_view; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.buy_ads_view AS
 SELECT buy_ads_mview.aid,
    buy_ads_mview.cc_code,
    buy_ads_mview.currency,
    buy_ads_mview.min_amount,
    buy_ads_mview.max_amount,
    buy_ads_mview.rate_value,
    buy_ads_mview.pid,
    buy_ads_mview.i18n,
    buy_ads_mview.description,
    buy_ads_mview.user_id,
    buy_ads_mview.lastactivity,
    buy_ads_mview.verified,
    buy_ads_mview.is_it_safe,
    buy_ads_mview.max_limit_for_new_trader,
    buy_ads_mview.balance,
    buy_ads_mview.verified_only,
    buy_ads_mview.is_mature,
    buy_ads_mview.start_of_use_date
   FROM p2p.buy_ads_mview
  ORDER BY buy_ads_mview.verified DESC, buy_ads_mview.is_mature DESC, buy_ads_mview.rate_value DESC, buy_ads_mview.start_of_use_date, buy_ads_mview.aid DESC;


--
-- Name: cc_settings_backup; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.cc_settings_backup (
    code character varying(256) NOT NULL,
    ref_trader_bonus_percent real,
    trade_comission_percent real,
    hot_wallet_balance numeric,
    cold_wallet_audit_adjust numeric,
    withdrawal_fee_optimal numeric DEFAULT 0.001,
    withdrawal_fee_vip numeric DEFAULT 0.001,
    withdraw_enabled boolean DEFAULT true NOT NULL,
    deposit_enabled boolean DEFAULT true NOT NULL,
    optimal_enabled boolean DEFAULT true NOT NULL,
    vip_enabled boolean DEFAULT true NOT NULL,
    free_enabled boolean DEFAULT false NOT NULL,
    free_trades_enabled boolean DEFAULT false NOT NULL,
    min_withdrawal numeric DEFAULT 0 NOT NULL,
    is_token boolean DEFAULT false NOT NULL,
    ref_ad_bonus_percent real,
    pay_many_stack integer DEFAULT 1 NOT NULL,
    minimum_ad_enabled_amount numeric DEFAULT 0 NOT NULL,
    real_cold_wallet_balance numeric DEFAULT 0,
    freeze_amount numeric DEFAULT '1'::numeric NOT NULL,
    trades_enabled boolean DEFAULT true NOT NULL,
    is_shitcoin boolean DEFAULT false NOT NULL,
    is_delisted boolean DEFAULT false NOT NULL,
    has_cold_wallet boolean DEFAULT false NOT NULL,
    cold_wallet_balance_updated_at timestamp without time zone,
    bot_name character varying(126),
    blockchain_url character varying(126),
    hot_wallet_unconfirmed_balance numeric,
    CONSTRAINT cryptocurrency_settings_check CHECK (((NOT is_delisted) OR (NOT (trades_enabled OR withdraw_enabled OR deposit_enabled))))
);


--
-- Name: chat; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.chat (
    id integer NOT NULL,
    author_id integer NOT NULL,
    text text,
    trade_id integer,
    "to" integer[],
    to_admin boolean DEFAULT false NOT NULL,
    from_admin boolean DEFAULT false NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    admin_file_uploaded_id integer
)
WITH (fillfactor='85');


--
-- Name: chat_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.chat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.chat_id_seq OWNED BY p2p.chat.id;


--
-- Name: config; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.config (
    name character varying(100) NOT NULL,
    value character varying(50) NOT NULL
);


--
-- Name: config_maintenance; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.config_maintenance (
    name character varying(50) NOT NULL,
    status boolean NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: cryptocurrency_rate_source; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.cryptocurrency_rate_source (
    cc_code public.cryptocurrency_code NOT NULL,
    rate_source_code character varying(63) NOT NULL,
    priority smallint NOT NULL,
    CONSTRAINT cryptocurrency_rate_source_priority_check CHECK ((priority > 0))
);


--
-- Name: currency; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.currency (
    symbol character varying(5) NOT NULL,
    name character varying(70) NOT NULL,
    sign character varying(3) NOT NULL,
    free_trade_enabled boolean DEFAULT false NOT NULL,
    max_commission_sum numeric DEFAULT 200000 NOT NULL
);


--
-- Name: debt; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.debt (
    id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    sum public.cryptocurrency_amount NOT NULL,
    done boolean NOT NULL,
    wallet_id integer NOT NULL,
    admin_code public.text_code NOT NULL,
    comment text,
    banuser boolean DEFAULT false NOT NULL,
    execution_date timestamp without time zone,
    action character varying(32),
    action_date timestamp without time zone,
    action_admin_code public.text_code,
    CONSTRAINT debts_sum_check CHECK (((sum)::numeric > (0)::numeric))
);


--
-- Name: debts_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.debts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: debts_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.debts_id_seq OWNED BY p2p.debt.id;


--
-- Name: deep_link_action; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.deep_link_action (
    id integer NOT NULL,
    action p2p.deep_link_action_type NOT NULL
);


--
-- Name: deep_link_action_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.deep_link_action_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deep_link_action_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.deep_link_action_id_seq OWNED BY p2p.deep_link_action.id;


--
-- Name: deep_link_referal_action; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.deep_link_referal_action (
    deep_link_action_id integer NOT NULL,
    parent_user_id integer NOT NULL
);


--
-- Name: deeplink_utm; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.deeplink_utm (
    code character varying(32) NOT NULL,
    utm_json jsonb NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: dispute; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.dispute (
    id integer NOT NULL,
    trade_id integer NOT NULL,
    seller_id integer NOT NULL,
    buyer_id integer NOT NULL,
    seller_reason text,
    admin_code public.text_code,
    chat_id integer,
    opened_at timestamp without time zone NOT NULL,
    closed_at timestamp without time zone,
    resolution p2p.trade_state,
    buyer_reason text,
    resolution_reason text,
    comment_admin text,
    refund boolean,
    reopened boolean DEFAULT false,
    fine_payer integer
);


--
-- Name: dispute_decision; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.dispute_decision (
    id integer NOT NULL,
    trade_id integer NOT NULL,
    commentary text NOT NULL,
    type p2p.dispute_decisions_type NOT NULL,
    active boolean DEFAULT true NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    dispute_id integer,
    admin_code public.text_code NOT NULL
);


--
-- Name: dispute_decisions_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.dispute_decisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dispute_decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.dispute_decisions_id_seq OWNED BY p2p.dispute_decision.id;


--
-- Name: dispute_video; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.dispute_video (
    id integer NOT NULL,
    dispute_id integer NOT NULL,
    file_name character varying(64) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    admin_code public.text_code NOT NULL
);


--
-- Name: dispute_video_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.dispute_video_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dispute_video_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.dispute_video_id_seq OWNED BY p2p.dispute_video.id;


--
-- Name: disputes_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.disputes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disputes_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.disputes_id_seq OWNED BY p2p.dispute.id;


--
-- Name: dust_aggregation; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.dust_aggregation (
    id integer NOT NULL,
    tx_id character varying(126) NOT NULL,
    status p2p.dust_aggregation_status DEFAULT 'dust_collected'::p2p.dust_aggregation_status NOT NULL,
    confirmation_block integer,
    confirmation_time timestamp without time zone,
    category p2p.dust_category NOT NULL,
    count_inputs integer NOT NULL,
    sum_inputs public.cryptocurrency_amount NOT NULL,
    sum_outputs public.cryptocurrency_amount NOT NULL,
    fee public.cryptocurrency_amount NOT NULL,
    fee_rate public.cryptocurrency_amount NOT NULL,
    address_collector character varying(126) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    settled_at timestamp without time zone,
    CONSTRAINT dust_aggregation_check CHECK (((settled_at IS NOT NULL) = (status = 'fee_settled'::p2p.dust_aggregation_status))),
    CONSTRAINT dust_aggregation_count_inputs_check CHECK ((count_inputs > 0)),
    CONSTRAINT dust_aggregation_fee_check CHECK (((fee)::numeric >= (0)::numeric)),
    CONSTRAINT dust_aggregation_fee_rate_check CHECK (((fee_rate)::numeric >= (0)::numeric)),
    CONSTRAINT dust_aggregation_sum_inputs_check CHECK (((sum_inputs)::numeric > (0)::numeric)),
    CONSTRAINT dust_aggregation_sum_outputs_check CHECK (((sum_outputs)::numeric > (0)::numeric))
);


--
-- Name: dust_aggregation_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

ALTER TABLE p2p.dust_aggregation ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME p2p.dust_aggregation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: feature; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.feature (
    code character varying(63) NOT NULL,
    description text NOT NULL,
    required_feature_code character varying(63),
    CONSTRAINT features_check CHECK (((code)::text <> (required_feature_code)::text))
);


--
-- Name: feedback; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.feedback (
    id integer NOT NULL,
    user_id integer NOT NULL,
    type p2p.feedback_type NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    trade_id integer,
    for_user_id integer,
    date timestamp without time zone
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.feedbacks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.feedbacks_id_seq OWNED BY p2p.feedback.id;


--
-- Name: forbidden_public_name; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.forbidden_public_name (
    name text NOT NULL
);


--
-- Name: identity_verification_attempt; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.identity_verification_attempt (
    user_id integer NOT NULL,
    at timestamp without time zone NOT NULL,
    success boolean NOT NULL,
    comment character varying
);


--
-- Name: lang; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.lang (
    code character varying(2) NOT NULL,
    description character varying(256) NOT NULL
);


--
-- Name: merge; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.merge (
    web_account_user_id integer NOT NULL,
    telegram_account_user_id integer NOT NULL,
    date_of_merge timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone,
    CONSTRAINT merges_check CHECK ((deleted_at > date_of_merge))
);


--
-- Name: merge_token; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.merge_token (
    id bigint NOT NULL,
    expired_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    token character varying(512) NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: merge_tokens_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.merge_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merge_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.merge_tokens_id_seq OWNED BY p2p.merge_token.id;


--
-- Name: muted_user; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.muted_user (
    id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    admin_code public.text_code NOT NULL,
    user_id integer NOT NULL,
    duration_hrs integer NOT NULL,
    reason text NOT NULL,
    expiry timestamp without time zone NOT NULL,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: muted_users_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.muted_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: muted_users_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.muted_users_id_seq OWNED BY p2p.muted_user.id;


--
-- Name: notebook; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.notebook (
    id integer NOT NULL,
    user_id integer NOT NULL,
    cryptocurrency character varying(8) NOT NULL,
    address character varying(800) NOT NULL,
    description character varying(255) NOT NULL,
    is_actual boolean NOT NULL
);


--
-- Name: notebook_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.notebook_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notebook_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.notebook_id_seq OWNED BY p2p.notebook.id;


--
-- Name: notification; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.notification (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    data_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    receiver_user_id integer NOT NULL,
    unread boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: notification_token; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.notification_token (
    user_id integer NOT NULL,
    token text NOT NULL,
    device_id text NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.notifications_id_seq OWNED BY p2p.notification.id;


--
-- Name: old_data_profile; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.old_data_profile (
    id integer NOT NULL,
    user_id integer NOT NULL,
    btc_amount numeric NOT NULL,
    btc_count integer NOT NULL
);


--
-- Name: old_data_profile_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.old_data_profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: old_data_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.old_data_profile_id_seq OWNED BY p2p.old_data_profile.id;


--
-- Name: payment_group; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.payment_group (
    id integer NOT NULL,
    label text NOT NULL,
    weight integer DEFAULT 0 NOT NULL
);


--
-- Name: payment_group_multilang; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.payment_group_multilang (
    id integer NOT NULL,
    payments_group_id integer NOT NULL,
    lang_code character varying(32) NOT NULL,
    label text NOT NULL
);


--
-- Name: payment_list_precalculation; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.payment_list_precalculation (
    payment_method_id integer NOT NULL,
    best_rate numeric NOT NULL,
    ads_count integer NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    description text NOT NULL,
    currency character(4) NOT NULL,
    trade_amount numeric NOT NULL,
    ads_type p2p.ads_type NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    payment_group integer DEFAULT 1 NOT NULL,
    best_rate_safe numeric NOT NULL,
    i18n jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: payment_method_global; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.payment_method_global (
    id integer NOT NULL,
    label character varying(255) NOT NULL,
    payments_group integer NOT NULL
);


--
-- Name: payment_method_global_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.payment_method_global_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_method_global_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.payment_method_global_id_seq OWNED BY p2p.payment_method_global.id;


--
-- Name: payment_method_hist; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.payment_method_hist (
    id integer NOT NULL,
    admin_code public.text_code NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: payment_method_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.payment_method_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_method_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.payment_method_id_seq OWNED BY p2p.payment_method.id;


--
-- Name: payments_group_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.payments_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_group_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.payments_group_id_seq OWNED BY p2p.payment_group.id;


--
-- Name: payments_group_multilang_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.payments_group_multilang_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_group_multilang_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.payments_group_multilang_id_seq OWNED BY p2p.payment_group_multilang.id;


--
-- Name: rate_fiat; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.rate_fiat (
    value numeric NOT NULL,
    url text NOT NULL,
    description text NOT NULL,
    symbol1 character varying(5) NOT NULL,
    symbol2 character varying(256) NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT rates_fiat_value_check CHECK ((value > (0)::numeric))
);


--
-- Name: rate_plan_withdraw; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.rate_plan_withdraw (
    cc_code character varying NOT NULL,
    act_during tsrange NOT NULL,
    op_amount numrange NOT NULL,
    fee_amount public.cryptocurrency_amount NOT NULL,
    CONSTRAINT rate_plan_withdraw_fee_amount_check CHECK (((fee_amount)::numeric >= (0)::numeric)),
    CONSTRAINT rate_plan_withdraw_op_amount_check CHECK ((op_amount <@ '[0,)'::numrange))
);


--
-- Name: rate_source; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.rate_source (
    code character varying(63) NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL
);


--
-- Name: rates_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rates_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.rates_id_seq OWNED BY p2p.rate.id;


--
-- Name: rating_change_log; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.rating_change_log (
    id integer NOT NULL,
    value numeric NOT NULL,
    cause text NOT NULL,
    user_id integer NOT NULL,
    "tradeId" integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: rating_change_log_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.rating_change_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rating_change_log_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.rating_change_log_id_seq OWNED BY p2p.rating_change_log.id;


--
-- Name: referal_bonus; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.referal_bonus (
    id integer NOT NULL,
    referal_id integer NOT NULL,
    crypto_amount public.cryptocurrency_amount NOT NULL,
    trade_id integer,
    date timestamp without time zone DEFAULT now() NOT NULL,
    order_id bigint,
    ref_parent_user_id integer NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL
);


--
-- Name: referal_bonuses_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.referal_bonuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referal_bonuses_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.referal_bonuses_id_seq OWNED BY p2p.referal_bonus.id;


--
-- Name: referral_links_statistic; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.referral_links_statistic (
    id integer NOT NULL,
    user_id integer NOT NULL,
    parent_id integer,
    key_word character varying(100),
    date timestamp without time zone DEFAULT now() NOT NULL,
    url text
);


--
-- Name: referral_links_statistic_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.referral_links_statistic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referral_links_statistic_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.referral_links_statistic_id_seq OWNED BY p2p.referral_links_statistic.id;


--
-- Name: report; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.report (
    code integer NOT NULL,
    description text NOT NULL,
    format character varying(10) NOT NULL
);


--
-- Name: requisite; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.requisite (
    id integer NOT NULL,
    user_id integer NOT NULL,
    paymethod character varying(8) NOT NULL,
    details character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_actual boolean NOT NULL
);


--
-- Name: requisites_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.requisites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requisites_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.requisites_id_seq OWNED BY p2p.requisite.id;


--
-- Name: sell_ads_mview; Type: MATERIALIZED VIEW; Schema: p2p; Owner: -
--

CREATE MATERIALIZED VIEW p2p.sell_ads_mview
WITH (fillfactor='70') AS
 SELECT ad.id AS aid,
    ad.cc_code,
    pm.currency,
    ad.min_amount,
    LEAST(ad.max_amount, (((w.balance)::numeric * ad.rate_value) / ((1)::numeric + (ccs.trade_comission_percent)::numeric))) AS max_amount,
    ad.rate_value,
    pm.id AS pid,
    pm.i18n,
    pm.description,
    ad.user_id,
    up.lastactivity,
    up.verified,
    (up.verified AND (NOT up.suspicious)) AS is_it_safe,
    ad.max_limit_for_new_trader,
    w.balance,
    ad.verified_only,
    up.start_of_use_date
   FROM (((((((p2p.ad
     JOIN p2p.cryptocurrency_settings ccs ON ((((ccs.code)::text = (ad.cc_code)::text) AND ccs.trades_enabled AND (NOT ccs.is_delisted) AND (NOT ccs.is_shitcoin))))
     JOIN public.user_cryptocurrency_settings uccs ON ((((uccs.cc_code)::text = (ccs.code)::text) AND (uccs.user_id = ad.user_id) AND uccs.trading_enabled)))
     JOIN p2p.payment_method pm ON ((pm.id = ad.paymethod)))
     JOIN p2p.user_profile up ON (((up.user_id = ad.user_id) AND (NOT up.blocked_by_admin) AND (NOT up.is_muted))))
     JOIN public.cryptocurrency cc ON (((cc.code)::text = (ad.cc_code)::text)))
     JOIN p2p.rate r ON ((((r.cc_code)::text = (ad.cc_code)::text) AND r.default_rate AND ((r.currency_symbol)::text = (pm.currency)::text))))
     JOIN public.wallet w ON (((w.user_id = ad.user_id) AND ((w.cc_code)::text = (cc.code)::text))))
  WHERE ((ad.deleted_at IS NULL) AND (ad.status = 'active'::p2p.ads_status) AND (ad.type = 'selling'::p2p.ads_type) AND ((ad.rate_value >= (r.value * 0.5)) AND (ad.rate_value <= (r.value * 1.5))) AND ((w.balance)::numeric > ((ad.min_amount / ad.rate_value) * ((1)::numeric + (ccs.trade_comission_percent)::numeric))))
  WITH NO DATA;


--
-- Name: sell_ads_view; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.sell_ads_view AS
 SELECT sell_ads_mview.aid,
    sell_ads_mview.cc_code,
    sell_ads_mview.currency,
    sell_ads_mview.min_amount,
    sell_ads_mview.max_amount,
    sell_ads_mview.rate_value,
    sell_ads_mview.pid,
    sell_ads_mview.i18n,
    sell_ads_mview.description,
    sell_ads_mview.user_id,
    sell_ads_mview.lastactivity,
    sell_ads_mview.verified,
    sell_ads_mview.is_it_safe,
    sell_ads_mview.max_limit_for_new_trader,
    sell_ads_mview.balance,
    sell_ads_mview.verified_only,
    sell_ads_mview.start_of_use_date
   FROM p2p.sell_ads_mview
  ORDER BY sell_ads_mview.verified DESC, sell_ads_mview.rate_value, sell_ads_mview.start_of_use_date, sell_ads_mview.aid DESC;


--
-- Name: stablecoin_trade; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.stablecoin_trade (
    name character varying(20) NOT NULL,
    status p2p.pair_status NOT NULL,
    base character varying(10) NOT NULL,
    quote character varying(10) NOT NULL,
    fee_sell numeric NOT NULL,
    fee_buy numeric NOT NULL,
    max_amount_quote numeric NOT NULL,
    min_amount_quote numeric NOT NULL
);


--
-- Name: trade; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.trade (
    id integer NOT NULL,
    trade_initiator integer NOT NULL,
    crypto_seller integer NOT NULL,
    crypto_buyer integer NOT NULL,
    status p2p.trade_state NOT NULL,
    currency character varying(8) NOT NULL,
    amount numeric NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    cryptoamount public.cryptocurrency_amount NOT NULL,
    details text,
    fee_buyer public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    fee_seller public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    ad_id integer NOT NULL,
    ad_user_id integer NOT NULL,
    ad_rate numeric NOT NULL,
    ad_terms text,
    ad_details text,
    ad_type p2p.ads_type NOT NULL,
    ad_min_amount numeric NOT NULL,
    ad_max_amount numeric NOT NULL,
    ad_paymethod integer NOT NULL,
    timeout integer DEFAULT 0 NOT NULL,
    ref_bonus_paid boolean DEFAULT false,
    first_dispute_notification_shown boolean DEFAULT false,
    comission numeric DEFAULT 0.009 NOT NULL,
    creater_platform character varying(3),
    confirmer_platform character varying(3),
    ad_owner_parent_id integer,
    trade_initiator_parent_id integer,
    ref_bonus_percent numeric,
    status_advanced p2p.trade_status_advanced,
    created_at timestamp without time zone NOT NULL,
    second_dispute_notification_shown boolean DEFAULT false NOT NULL,
    tips_payed boolean DEFAULT false NOT NULL,
    tips_amount numeric,
    CONSTRAINT check_amount CHECK ((amount > (0)::numeric)),
    CONSTRAINT check_cryptoamount CHECK (((cryptoamount)::numeric > (0)::numeric)),
    CONSTRAINT trades_check CHECK (((trade_initiator = crypto_seller) OR (trade_initiator = crypto_buyer)))
);


--
-- Name: trade_history; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.trade_history (
    id integer NOT NULL,
    trade_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    status p2p.trade_state NOT NULL,
    reason text NOT NULL,
    status_advanced p2p.trade_status_advanced
);


--
-- Name: trade_history_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.trade_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_history_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.trade_history_id_seq OWNED BY p2p.trade_history.id;


--
-- Name: trade_statistic_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.trade_statistic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_statistic_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.trade_statistic_id_seq OWNED BY p2p.trade_statistic.id;


--
-- Name: trade_statistic_log; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.trade_statistic_log (
    id integer NOT NULL,
    ts_id integer NOT NULL,
    old_value text NOT NULL,
    new_value text NOT NULL,
    cause text NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    admin_code public.text_code NOT NULL
);


--
-- Name: trade_statistic_log_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.trade_statistic_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_statistic_log_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.trade_statistic_log_id_seq OWNED BY p2p.trade_statistic_log.id;


--
-- Name: trades_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.trades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trades_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.trades_id_seq OWNED BY p2p.trade.id;


--
-- Name: untrusted_user; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.untrusted_user (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reason text NOT NULL,
    date timestamp without time zone NOT NULL,
    admin_code public.text_code NOT NULL,
    active boolean DEFAULT true NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


--
-- Name: untrusted_users_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.untrusted_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: untrusted_users_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.untrusted_users_id_seq OWNED BY p2p.untrusted_user.id;


--
-- Name: user_2fa; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_2fa (
    id integer NOT NULL,
    user_id integer NOT NULL,
    secret character varying(20) NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: user_action_freeze; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_action_freeze (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    freeze_type text NOT NULL,
    reason text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    admin_code public.text_code
);


--
-- Name: user_actions_freeze_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.user_actions_freeze_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_actions_freeze_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.user_actions_freeze_id_seq OWNED BY p2p.user_action_freeze.id;


--
-- Name: user_ad_filter; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_ad_filter (
    user_id integer NOT NULL,
    settings_json jsonb NOT NULL
);


--
-- Name: user_block; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_block (
    id integer NOT NULL,
    user_id integer NOT NULL,
    blocked_user_id integer NOT NULL,
    date timestamp without time zone NOT NULL
);


--
-- Name: user_block_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.user_block_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_block_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.user_block_id_seq OWNED BY p2p.user_block.id;


--
-- Name: user_feature; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_feature (
    user_id integer NOT NULL,
    feature_code character varying(63) NOT NULL
);


--
-- Name: user_note; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_note (
    id integer NOT NULL,
    user_id integer NOT NULL,
    for_user_id integer NOT NULL,
    text text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_notes_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.user_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.user_notes_id_seq OWNED BY p2p.user_note.id;


--
-- Name: user_profile_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.user_profile_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_profile_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.user_profile_id_seq OWNED BY p2p.user_profile.id;


--
-- Name: user_rate; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_rate (
    id integer NOT NULL,
    user_id integer NOT NULL,
    rate_id integer NOT NULL
);


--
-- Name: user_rates_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.user_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.user_rates_id_seq OWNED BY p2p.user_rate.id;


--
-- Name: user_settings; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_settings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    save_requisites boolean DEFAULT true NOT NULL,
    notifications jsonb
);


--
-- Name: user_settings_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.user_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.user_settings_id_seq OWNED BY p2p.user_settings.id;


--
-- Name: user_trust; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.user_trust (
    id integer NOT NULL,
    user_id integer NOT NULL,
    trusted_user_id integer NOT NULL,
    trust boolean NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user_trust_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.user_trust_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_trust_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.user_trust_id_seq OWNED BY p2p.user_trust.id;


--
-- Name: users_2fa_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.users_2fa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_2fa_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.users_2fa_id_seq OWNED BY p2p.user_2fa.id;


--
-- Name: utm_statistic; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.utm_statistic (
    user_id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    utm_source character varying(255) NOT NULL,
    utm_medium character varying(255),
    utm_campaign character varying(255),
    utm_term character varying(255),
    utm_content character varying(255)
);


--
-- Name: voucher; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.voucher (
    id integer NOT NULL,
    secret_key text NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    amount public.cryptocurrency_amount NOT NULL,
    currency character varying(3) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone,
    cashed_at timestamp without time zone,
    user_id integer NOT NULL,
    cashed_by_user_id integer,
    comment text,
    comment_by_cashed_user text,
    CONSTRAINT check_amount CHECK (((amount)::numeric > (0)::numeric))
);


--
-- Name: voucher_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.voucher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: voucher_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.voucher_id_seq OWNED BY p2p.voucher.id;


--
-- Name: vw_audit; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_audit AS
 SELECT a1.id,
    a1.date,
    a1.cryptocurrency,
    a2."totalIn" AS total_in,
    a2."totalOut" AS total_out,
    a2."totalAudit" AS total_audit,
    a2."totalWallets" AS total_wallets,
    a2."coldWalletAdjust" AS cold_wallet_adjust,
    a2."totalBalancesFree" AS total_balances_free,
    a2."systemWalletBalance" AS system_wallet_balance,
    a2."totalBalancesHolded" AS total_balances_holded,
    a2."realColdWalletBalance" AS real_cold_wallet_balance,
    a2."systemHotWalletBalance" AS system_hot_wallet_balance,
    a2."totalWalletsColdAndHot" AS total_wallets_cold_and_hot,
    a2."hotWalletUnconfirmedBalance" AS hot_wallet_unconfirmed_balance,
    a2."pendingPayments" AS pending_payments,
    a2."totalNetworkFee" AS total_network_fee
   FROM (( SELECT a.id,
            a.date,
            (jsonb_each(a.audit_json)).key AS key,
            (jsonb_each(a.audit_json)).value AS value
           FROM ( SELECT a_1.id,
                    a_1.date,
                    a_1.audit_json
                   FROM p2p.audit a_1
                  ORDER BY a_1.id DESC) a) a1(id, date, cryptocurrency, data)
     CROSS JOIN LATERAL ( SELECT jsonb_populate_record."totalIn",
            jsonb_populate_record."totalOut",
            jsonb_populate_record."totalAudit",
            jsonb_populate_record."totalWallets",
            jsonb_populate_record."coldWalletAdjust",
            jsonb_populate_record."totalBalancesFree",
            jsonb_populate_record."systemWalletBalance",
            jsonb_populate_record."totalBalancesHolded",
            jsonb_populate_record."realColdWalletBalance",
            jsonb_populate_record."systemHotWalletBalance",
            jsonb_populate_record."totalWalletsColdAndHot",
            jsonb_populate_record."hotWalletUnconfirmedBalance",
            jsonb_populate_record."pendingPayments",
            jsonb_populate_record."totalNetworkFee"
           FROM jsonb_populate_record(NULL::p2p.audit_rec, a1.data) jsonb_populate_record("totalIn", "totalOut", "totalAudit", "totalWallets", "coldWalletAdjust", "totalBalancesFree", "systemWalletBalance", "totalBalancesHolded", "realColdWalletBalance", "systemHotWalletBalance", "totalWalletsColdAndHot", "hotWalletUnconfirmedBalance", "pendingPayments", "totalNetworkFee")) a2);


--
-- Name: vw_audit_latest; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_audit_latest AS
 SELECT a1.id,
    a1.date,
    a1.cryptocurrency,
    a2."totalIn" AS total_in,
    a2."totalOut" AS total_out,
    a2."totalAudit" AS total_audit,
    a2."totalWallets" AS total_wallets,
    a2."coldWalletAdjust" AS cold_wallet_adjust,
    a2."totalBalancesFree" AS total_balances_free,
    a2."systemWalletBalance" AS system_wallet_balance,
    a2."totalBalancesHolded" AS total_balances_holded,
    a2."realColdWalletBalance" AS real_cold_wallet_balance,
    a2."systemHotWalletBalance" AS system_hot_wallet_balance,
    a2."totalWalletsColdAndHot" AS total_wallets_cold_and_hot,
    a2."hotWalletUnconfirmedBalance" AS hot_wallet_unconfirmed_balance,
    a2."pendingPayments" AS pending_payments,
    a2."totalNetworkFee" AS total_network_fee
   FROM (( SELECT a.id,
            a.date,
            (jsonb_each(a.audit_json)).key AS key,
            (jsonb_each(a.audit_json)).value AS value
           FROM ( SELECT a_1.id,
                    a_1.date,
                    a_1.audit_json
                   FROM p2p.audit a_1
                  ORDER BY a_1.id DESC
                 LIMIT 1) a) a1(id, date, cryptocurrency, data)
     CROSS JOIN LATERAL ( SELECT jsonb_populate_record."totalIn",
            jsonb_populate_record."totalOut",
            jsonb_populate_record."totalAudit",
            jsonb_populate_record."totalWallets",
            jsonb_populate_record."coldWalletAdjust",
            jsonb_populate_record."totalBalancesFree",
            jsonb_populate_record."systemWalletBalance",
            jsonb_populate_record."totalBalancesHolded",
            jsonb_populate_record."realColdWalletBalance",
            jsonb_populate_record."systemHotWalletBalance",
            jsonb_populate_record."totalWalletsColdAndHot",
            jsonb_populate_record."hotWalletUnconfirmedBalance",
            jsonb_populate_record."pendingPayments",
            jsonb_populate_record."totalNetworkFee"
           FROM jsonb_populate_record(NULL::p2p.audit_rec, a1.data) jsonb_populate_record("totalIn", "totalOut", "totalAudit", "totalWallets", "coldWalletAdjust", "totalBalancesFree", "systemWalletBalance", "totalBalancesHolded", "realColdWalletBalance", "systemHotWalletBalance", "totalWalletsColdAndHot", "hotWalletUnconfirmedBalance", "pendingPayments", "totalNetworkFee")) a2);


--
-- Name: blockchain_tx; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blockchain_tx (
    id integer NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    txid character varying(128) NOT NULL,
    network_fee public.cryptocurrency_amount,
    status public.blockchain_tx_status NOT NULL,
    confirmations integer,
    issued_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    source jsonb,
    CONSTRAINT blockchain_tx_check CHECK (((issued_at IS NULL) = (status = 'initial'::public.blockchain_tx_status))),
    CONSTRAINT blockchain_tx_confirmations_check CHECK ((confirmations >= 0)),
    CONSTRAINT blockchain_tx_network_fee_check CHECK (((network_fee)::numeric >= (0)::numeric)),
    CONSTRAINT blockchain_tx_txid_check CHECK ((length((txid)::text) > 0))
);


--
-- Name: deposit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deposit (
    id integer NOT NULL,
    user_id integer,
    wallet_id integer,
    account character varying(100),
    fee public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    address character varying(68) NOT NULL,
    amount public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    blockchain_tx_id integer NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    comment character varying(256),
    vout integer,
    is_dust boolean DEFAULT false NOT NULL,
    cc_code public.cryptocurrency_code NOT NULL,
    status public.deposit_status NOT NULL,
    CONSTRAINT deposit_check CHECK (((status <> 'dust-seizure'::public.deposit_status) OR is_dust))
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
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
    ref_type p2p.referral_type DEFAULT 'independent'::p2p.referral_type NOT NULL,
    authority_can_make_deal boolean DEFAULT true NOT NULL,
    authority_can_make_order boolean DEFAULT true NOT NULL,
    authority_can_make_voucher boolean DEFAULT true NOT NULL,
    authority_can_make_withdrawal boolean DEFAULT true NOT NULL,
    authority_is_admin boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    password_reset_at timestamp without time zone,
    sys_code character varying(63),
    CONSTRAINT user_check CHECK (((sys_code IS NULL) OR ((telegram_id IS NULL) AND (real_email IS NULL) AND (nickname IS NULL)))),
    CONSTRAINT user_sys_code_check CHECK ((length((sys_code)::text) > 0)),
    CONSTRAINT users_check CHECK ((deleted_at > created_at))
);


--
-- Name: COLUMN "user".sys_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."user".sys_code IS 'Special code for system accounts only, must be unique for each system account. Regular users have don''t have such codes.';


--
-- Name: withdrawal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.withdrawal (
    id integer NOT NULL,
    user_id integer NOT NULL,
    wallet_id integer NOT NULL,
    blockchain_tx_id integer,
    address character varying(68) NOT NULL,
    amount public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    fee public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    status public.withdrawal_status NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    comment text,
    real_pay_fee public.cryptocurrency_amount,
    cc_code public.cryptocurrency_code NOT NULL,
    CONSTRAINT check_amount CHECK (((amount)::numeric > (0)::numeric)),
    CONSTRAINT payments_fee_check CHECK (((fee)::numeric >= (0)::numeric)),
    CONSTRAINT withdrawal_check CHECK (((blockchain_tx_id IS NOT NULL) OR (status = ANY (ARRAY['pending'::public.withdrawal_status, 'in_progress'::public.withdrawal_status, 'cancelled_by_admin'::public.withdrawal_status, 'failed'::public.withdrawal_status])))),
    CONSTRAINT withdrawal_real_pay_fee_check CHECK (((real_pay_fee)::numeric >= (0)::numeric))
)
WITH (fillfactor='90', autovacuum_enabled='on', autovacuum_vacuum_cost_delay='20');


--
-- Name: vw_audit_source; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_audit_source AS
 WITH sum_withdrawal AS (
         SELECT p.cc_code AS code,
            sum((p.amount)::numeric) FILTER (WHERE (p.status = 'pending'::public.withdrawal_status)) AS pending_payments,
            sum((p.amount)::numeric) FILTER (WHERE (p.status = ANY (ARRAY['pending'::public.withdrawal_status, 'processed'::public.withdrawal_status, 'in_progress'::public.withdrawal_status]))) AS total_out
           FROM public.withdrawal p
          GROUP BY p.cc_code
        ), sum_btx AS (
         SELECT btx.cc_code,
            sum((btx.network_fee)::numeric) AS total_network_fee
           FROM public.blockchain_tx btx
          WHERE (btx.status = 'confirmed'::public.blockchain_tx_status)
          GROUP BY btx.cc_code
        ), sum_wallets AS (
         SELECT w.cc_code AS code,
            sum((w.balance)::numeric) AS total_balances_free,
            sum((w.hold_balance)::numeric) AS total_balances_holded,
            sum(((w.balance)::numeric + (w.hold_balance)::numeric)) AS total_balances
           FROM public.wallet w
          GROUP BY w.cc_code
        ), sum_deposits AS (
         SELECT t.cc_code AS code,
            sum((t.amount)::numeric) FILTER (WHERE (t.status = 'success'::public.deposit_status)) AS total_in,
            sum((t.amount)::numeric) FILTER (WHERE (t.status = 'dust-seizure'::public.deposit_status)) AS total_dust_in
           FROM public.deposit t
          GROUP BY t.cc_code
        ), system_wallets AS (
         SELECT w.cc_code AS code,
            w.balance AS system_wallet_balance
           FROM public.wallet w
          WHERE (w.user_id = ( SELECT "user".id
                   FROM public."user"
                  WHERE (("user".sys_code)::text = 'system'::text)))
        )
 SELECT ccs.code AS cryptocurrency,
    ccs.real_cold_wallet_balance,
    ccs.hot_wallet_balance,
    ccs.hot_wallet_unconfirmed_balance,
    ccs.cold_wallet_audit_adjust,
    sysw.system_wallet_balance,
    COALESCE(sp.pending_payments, (0)::numeric) AS pending_payments,
    COALESCE(sum_btx.total_network_fee, (0)::numeric) AS total_network_fee,
    COALESCE(sp.total_out, (0)::numeric) AS total_out,
    COALESCE(st.total_in, (0)::numeric) AS total_in,
    COALESCE(st.total_dust_in, (0)::numeric) AS total_dust_in,
    COALESCE(sw.total_balances_free, (0)::numeric) AS total_balances_free,
    COALESCE(sw.total_balances_holded, (0)::numeric) AS total_balances_holded,
    (COALESCE(sw.total_balances, (0)::numeric) + COALESCE(sp.pending_payments, (0)::numeric)) AS total_wallets,
    ccs.debt
   FROM (((((p2p.cryptocurrency_settings ccs
     LEFT JOIN sum_btx ON (((ccs.code)::text = (sum_btx.cc_code)::text)))
     LEFT JOIN sum_withdrawal sp ON (((sp.code)::text = (ccs.code)::text)))
     LEFT JOIN sum_wallets sw ON (((sw.code)::text = (ccs.code)::text)))
     LEFT JOIN sum_deposits st ON (((st.code)::text = (ccs.code)::text)))
     LEFT JOIN system_wallets sysw ON (((sysw.code)::text = (ccs.code)::text)))
  WHERE (NOT ccs.is_delisted);


--
-- Name: vw_audit_watchdog; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_audit_watchdog AS
 SELECT cc.code AS cryptocurrency,
    (s.total_wallets - (((((s.hot_wallet_balance)::numeric + (s.real_cold_wallet_balance)::numeric) + (s.cold_wallet_audit_adjust)::numeric) + d.sum_amnt) + COALESCE((s.hot_wallet_unconfirmed_balance)::numeric, (0)::numeric))) AS balance,
    s.hot_wallet_balance
   FROM ((p2p.cryptocurrency_settings cc
     LEFT JOIN p2p.vw_audit_source s ON (((s.cryptocurrency)::text = (cc.code)::text)))
     CROSS JOIN LATERAL ( SELECT COALESCE(sum((d_1.amount)::numeric), (0)::numeric) AS sum_amnt
           FROM public.deposit d_1
          WHERE (((d_1.cc_code)::text = (cc.code)::text) AND (d_1.updated_at >= (now() - cc.audit_watchdog_deposit_interval)))) d)
  WHERE cc.withdraw_enabled;


--
-- Name: vw_disputes_list; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_disputes_list AS
 WITH islastansweradmin AS (
         SELECT t1_1.trade_id,
            t1_1.from_admin
           FROM ( SELECT t1_2.trade_id,
                    t1_2.from_admin,
                    row_number() OVER (PARTITION BY t1_2.trade_id ORDER BY t1_2.id DESC) AS rn
                   FROM (p2p.chat t1_2
                     JOIN p2p.dispute t2 ON ((t1_2.trade_id = t2.trade_id)))
                  WHERE (t2.resolution IS NULL)) t1_1
          WHERE (t1_1.rn = 1)
        )
 SELECT t1.id,
    t1.trade_id,
    t3.amount,
    t3.currency,
    t1.seller_id,
    t1.buyer_id,
    t1.buyer_reason,
    t1.seller_reason,
    t1.opened_at,
    t1.refund,
    ((CURRENT_TIMESTAMP - (t1.opened_at)::timestamp with time zone))::text AS in_dispute,
    COALESCE(t4.from_admin, false) AS isadminlastmessage
   FROM ((p2p.dispute t1
     LEFT JOIN islastansweradmin t4 ON ((t4.trade_id = t1.trade_id)))
     JOIN p2p.trade t3 ON ((t1.trade_id = t3.id)))
  WHERE ((t1.resolution IS NULL) AND (t1.closed_at IS NULL))
  ORDER BY t1.id DESC
 LIMIT 500;


--
-- Name: vw_inappropriate_ads; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_inappropriate_ads AS
 WITH btc_min_ad_amount AS (
         SELECT cryptocurrency_settings.minimum_ad_enabled_amount AS amount
           FROM p2p.cryptocurrency_settings
          WHERE ((cryptocurrency_settings.code)::text = 'BTC'::text)
        )
 SELECT ad.id,
    ad.user_id
   FROM ((((((((p2p.ad
     CROSS JOIN btc_min_ad_amount)
     JOIN public.cryptocurrency cc ON (((cc.code)::text = (ad.cc_code)::text)))
     JOIN p2p.cryptocurrency_settings ccs ON ((((ccs.code)::text = (ad.cc_code)::text) AND ccs.trades_enabled AND (NOT ccs.is_delisted) AND (NOT ccs.is_shitcoin))))
     JOIN public.user_cryptocurrency_settings uccs ON ((((uccs.cc_code)::text = (cc.code)::text) AND (uccs.user_id = ad.user_id) AND uccs.trading_enabled)))
     JOIN p2p.payment_method pm ON ((pm.id = ad.paymethod)))
     JOIN p2p.rate r ON ((((r.cc_code)::text = (ad.cc_code)::text) AND r.default_rate AND ((r.currency_symbol)::text = (pm.currency)::text))))
     JOIN public.wallet btcw ON (((btcw.user_id = ad.user_id) AND ((btcw.cc_code)::text = 'BTC'::text))))
     JOIN public.wallet w ON (((w.user_id = ad.user_id) AND ((w.cc_code)::text = (cc.code)::text))))
  WHERE ((ad.deleted_at IS NULL) AND (ad.status = 'active'::p2p.ads_status) AND (false OR (ad.rate_value < (r.value * 0.5)) OR (ad.rate_value > (r.value * 1.5)) OR (true AND (ad.type = 'purchase'::p2p.ads_type) AND (NOT (((btcw.balance)::numeric + (btcw.hold_balance)::numeric) >= (btc_min_ad_amount.amount)::numeric)) AND (NOT (((w.balance)::numeric + (w.hold_balance)::numeric) >= (ccs.minimum_ad_enabled_amount)::numeric))) OR (true AND (ad.type = 'selling'::p2p.ads_type) AND (NOT ((w.balance)::numeric > ((ad.min_amount / ad.rate_value) * ((1)::numeric + (ccs.trade_comission_percent)::numeric)))))));


--
-- Name: vw_user_notification_alarm_mode; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_user_notification_alarm_mode AS
 SELECT a.user_id,
    a.notification_code,
    regexp_split_to_array(a.value, ','::text) AS alarm_mode
   FROM ( SELECT us.user_id,
            (jsonb_each_text(us.notifications)).key AS key,
            (jsonb_each_text(us.notifications)).value AS value
           FROM p2p.user_settings us
          WHERE (us.notifications IS NOT NULL)) a(user_id, notification_code, value)
  WHERE (a.value IS NOT NULL);


--
-- Name: vw_user_voucher; Type: VIEW; Schema: p2p; Owner: -
--

CREATE VIEW p2p.vw_user_voucher AS
 SELECT v.secret_key,
    v.cc_code,
    v.amount,
    v.currency,
    v.created_at,
    v.cashed_at,
    v.user_id,
    v.cashed_by_user_id,
    round(((v.amount)::numeric * p2p.remote_rate_value(u.user_id, u.currency, v.cc_code)), 8) AS fiat_amount,
    (
        CASE
            WHEN (v.cashed_at IS NULL) THEN 'active'::text
            ELSE 'cashed'::text
        END)::p2p.voucher_status_type AS status,
        CASE
            WHEN (v.user_id = u.user_id) THEN v.comment
            ELSE v.comment_by_cashed_user
        END AS comment,
    u.user_id AS voucher_user_id
   FROM (p2p.voucher v
     JOIN p2p.user_profile u ON (((v.user_id = u.user_id) OR (v.cashed_by_user_id = u.user_id))))
  WHERE (v.deleted_at IS NULL)
  ORDER BY v.created_at DESC;


--
-- Name: wallet_log; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.wallet_log (
    wallet_id integer NOT NULL,
    description character varying(100),
    balance_at_the_moment public.cryptocurrency_amount NOT NULL,
    hold_balance_at_moment public.cryptocurrency_amount NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    cause character varying(200),
    currency public.cryptocurrency_code NOT NULL,
    amount public.cryptocurrency_amount NOT NULL,
    source_type p2p.operation_source,
    source_id integer,
    operation_type p2p.operation_type,
    platform character varying(10)
);


--
-- Name: wallet_log_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.wallet_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wallet_log_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.wallet_log_id_seq OWNED BY p2p."backup$wallet_log".id;


--
-- Name: withdraw_voucher; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.withdraw_voucher (
    id integer NOT NULL,
    user_id integer,
    payment_id integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    used_at timestamp without time zone,
    secret_key text NOT NULL,
    expire_at timestamp without time zone DEFAULT (now() + '1 mon'::interval) NOT NULL,
    first_notification_sent boolean DEFAULT false NOT NULL,
    second_notification_sent boolean DEFAULT false NOT NULL,
    prime_time_event_name character varying(64)
);


--
-- Name: withdraw_voucher_prime_time; Type: TABLE; Schema: p2p; Owner: -
--

CREATE TABLE p2p.withdraw_voucher_prime_time (
    name character varying(63) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    from_hour smallint,
    to_hour smallint,
    monday boolean DEFAULT true NOT NULL,
    tuesday boolean DEFAULT true NOT NULL,
    wednesday boolean DEFAULT true NOT NULL,
    thursday boolean DEFAULT true NOT NULL,
    friday boolean DEFAULT true NOT NULL,
    saturday boolean DEFAULT true NOT NULL,
    sunday boolean DEFAULT true NOT NULL,
    min_amount public.cryptocurrency_amount DEFAULT 0 NOT NULL,
    start_at timestamp without time zone DEFAULT now() NOT NULL,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    per_user_limit integer DEFAULT 1 NOT NULL,
    CONSTRAINT withdraw_vouchers_prime_time_check CHECK ((from_hour <= to_hour)),
    CONSTRAINT withdraw_vouchers_prime_time_check1 CHECK ((expires_at > start_at)),
    CONSTRAINT withdraw_vouchers_prime_time_from_hour_check CHECK (((from_hour >= 0) AND (from_hour <= 23))),
    CONSTRAINT withdraw_vouchers_prime_time_from_hour_check1 CHECK (((from_hour >= 0) AND (from_hour <= 23))),
    CONSTRAINT withdraw_vouchers_prime_time_min_amount_check CHECK (((min_amount)::numeric >= (0)::numeric)),
    CONSTRAINT withdraw_vouchers_prime_time_name_check CHECK ((length((name)::text) > 0)),
    CONSTRAINT withdraw_vouchers_prime_time_per_user_limit_check CHECK ((per_user_limit > 0))
);


--
-- Name: withdraw_vouchers_id_seq; Type: SEQUENCE; Schema: p2p; Owner: -
--

CREATE SEQUENCE p2p.withdraw_vouchers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: withdraw_vouchers_id_seq; Type: SEQUENCE OWNED BY; Schema: p2p; Owner: -
--

ALTER SEQUENCE p2p.withdraw_vouchers_id_seq OWNED BY p2p.withdraw_voucher.id;


--
-- Name: account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account (
    id integer NOT NULL,
    kyc_status public.kyc_status DEFAULT 'NONE'::public.kyc_status NOT NULL
);


--
-- Name: account_kyc_hist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_kyc_hist (
    acc_id integer NOT NULL,
    correlation_id character varying(126) NOT NULL,
    provider public.kyc_provider NOT NULL,
    status public.kyc_status NOT NULL,
    source jsonb,
    at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: account_swap_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_swap_log (
    id integer NOT NULL,
    old_user_id integer NOT NULL,
    new_user_id integer NOT NULL,
    cause character varying(512) NOT NULL,
    admin_code public.text_code NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: account_swap_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_swap_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_swap_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_swap_log_id_seq OWNED BY public.account_swap_log.id;


--
-- Name: admin_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_user (
    code public.text_code NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    role public.admin_role DEFAULT 'superuser'::public.admin_role NOT NULL,
    user_id integer
);


--
-- Name: banned_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banned_user (
    user_id integer NOT NULL,
    reason text,
    action public.ban_action NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    admin_code public.text_code NOT NULL
);


--
-- Name: blockchain_tx_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.blockchain_tx ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.blockchain_tx_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event (
    id integer NOT NULL,
    event_type public.event_type NOT NULL,
    entity_type public.entity NOT NULL,
    entity_id integer NOT NULL,
    event_data_json jsonb NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_id_seq OWNED BY public.event.id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


--
-- Name: lock_monitor; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.lock_monitor AS
 SELECT COALESCE(((blockingl.relation)::regclass)::text, blockingl.locktype) AS locked_item,
    (now() - blockeda.query_start) AS waiting_duration,
    blockeda.pid AS blocked_pid,
    blockeda.query AS blocked_query,
    blockedl.mode AS blocked_mode,
    blockinga.pid AS blocking_pid,
    blockinga.query AS blocking_query,
    blockingl.mode AS blocking_mode
   FROM (((pg_locks blockedl
     JOIN pg_stat_activity blockeda ON ((blockedl.pid = blockeda.pid)))
     JOIN pg_locks blockingl ON ((((blockingl.transactionid = blockedl.transactionid) OR ((blockingl.relation = blockedl.relation) AND (blockingl.locktype = blockedl.locktype))) AND (blockedl.pid <> blockingl.pid))))
     JOIN pg_stat_activity blockinga ON (((blockingl.pid = blockinga.pid) AND (blockinga.datid = blockeda.datid))))
  WHERE ((NOT blockedl.granted) AND (blockinga.datname = current_database()));


--
-- Name: withdrawal_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.withdrawal_log (
    id integer NOT NULL,
    withdrawal_id integer NOT NULL,
    log text NOT NULL,
    created_at timestamp(0) without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: payment_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_logs_id_seq OWNED BY public.withdrawal_log.id;


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.withdrawal.id;


--
-- Name: signed_operation_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signed_operation_request (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
PARTITION BY LIST (expires_date);


--
-- Name: signed_operation_request$20211113; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211113" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211113" FOR VALUES IN ('2021-11-13');


--
-- Name: signed_operation_request$20211114; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211114" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211114" FOR VALUES IN ('2021-11-14');


--
-- Name: signed_operation_request$20211115; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211115" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211115" FOR VALUES IN ('2021-11-15');


--
-- Name: signed_operation_request$20211116; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211116" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211116" FOR VALUES IN ('2021-11-16');


--
-- Name: signed_operation_request$20211117; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211117" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211117" FOR VALUES IN ('2021-11-17');


--
-- Name: signed_operation_request$20211118; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211118" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211118" FOR VALUES IN ('2021-11-18');


--
-- Name: signed_operation_request$20211119; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211119" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211119" FOR VALUES IN ('2021-11-19');


--
-- Name: signed_operation_request$20211120; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211120" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211120" FOR VALUES IN ('2021-11-20');


--
-- Name: signed_operation_request$20211121; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211121" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211121" FOR VALUES IN ('2021-11-21');


--
-- Name: signed_operation_request$20211122; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211122" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211122" FOR VALUES IN ('2021-11-22');


--
-- Name: signed_operation_request$20211123; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211123" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211123" FOR VALUES IN ('2021-11-23');


--
-- Name: signed_operation_request$20211124; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211124" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211124" FOR VALUES IN ('2021-11-24');


--
-- Name: signed_operation_request$20211125; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211125" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211125" FOR VALUES IN ('2021-11-25');


--
-- Name: signed_operation_request$20211126; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211126" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211126" FOR VALUES IN ('2021-11-26');


--
-- Name: signed_operation_request$20211127; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211127" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211127" FOR VALUES IN ('2021-11-27');


--
-- Name: signed_operation_request$20211128; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211128" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211128" FOR VALUES IN ('2021-11-28');


--
-- Name: signed_operation_request$20211129; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211129" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211129" FOR VALUES IN ('2021-11-29');


--
-- Name: signed_operation_request$20211130; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211130" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211130" FOR VALUES IN ('2021-11-30');


--
-- Name: signed_operation_request$20211201; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211201" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211201" FOR VALUES IN ('2021-12-01');


--
-- Name: signed_operation_request$20211202; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211202" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211202" FOR VALUES IN ('2021-12-02');


--
-- Name: signed_operation_request$20211203; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211203" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211203" FOR VALUES IN ('2021-12-03');


--
-- Name: signed_operation_request$20211204; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211204" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211204" FOR VALUES IN ('2021-12-04');


--
-- Name: signed_operation_request$20211205; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211205" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211205" FOR VALUES IN ('2021-12-05');


--
-- Name: signed_operation_request$20211206; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211206" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211206" FOR VALUES IN ('2021-12-06');


--
-- Name: signed_operation_request$20211207; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211207" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211207" FOR VALUES IN ('2021-12-07');


--
-- Name: signed_operation_request$20211208; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211208" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211208" FOR VALUES IN ('2021-12-08');


--
-- Name: signed_operation_request$20211209; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211209" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211209" FOR VALUES IN ('2021-12-09');


--
-- Name: signed_operation_request$20211210; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211210" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211210" FOR VALUES IN ('2021-12-10');


--
-- Name: signed_operation_request$20211211; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211211" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211211" FOR VALUES IN ('2021-12-11');


--
-- Name: signed_operation_request$20211212; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211212" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211212" FOR VALUES IN ('2021-12-12');


--
-- Name: signed_operation_request$20211213; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211213" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211213" FOR VALUES IN ('2021-12-13');


--
-- Name: signed_operation_request$20211214; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211214" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211214" FOR VALUES IN ('2021-12-14');


--
-- Name: signed_operation_request$20211215; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211215" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211215" FOR VALUES IN ('2021-12-15');


--
-- Name: signed_operation_request$20211216; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."signed_operation_request$20211216" (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    command character varying(63) NOT NULL,
    params jsonb NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone,
    CONSTRAINT signed_operation_request_check CHECK (((expires_date + expires_time) > issued_at)),
    CONSTRAINT signed_operation_request_check1 CHECK (((expires_date + expires_time) > confirmed_at))
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.signed_operation_request ATTACH PARTITION public."signed_operation_request$20211216" FOR VALUES IN ('2021-12-16');


--
-- Name: signed_operation_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.signed_operation_request ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.signed_operation_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.deposit.id;


--
-- Name: user_auth_pub_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_auth_pub_key (
    user_id integer NOT NULL,
    kid smallint DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    jwk jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(63) DEFAULT 'default'::character varying NOT NULL,
    can_read boolean DEFAULT true NOT NULL,
    can_trade boolean DEFAULT true NOT NULL,
    can_transfer boolean DEFAULT true NOT NULL,
    aud public.oauth_aud DEFAULT 'usr'::public.oauth_aud NOT NULL
);


--
-- Name: user_token_mfa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_token_mfa (
    jwt_hash character varying(64) NOT NULL,
    user_id integer NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    mfa_passed_at timestamp without time zone DEFAULT now() NOT NULL
)
PARTITION BY LIST (expires_date);


--
-- Name: user_token_mfa$20211210; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user_token_mfa$20211210" (
    jwt_hash character varying(64) NOT NULL,
    user_id integer NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    mfa_passed_at timestamp without time zone DEFAULT now() NOT NULL
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.user_token_mfa ATTACH PARTITION public."user_token_mfa$20211210" FOR VALUES IN ('2021-12-10');


--
-- Name: user_token_mfa$20211211; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user_token_mfa$20211211" (
    jwt_hash character varying(64) NOT NULL,
    user_id integer NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    mfa_passed_at timestamp without time zone DEFAULT now() NOT NULL
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.user_token_mfa ATTACH PARTITION public."user_token_mfa$20211211" FOR VALUES IN ('2021-12-11');


--
-- Name: user_token_mfa$20211212; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user_token_mfa$20211212" (
    jwt_hash character varying(64) NOT NULL,
    user_id integer NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    mfa_passed_at timestamp without time zone DEFAULT now() NOT NULL
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.user_token_mfa ATTACH PARTITION public."user_token_mfa$20211212" FOR VALUES IN ('2021-12-12');


--
-- Name: user_token_mfa$20211213; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user_token_mfa$20211213" (
    jwt_hash character varying(64) NOT NULL,
    user_id integer NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    mfa_passed_at timestamp without time zone DEFAULT now() NOT NULL
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.user_token_mfa ATTACH PARTITION public."user_token_mfa$20211213" FOR VALUES IN ('2021-12-13');


--
-- Name: user_token_mfa$20211214; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user_token_mfa$20211214" (
    jwt_hash character varying(64) NOT NULL,
    user_id integer NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    mfa_passed_at timestamp without time zone DEFAULT now() NOT NULL
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.user_token_mfa ATTACH PARTITION public."user_token_mfa$20211214" FOR VALUES IN ('2021-12-14');


--
-- Name: user_token_mfa$20211215; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user_token_mfa$20211215" (
    jwt_hash character varying(64) NOT NULL,
    user_id integer NOT NULL,
    expires_date date NOT NULL,
    expires_time time without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    mfa_passed_at timestamp without time zone DEFAULT now() NOT NULL
)
WITH (autovacuum_enabled='false', fillfactor='100');
ALTER TABLE ONLY public.user_token_mfa ATTACH PARTITION public."user_token_mfa$20211215" FOR VALUES IN ('2021-12-15');


--
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


--
-- Name: vw_admin; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_admin AS
 SELECT au.code,
    au.role,
    au.user_id,
    (au.code)::character varying AS display_name,
    au.created_at,
    au.updated_at
   FROM public.admin_user au;


--
-- Name: wallet_address_hist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wallet_address_hist (
    wallet_id integer NOT NULL,
    user_id integer NOT NULL,
    cryptocurrency_code character varying(4) NOT NULL,
    address character varying(800) NOT NULL,
    active_from timestamp(0) without time zone NOT NULL,
    active_till timestamp without time zone NOT NULL,
    admin_code public.text_code,
    reason public.wallet_address_change_reason NOT NULL,
    comment character varying(1024),
    action_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallet_address_hist_check CHECK ((NOT ((admin_code IS NULL) AND (reason = 'admin_reset'::public.wallet_address_change_reason))))
);


--
-- Name: COLUMN wallet_address_hist.active_from; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallet_address_hist.active_from IS 'wallets.created_at';


--
-- Name: COLUMN wallet_address_hist.active_till; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.wallet_address_hist.active_till IS 'wallets.updated_at';


--
-- Name: wallets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

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


--
-- Name: ad id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.ad ALTER COLUMN id SET DEFAULT nextval('p2p.ads_id_seq'::regclass);


--
-- Name: admin_file_uploaded id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.admin_file_uploaded ALTER COLUMN id SET DEFAULT nextval('p2p.admin_file_uploded_id_seq'::regclass);


--
-- Name: audit id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.audit ALTER COLUMN id SET DEFAULT nextval('p2p.audit_id_seq'::regclass);


--
-- Name: backup$wallet_log id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p."backup$wallet_log" ALTER COLUMN id SET DEFAULT nextval('p2p.wallet_log_id_seq'::regclass);


--
-- Name: chat id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.chat ALTER COLUMN id SET DEFAULT nextval('p2p.chat_id_seq'::regclass);


--
-- Name: debt id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.debt ALTER COLUMN id SET DEFAULT nextval('p2p.debts_id_seq'::regclass);


--
-- Name: deep_link_action id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.deep_link_action ALTER COLUMN id SET DEFAULT nextval('p2p.deep_link_action_id_seq'::regclass);


--
-- Name: dispute id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute ALTER COLUMN id SET DEFAULT nextval('p2p.disputes_id_seq'::regclass);


--
-- Name: dispute_decision id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_decision ALTER COLUMN id SET DEFAULT nextval('p2p.dispute_decisions_id_seq'::regclass);


--
-- Name: dispute_video id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_video ALTER COLUMN id SET DEFAULT nextval('p2p.dispute_video_id_seq'::regclass);


--
-- Name: feedback id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.feedback ALTER COLUMN id SET DEFAULT nextval('p2p.feedbacks_id_seq'::regclass);


--
-- Name: merge_token id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge_token ALTER COLUMN id SET DEFAULT nextval('p2p.merge_tokens_id_seq'::regclass);


--
-- Name: muted_user id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.muted_user ALTER COLUMN id SET DEFAULT nextval('p2p.muted_users_id_seq'::regclass);


--
-- Name: notebook id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notebook ALTER COLUMN id SET DEFAULT nextval('p2p.notebook_id_seq'::regclass);


--
-- Name: notification id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notification ALTER COLUMN id SET DEFAULT nextval('p2p.notifications_id_seq'::regclass);


--
-- Name: old_data_profile id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.old_data_profile ALTER COLUMN id SET DEFAULT nextval('p2p.old_data_profile_id_seq'::regclass);


--
-- Name: payment_group id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_group ALTER COLUMN id SET DEFAULT nextval('p2p.payments_group_id_seq'::regclass);


--
-- Name: payment_group_multilang id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_group_multilang ALTER COLUMN id SET DEFAULT nextval('p2p.payments_group_multilang_id_seq'::regclass);


--
-- Name: payment_method id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method ALTER COLUMN id SET DEFAULT nextval('p2p.payment_method_id_seq'::regclass);


--
-- Name: payment_method_global id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method_global ALTER COLUMN id SET DEFAULT nextval('p2p.payment_method_global_id_seq'::regclass);


--
-- Name: rate id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate ALTER COLUMN id SET DEFAULT nextval('p2p.rates_id_seq'::regclass);


--
-- Name: rating_change_log id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rating_change_log ALTER COLUMN id SET DEFAULT nextval('p2p.rating_change_log_id_seq'::regclass);


--
-- Name: referal_bonus id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referal_bonus ALTER COLUMN id SET DEFAULT nextval('p2p.referal_bonuses_id_seq'::regclass);


--
-- Name: referral_links_statistic id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referral_links_statistic ALTER COLUMN id SET DEFAULT nextval('p2p.referral_links_statistic_id_seq'::regclass);


--
-- Name: requisite id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.requisite ALTER COLUMN id SET DEFAULT nextval('p2p.requisites_id_seq'::regclass);


--
-- Name: trade id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade ALTER COLUMN id SET DEFAULT nextval('p2p.trades_id_seq'::regclass);


--
-- Name: trade_history id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_history ALTER COLUMN id SET DEFAULT nextval('p2p.trade_history_id_seq'::regclass);


--
-- Name: trade_statistic id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic ALTER COLUMN id SET DEFAULT nextval('p2p.trade_statistic_id_seq'::regclass);


--
-- Name: trade_statistic_log id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic_log ALTER COLUMN id SET DEFAULT nextval('p2p.trade_statistic_log_id_seq'::regclass);


--
-- Name: untrusted_user id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.untrusted_user ALTER COLUMN id SET DEFAULT nextval('p2p.untrusted_users_id_seq'::regclass);


--
-- Name: user_2fa id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_2fa ALTER COLUMN id SET DEFAULT nextval('p2p.users_2fa_id_seq'::regclass);


--
-- Name: user_action_freeze id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_action_freeze ALTER COLUMN id SET DEFAULT nextval('p2p.user_actions_freeze_id_seq'::regclass);


--
-- Name: user_block id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_block ALTER COLUMN id SET DEFAULT nextval('p2p.user_block_id_seq'::regclass);


--
-- Name: user_note id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_note ALTER COLUMN id SET DEFAULT nextval('p2p.user_notes_id_seq'::regclass);


--
-- Name: user_profile id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile ALTER COLUMN id SET DEFAULT nextval('p2p.user_profile_id_seq'::regclass);


--
-- Name: user_rate id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_rate ALTER COLUMN id SET DEFAULT nextval('p2p.user_rates_id_seq'::regclass);


--
-- Name: user_settings id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_settings ALTER COLUMN id SET DEFAULT nextval('p2p.user_settings_id_seq'::regclass);


--
-- Name: user_trust id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_trust ALTER COLUMN id SET DEFAULT nextval('p2p.user_trust_id_seq'::regclass);


--
-- Name: voucher id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.voucher ALTER COLUMN id SET DEFAULT nextval('p2p.voucher_id_seq'::regclass);


--
-- Name: withdraw_voucher id; Type: DEFAULT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.withdraw_voucher ALTER COLUMN id SET DEFAULT nextval('p2p.withdraw_vouchers_id_seq'::regclass);


--
-- Name: account_swap_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_swap_log ALTER COLUMN id SET DEFAULT nextval('public.account_swap_log_id_seq'::regclass);


--
-- Name: deposit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deposit ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: event id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event ALTER COLUMN id SET DEFAULT nextval('public.event_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: user ref_parent_user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN ref_parent_user_id SET DEFAULT currval('public.users_id_seq'::regclass);


--
-- Name: wallet id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet ALTER COLUMN id SET DEFAULT nextval('public.wallets_id_seq'::regclass);


--
-- Name: withdrawal id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: withdrawal_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal_log ALTER COLUMN id SET DEFAULT nextval('public.payment_logs_id_seq'::regclass);


--
-- Name: admin_file_uploaded admin_file_uploded_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.admin_file_uploaded
    ADD CONSTRAINT admin_file_uploded_pkey PRIMARY KEY (id);


--
-- Name: ad ads_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.ad
    ADD CONSTRAINT ads_pkey PRIMARY KEY (id);


--
-- Name: audit audit_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.audit
    ADD CONSTRAINT audit_pkey PRIMARY KEY (id);


--
-- Name: cc_settings_backup cc_settings_backup_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.cc_settings_backup
    ADD CONSTRAINT cc_settings_backup_pkey PRIMARY KEY (code);


--
-- Name: chat chat_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (id);


--
-- Name: report check_unique_report_and_format; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.report
    ADD CONSTRAINT check_unique_report_and_format UNIQUE (description, format);


--
-- Name: config_maintenance config_maintenance_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.config_maintenance
    ADD CONSTRAINT config_maintenance_pkey PRIMARY KEY (name);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (name);


--
-- Name: cryptocurrency_settings cryptocurrency_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.cryptocurrency_settings
    ADD CONSTRAINT cryptocurrency_pkey PRIMARY KEY (code);


--
-- Name: cryptocurrency_rate_source cryptocurrency_rate_source_cryptocurrency_code_priority_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.cryptocurrency_rate_source
    ADD CONSTRAINT cryptocurrency_rate_source_cryptocurrency_code_priority_key UNIQUE (cc_code, priority);


--
-- Name: cryptocurrency_rate_source cryptocurrency_rate_source_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.cryptocurrency_rate_source
    ADD CONSTRAINT cryptocurrency_rate_source_pkey PRIMARY KEY (cc_code, rate_source_code);


--
-- Name: currency currencies_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.currency
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (symbol);


--
-- Name: payment_method currency_description_constraint; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method
    ADD CONSTRAINT currency_description_constraint UNIQUE (currency, description);


--
-- Name: deep_link_action deep_link_action_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.deep_link_action
    ADD CONSTRAINT deep_link_action_pkey PRIMARY KEY (id);


--
-- Name: dispute_decision dispute_decisions_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_decision
    ADD CONSTRAINT dispute_decisions_pkey PRIMARY KEY (id);


--
-- Name: dispute_video dispute_video_file_name_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_video
    ADD CONSTRAINT dispute_video_file_name_key UNIQUE (file_name);


--
-- Name: dispute_video dispute_video_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_video
    ADD CONSTRAINT dispute_video_pkey PRIMARY KEY (id);


--
-- Name: dispute disputes_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute
    ADD CONSTRAINT disputes_pkey PRIMARY KEY (id);


--
-- Name: dust_aggregation dust_aggregation_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dust_aggregation
    ADD CONSTRAINT dust_aggregation_pkey PRIMARY KEY (id);


--
-- Name: dust_aggregation dust_aggregation_tx_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dust_aggregation
    ADD CONSTRAINT dust_aggregation_tx_id_key UNIQUE (tx_id);


--
-- Name: feature features_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.feature
    ADD CONSTRAINT features_pkey PRIMARY KEY (code);


--
-- Name: feedback feedbacks_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.feedback
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: forbidden_public_name forbidden_public_names_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.forbidden_public_name
    ADD CONSTRAINT forbidden_public_names_pkey PRIMARY KEY (name);


--
-- Name: identity_verification_attempt identity_verification_attempt_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.identity_verification_attempt
    ADD CONSTRAINT identity_verification_attempt_pkey PRIMARY KEY (user_id, at);


--
-- Name: lang lang_description_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.lang
    ADD CONSTRAINT lang_description_key UNIQUE (description);


--
-- Name: lang lang_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.lang
    ADD CONSTRAINT lang_pkey PRIMARY KEY (code);


--
-- Name: merge_token merge_tokens_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge_token
    ADD CONSTRAINT merge_tokens_pkey PRIMARY KEY (id);


--
-- Name: merge_token merge_tokens_token_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge_token
    ADD CONSTRAINT merge_tokens_token_key UNIQUE (token);


--
-- Name: merge_token merge_tokens_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge_token
    ADD CONSTRAINT merge_tokens_user_id_key UNIQUE (user_id);


--
-- Name: merge merges_telegram_account_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge
    ADD CONSTRAINT merges_telegram_account_user_id_key UNIQUE (telegram_account_user_id);


--
-- Name: muted_user muted_users_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.muted_user
    ADD CONSTRAINT muted_users_pkey PRIMARY KEY (id);


--
-- Name: forbidden_public_name name_unique_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.forbidden_public_name
    ADD CONSTRAINT name_unique_key UNIQUE (name) INCLUDE (name);


--
-- Name: notebook notebook_address_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notebook
    ADD CONSTRAINT notebook_address_key UNIQUE (user_id, address);


--
-- Name: notebook notebook_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notebook
    ADD CONSTRAINT notebook_pkey PRIMARY KEY (id);


--
-- Name: notification_token notification_token_device_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notification_token
    ADD CONSTRAINT notification_token_device_id_key UNIQUE (device_id);


--
-- Name: notification_token notification_token_token_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notification_token
    ADD CONSTRAINT notification_token_token_key UNIQUE (token);


--
-- Name: notification notifications_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notification
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: old_data_profile old_data_profile_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.old_data_profile
    ADD CONSTRAINT old_data_profile_pkey PRIMARY KEY (id);


--
-- Name: config p2p_config_check_name_unique; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.config
    ADD CONSTRAINT p2p_config_check_name_unique UNIQUE (name);


--
-- Name: merge p2p_merges_unique; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge
    ADD CONSTRAINT p2p_merges_unique UNIQUE (web_account_user_id, telegram_account_user_id);


--
-- Name: payment_method_global payment_method_global_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method_global
    ADD CONSTRAINT payment_method_global_pkey PRIMARY KEY (id);


--
-- Name: payment_method_hist payment_method_hist_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method_hist
    ADD CONSTRAINT payment_method_hist_pkey PRIMARY KEY (id);


--
-- Name: payment_method payment_method_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method
    ADD CONSTRAINT payment_method_pkey PRIMARY KEY (id);


--
-- Name: payment_group_multilang payments_group_multilang_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_group_multilang
    ADD CONSTRAINT payments_group_multilang_pkey PRIMARY KEY (id);


--
-- Name: payment_group payments_group_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_group
    ADD CONSTRAINT payments_group_pkey PRIMARY KEY (id);


--
-- Name: payment_list_precalculation payments_list_precalculation_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_list_precalculation
    ADD CONSTRAINT payments_list_precalculation_pkey PRIMARY KEY (cc_code, ads_type, payment_method_id);


--
-- Name: rate_plan_withdraw rate_plan_withdraw_cc_code_act_during_op_amount_excl; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate_plan_withdraw
    ADD CONSTRAINT rate_plan_withdraw_cc_code_act_during_op_amount_excl EXCLUDE USING gist (cc_code WITH =, act_during WITH &&, op_amount WITH &&);


--
-- Name: user_rate rate_rate_id_constraint; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_rate
    ADD CONSTRAINT rate_rate_id_constraint UNIQUE (user_id, rate_id);


--
-- Name: rate_source rate_source_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate_source
    ADD CONSTRAINT rate_source_pkey PRIMARY KEY (code);


--
-- Name: rate rate_url_cryptocurrency_constraint; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate
    ADD CONSTRAINT rate_url_cryptocurrency_constraint UNIQUE (url, cc_code, currency_symbol);


--
-- Name: rate_fiat rates_fiat_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate_fiat
    ADD CONSTRAINT rates_fiat_pkey PRIMARY KEY (symbol1, symbol2);


--
-- Name: rate rates_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate
    ADD CONSTRAINT rates_pkey PRIMARY KEY (id);


--
-- Name: rating_change_log rating_change_log_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rating_change_log
    ADD CONSTRAINT rating_change_log_pkey PRIMARY KEY (id);


--
-- Name: referal_bonus referal_bonuses_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referal_bonus
    ADD CONSTRAINT referal_bonuses_pkey PRIMARY KEY (id);


--
-- Name: referral_links_statistic referral_links_statistic_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referral_links_statistic
    ADD CONSTRAINT referral_links_statistic_pkey PRIMARY KEY (id);


--
-- Name: requisite requisites_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.requisite
    ADD CONSTRAINT requisites_pkey PRIMARY KEY (id);


--
-- Name: stablecoin_trade stablecoin_trade_name_unique; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.stablecoin_trade
    ADD CONSTRAINT stablecoin_trade_name_unique UNIQUE (name);


--
-- Name: trade_history trade_history_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_history
    ADD CONSTRAINT trade_history_pkey PRIMARY KEY (id);


--
-- Name: trade_statistic_log trade_statistic_log_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic_log
    ADD CONSTRAINT trade_statistic_log_pkey PRIMARY KEY (id);


--
-- Name: trade_statistic trade_statistic_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic
    ADD CONSTRAINT trade_statistic_pkey PRIMARY KEY (id);


--
-- Name: trade_statistic trade_statistic_user_id_cryptocurrency_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic
    ADD CONSTRAINT trade_statistic_user_id_cryptocurrency_key UNIQUE (user_id, cc_code);


--
-- Name: trade trades_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade
    ADD CONSTRAINT trades_pkey PRIMARY KEY (id);


--
-- Name: user_settings unique_settings; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_settings
    ADD CONSTRAINT unique_settings UNIQUE (user_id);


--
-- Name: untrusted_user untrusted_users_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.untrusted_user
    ADD CONSTRAINT untrusted_users_pkey PRIMARY KEY (id);


--
-- Name: user_action_freeze user_action_freeze_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_action_freeze
    ADD CONSTRAINT user_action_freeze_pkey PRIMARY KEY (id);


--
-- Name: user_ad_filter user_ad_filter_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_ad_filter
    ADD CONSTRAINT user_ad_filter_user_id_key UNIQUE (user_id);


--
-- Name: user_block user_block_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_block
    ADD CONSTRAINT user_block_pkey PRIMARY KEY (id);


--
-- Name: user_block user_block_user_id_blocked_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_block
    ADD CONSTRAINT user_block_user_id_blocked_user_id_key UNIQUE (user_id, blocked_user_id);


--
-- Name: user_feature user_features_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_feature
    ADD CONSTRAINT user_features_pkey PRIMARY KEY (user_id, feature_code);


--
-- Name: user_note user_notes_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_note
    ADD CONSTRAINT user_notes_pkey PRIMARY KEY (id);


--
-- Name: user_profile user_profile_generated_name_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_generated_name_key UNIQUE (generated_name);


--
-- Name: user_profile user_profile_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_pkey PRIMARY KEY (id);


--
-- Name: user_profile user_profile_public_name_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_public_name_key UNIQUE (public_name);


--
-- Name: user_profile user_profile_uniqie; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_uniqie UNIQUE (user_id);


--
-- Name: user_profile user_profile_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_user_id_key UNIQUE (user_id);


--
-- Name: user_rate user_rates_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_rate
    ADD CONSTRAINT user_rates_pkey PRIMARY KEY (id);


--
-- Name: user_rate user_rates_user_id_rate_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_rate
    ADD CONSTRAINT user_rates_user_id_rate_id_key UNIQUE (user_id, rate_id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: user_trust user_trust_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_trust
    ADD CONSTRAINT user_trust_pkey PRIMARY KEY (id);


--
-- Name: user_trust user_trust_user_id_trusted_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_trust
    ADD CONSTRAINT user_trust_user_id_trusted_user_id_key UNIQUE (user_id, trusted_user_id);


--
-- Name: user_2fa users_2fa_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_2fa
    ADD CONSTRAINT users_2fa_pkey PRIMARY KEY (id);


--
-- Name: user_2fa users_2fa_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_2fa
    ADD CONSTRAINT users_2fa_user_id_key UNIQUE (user_id);


--
-- Name: utm_statistic utm_statistic_user_id_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.utm_statistic
    ADD CONSTRAINT utm_statistic_user_id_key UNIQUE (user_id);


--
-- Name: voucher voucher_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.voucher
    ADD CONSTRAINT voucher_pkey PRIMARY KEY (id);


--
-- Name: voucher voucher_secret_key_key; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.voucher
    ADD CONSTRAINT voucher_secret_key_key UNIQUE (secret_key);


--
-- Name: backup$wallet_log wallet_log_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p."backup$wallet_log"
    ADD CONSTRAINT wallet_log_pkey PRIMARY KEY (id);


--
-- Name: withdraw_voucher withdraw_vouchers_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.withdraw_voucher
    ADD CONSTRAINT withdraw_vouchers_pkey PRIMARY KEY (id);


--
-- Name: withdraw_voucher_prime_time withdraw_vouchers_prime_time_pkey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.withdraw_voucher_prime_time
    ADD CONSTRAINT withdraw_vouchers_prime_time_pkey PRIMARY KEY (name);


--
-- Name: withdraw_voucher withdraw_vouchers_secret_key_ukey; Type: CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.withdraw_voucher
    ADD CONSTRAINT withdraw_vouchers_secret_key_ukey UNIQUE (secret_key);


--
-- Name: account_kyc_hist account_kyc_hist_acc_id_at_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_kyc_hist
    ADD CONSTRAINT account_kyc_hist_acc_id_at_key UNIQUE (acc_id, at);


--
-- Name: account_kyc_hist account_kyc_hist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_kyc_hist
    ADD CONSTRAINT account_kyc_hist_pkey PRIMARY KEY (provider, correlation_id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account_swap_log account_swap_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_swap_log
    ADD CONSTRAINT account_swap_log_pkey PRIMARY KEY (old_user_id, new_user_id);


--
-- Name: admin_user admin_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT admin_user_pkey PRIMARY KEY (code);


--
-- Name: admin_user admin_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT admin_users_email_key UNIQUE (code);


--
-- Name: banned_user banned_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banned_user
    ADD CONSTRAINT banned_users_pkey PRIMARY KEY (user_id, date);


--
-- Name: blockchain_tx blockchain_tx_cc_code_txid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blockchain_tx
    ADD CONSTRAINT blockchain_tx_cc_code_txid_key UNIQUE (cc_code, txid);


--
-- Name: blockchain_tx blockchain_tx_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blockchain_tx
    ADD CONSTRAINT blockchain_tx_pkey PRIMARY KEY (id);


--
-- Name: cryptocurrency cryptocurrency_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryptocurrency
    ADD CONSTRAINT cryptocurrency_name_key UNIQUE (name);


--
-- Name: cryptocurrency cryptocurrency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cryptocurrency
    ADD CONSTRAINT cryptocurrency_pkey PRIMARY KEY (code);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: withdrawal_log payment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal_log
    ADD CONSTRAINT payment_logs_pkey PRIMARY KEY (id);


--
-- Name: withdrawal payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: withdrawal payments_wallet_id_address_created_at_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal
    ADD CONSTRAINT payments_wallet_id_address_created_at_key UNIQUE (wallet_id, address, created_at);


--
-- Name: signed_operation_request signed_operation_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signed_operation_request
    ADD CONSTRAINT signed_operation_request_pkey PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211113 signed_operation_request$20211113_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211113"
    ADD CONSTRAINT "signed_operation_request$20211113_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211114 signed_operation_request$20211114_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211114"
    ADD CONSTRAINT "signed_operation_request$20211114_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211115 signed_operation_request$20211115_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211115"
    ADD CONSTRAINT "signed_operation_request$20211115_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211116 signed_operation_request$20211116_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211116"
    ADD CONSTRAINT "signed_operation_request$20211116_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211117 signed_operation_request$20211117_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211117"
    ADD CONSTRAINT "signed_operation_request$20211117_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211118 signed_operation_request$20211118_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211118"
    ADD CONSTRAINT "signed_operation_request$20211118_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211119 signed_operation_request$20211119_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211119"
    ADD CONSTRAINT "signed_operation_request$20211119_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211120 signed_operation_request$20211120_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211120"
    ADD CONSTRAINT "signed_operation_request$20211120_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211121 signed_operation_request$20211121_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211121"
    ADD CONSTRAINT "signed_operation_request$20211121_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211122 signed_operation_request$20211122_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211122"
    ADD CONSTRAINT "signed_operation_request$20211122_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211123 signed_operation_request$20211123_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211123"
    ADD CONSTRAINT "signed_operation_request$20211123_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211124 signed_operation_request$20211124_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211124"
    ADD CONSTRAINT "signed_operation_request$20211124_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211125 signed_operation_request$20211125_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211125"
    ADD CONSTRAINT "signed_operation_request$20211125_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211126 signed_operation_request$20211126_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211126"
    ADD CONSTRAINT "signed_operation_request$20211126_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211127 signed_operation_request$20211127_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211127"
    ADD CONSTRAINT "signed_operation_request$20211127_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211128 signed_operation_request$20211128_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211128"
    ADD CONSTRAINT "signed_operation_request$20211128_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211129 signed_operation_request$20211129_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211129"
    ADD CONSTRAINT "signed_operation_request$20211129_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211130 signed_operation_request$20211130_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211130"
    ADD CONSTRAINT "signed_operation_request$20211130_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211201 signed_operation_request$20211201_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211201"
    ADD CONSTRAINT "signed_operation_request$20211201_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211202 signed_operation_request$20211202_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211202"
    ADD CONSTRAINT "signed_operation_request$20211202_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211203 signed_operation_request$20211203_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211203"
    ADD CONSTRAINT "signed_operation_request$20211203_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211204 signed_operation_request$20211204_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211204"
    ADD CONSTRAINT "signed_operation_request$20211204_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211205 signed_operation_request$20211205_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211205"
    ADD CONSTRAINT "signed_operation_request$20211205_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211206 signed_operation_request$20211206_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211206"
    ADD CONSTRAINT "signed_operation_request$20211206_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211207 signed_operation_request$20211207_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211207"
    ADD CONSTRAINT "signed_operation_request$20211207_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211208 signed_operation_request$20211208_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211208"
    ADD CONSTRAINT "signed_operation_request$20211208_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211209 signed_operation_request$20211209_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211209"
    ADD CONSTRAINT "signed_operation_request$20211209_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211210 signed_operation_request$20211210_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211210"
    ADD CONSTRAINT "signed_operation_request$20211210_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211211 signed_operation_request$20211211_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211211"
    ADD CONSTRAINT "signed_operation_request$20211211_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211212 signed_operation_request$20211212_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211212"
    ADD CONSTRAINT "signed_operation_request$20211212_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211213 signed_operation_request$20211213_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211213"
    ADD CONSTRAINT "signed_operation_request$20211213_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211214 signed_operation_request$20211214_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211214"
    ADD CONSTRAINT "signed_operation_request$20211214_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211215 signed_operation_request$20211215_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211215"
    ADD CONSTRAINT "signed_operation_request$20211215_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: signed_operation_request$20211216 signed_operation_request$20211216_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."signed_operation_request$20211216"
    ADD CONSTRAINT "signed_operation_request$20211216_pkey" PRIMARY KEY (expires_date, id);


--
-- Name: deposit transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deposit
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: deposit txid_vout; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deposit
    ADD CONSTRAINT txid_vout UNIQUE (blockchain_tx_id, vout);


--
-- Name: user_auth_pub_key user_auth_pub_key_jwk_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auth_pub_key
    ADD CONSTRAINT user_auth_pub_key_jwk_key UNIQUE (jwk);


--
-- Name: user_auth_pub_key user_auth_pub_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auth_pub_key
    ADD CONSTRAINT user_auth_pub_key_pkey PRIMARY KEY (user_id, aud, kid);


--
-- Name: user_cryptocurrency_settings user_cryptocurrency_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_cryptocurrency_settings
    ADD CONSTRAINT user_cryptocurrency_settings_pkey PRIMARY KEY (user_id, cc_code);


--
-- Name: wallet user_id_currency_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet
    ADD CONSTRAINT user_id_currency_unique UNIQUE (user_id, cc_code);


--
-- Name: user user_sys_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_sys_code_key UNIQUE (sys_code);


--
-- Name: user_token_mfa user_tokens_mfa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_token_mfa
    ADD CONSTRAINT user_tokens_mfa_pkey PRIMARY KEY (jwt_hash, expires_date);


--
-- Name: user_token_mfa$20211210 user_token_mfa$20211210_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user_token_mfa$20211210"
    ADD CONSTRAINT "user_token_mfa$20211210_pkey" PRIMARY KEY (jwt_hash, expires_date);


--
-- Name: user_token_mfa$20211211 user_token_mfa$20211211_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user_token_mfa$20211211"
    ADD CONSTRAINT "user_token_mfa$20211211_pkey" PRIMARY KEY (jwt_hash, expires_date);


--
-- Name: user_token_mfa$20211212 user_token_mfa$20211212_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user_token_mfa$20211212"
    ADD CONSTRAINT "user_token_mfa$20211212_pkey" PRIMARY KEY (jwt_hash, expires_date);


--
-- Name: user_token_mfa$20211213 user_token_mfa$20211213_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user_token_mfa$20211213"
    ADD CONSTRAINT "user_token_mfa$20211213_pkey" PRIMARY KEY (jwt_hash, expires_date);


--
-- Name: user_token_mfa$20211214 user_token_mfa$20211214_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user_token_mfa$20211214"
    ADD CONSTRAINT "user_token_mfa$20211214_pkey" PRIMARY KEY (jwt_hash, expires_date);


--
-- Name: user_token_mfa$20211215 user_token_mfa$20211215_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user_token_mfa$20211215"
    ADD CONSTRAINT "user_token_mfa$20211215_pkey" PRIMARY KEY (jwt_hash, expires_date);


--
-- Name: user users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wallet_address_hist wallet_address_hist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_address_hist
    ADD CONSTRAINT wallet_address_hist_pkey PRIMARY KEY (address, cryptocurrency_code, user_id);


--
-- Name: wallet wallets_address_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet
    ADD CONSTRAINT wallets_address_key UNIQUE (cc_code, address);


--
-- Name: wallet wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- Name: ads_cryptocurrency_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX ads_cryptocurrency_idx ON p2p.ad USING btree (cc_code);


--
-- Name: ads_cryptocurrency_idx1; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX ads_cryptocurrency_idx1 ON p2p.ad USING btree (cc_code) WHERE ((deleted_at IS NULL) AND (status = 'active'::p2p.ads_status) AND (type = 'purchase'::p2p.ads_type));


--
-- Name: ads_cryptocurrency_idx2; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX ads_cryptocurrency_idx2 ON p2p.ad USING btree (cc_code) WHERE ((deleted_at IS NULL) AND (status = 'active'::p2p.ads_status) AND (type = 'selling'::p2p.ads_type));


--
-- Name: ads_paymethod_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX ads_paymethod_idx ON p2p.ad USING btree (paymethod);


--
-- Name: ads_rate_value_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX ads_rate_value_idx ON p2p.ad USING btree (rate_value);


--
-- Name: ads_status_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX ads_status_idx ON p2p.ad USING btree (status);


--
-- Name: ads_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX ads_user_id_idx ON p2p.ad USING btree (user_id);


--
-- Name: audit_date_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX audit_date_idx ON p2p.audit USING btree (date);


--
-- Name: buy_ads_mview_aid_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE UNIQUE INDEX buy_ads_mview_aid_idx ON p2p.buy_ads_mview USING btree (aid);


--
-- Name: buy_ads_mview_cc_code_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX buy_ads_mview_cc_code_idx ON p2p.buy_ads_mview USING btree (cc_code);


--
-- Name: chat_author_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX chat_author_id_idx ON p2p.chat USING btree (author_id);


--
-- Name: chat_from_admin_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX chat_from_admin_idx ON p2p.chat USING btree (from_admin);


--
-- Name: chat_to_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX chat_to_idx ON p2p.chat USING btree ("to");


--
-- Name: chat_trade_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX chat_trade_id_idx ON p2p.chat USING btree (trade_id);


--
-- Name: disputes_admin_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX disputes_admin_idx ON p2p.dispute USING btree (admin_code);


--
-- Name: disputes_buyer_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX disputes_buyer_id_idx ON p2p.dispute USING btree (buyer_id);


--
-- Name: disputes_resolution_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX disputes_resolution_idx ON p2p.dispute USING btree (resolution);


--
-- Name: disputes_seller_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX disputes_seller_id_idx ON p2p.dispute USING btree (seller_id);


--
-- Name: dust_aggregation_status_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX dust_aggregation_status_idx ON p2p.dust_aggregation USING btree (status);


--
-- Name: feedbacks_for_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX feedbacks_for_user_id_idx ON p2p.feedback USING btree (for_user_id);


--
-- Name: feedbacks_trade_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX feedbacks_trade_id_idx ON p2p.feedback USING btree (trade_id);


--
-- Name: feedbacks_type_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX feedbacks_type_idx ON p2p.feedback USING btree (type);


--
-- Name: merges_web_account_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE UNIQUE INDEX merges_web_account_user_id_idx ON p2p.merge USING btree (web_account_user_id) WHERE (deleted_at IS NULL);


--
-- Name: notifications_name; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX notifications_name ON p2p.notification USING btree (name);


--
-- Name: notifications_receiver_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX notifications_receiver_user_id_idx ON p2p.notification USING btree (receiver_user_id);


--
-- Name: old_data_profile_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX old_data_profile_user_id_idx ON p2p.old_data_profile USING btree (user_id);


--
-- Name: payment_method_currency_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX payment_method_currency_idx ON p2p.payment_method USING btree (currency);


--
-- Name: payment_method_description_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX payment_method_description_idx ON p2p.payment_method USING btree (description);


--
-- Name: payment_method_i18n_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX payment_method_i18n_idx ON p2p.payment_method USING btree (i18n);


--
-- Name: payments_list_precalculation_ads_type_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX payments_list_precalculation_ads_type_idx ON p2p.payment_list_precalculation USING btree (ads_type);


--
-- Name: payments_list_precalculation_cryptocurrency_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX payments_list_precalculation_cryptocurrency_idx ON p2p.payment_list_precalculation USING btree (cc_code);


--
-- Name: payments_list_precalculation_currency_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX payments_list_precalculation_currency_idx ON p2p.payment_list_precalculation USING btree (currency);


--
-- Name: rates_cryptocurrency_code_currency_symbol_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE UNIQUE INDEX rates_cryptocurrency_code_currency_symbol_idx ON p2p.rate USING btree (cc_code, currency_symbol) WHERE default_rate;


--
-- Name: rates_cryptocurrency_code_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX rates_cryptocurrency_code_idx ON p2p.rate USING btree (cc_code);


--
-- Name: rates_currency_symbol_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX rates_currency_symbol_idx ON p2p.rate USING btree (currency_symbol);


--
-- Name: rates_default_rate_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX rates_default_rate_idx ON p2p.rate USING btree (default_rate);


--
-- Name: referal_bonuses_ref_parent_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX referal_bonuses_ref_parent_user_id_idx ON p2p.referal_bonus USING btree (ref_parent_user_id);


--
-- Name: sell_ads_mview_aid_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE UNIQUE INDEX sell_ads_mview_aid_idx ON p2p.sell_ads_mview USING btree (aid);


--
-- Name: sell_ads_mview_cc_code_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX sell_ads_mview_cc_code_idx ON p2p.sell_ads_mview USING btree (cc_code);


--
-- Name: trade_crypto_seller_ad_paymethod_status_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trade_crypto_seller_ad_paymethod_status_idx ON p2p.trade USING btree (crypto_seller, ad_paymethod, status);


--
-- Name: trade_history_date_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trade_history_date_idx ON p2p.trade_history USING btree (date);


--
-- Name: trade_history_status; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trade_history_status ON p2p.trade_history USING btree (status);


--
-- Name: trade_history_trade_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trade_history_trade_id_idx ON p2p.trade_history USING btree (trade_id);


--
-- Name: trade_statistic_cryptocurrency_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE UNIQUE INDEX trade_statistic_cryptocurrency_user_id_idx ON p2p.trade_statistic USING btree (cc_code, user_id);


--
-- Name: trade_statistic_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trade_statistic_idx ON p2p.trade_statistic USING btree (user_id);


--
-- Name: trades_ad_paymethod_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_ad_paymethod_idx ON p2p.trade USING btree (ad_paymethod);


--
-- Name: trades_ad_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_ad_user_id_idx ON p2p.trade USING btree (ad_user_id);


--
-- Name: trades_amount_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_amount_idx ON p2p.trade USING btree (amount);


--
-- Name: trades_comission_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_comission_idx ON p2p.trade USING btree (comission);


--
-- Name: trades_created_at_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_created_at_idx ON p2p.trade USING btree (created_at);


--
-- Name: trades_crypto_buyer_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_crypto_buyer_idx ON p2p.trade USING btree (crypto_buyer);


--
-- Name: trades_crypto_seller_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_crypto_seller_idx ON p2p.trade USING btree (crypto_seller);


--
-- Name: trades_cryptocurrency_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_cryptocurrency_idx ON p2p.trade USING btree (cc_code);


--
-- Name: trades_status_advanced_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_status_advanced_idx ON p2p.trade USING btree (status_advanced);


--
-- Name: trades_status_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_status_idx ON p2p.trade USING btree (status);


--
-- Name: trades_trade_initiator_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trades_trade_initiator_idx ON p2p.trade USING btree (trade_initiator);


--
-- Name: trgm_idx_wallet_log_cause; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX trgm_idx_wallet_log_cause ON p2p."backup$wallet_log" USING gin (cause public.gin_trgm_ops);


--
-- Name: user_block_blocked_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_block_blocked_user_id_idx ON p2p.user_block USING btree (blocked_user_id);


--
-- Name: user_profile_blocked_by_admin; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_profile_blocked_by_admin ON p2p.user_profile USING btree (blocked_by_admin);


--
-- Name: user_profile_lastactivity_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_profile_lastactivity_idx ON p2p.user_profile USING btree (lastactivity);


--
-- Name: user_profile_rating; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_profile_rating ON p2p.user_profile USING btree (rating);


--
-- Name: user_profile_start_of_use_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_profile_start_of_use_idx ON p2p.user_profile USING btree (start_of_use_date);


--
-- Name: user_profile_telegram_name_idx_new; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_profile_telegram_name_idx_new ON p2p.user_profile USING btree (telegram_name);


--
-- Name: user_profile_verification_date_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_profile_verification_date_idx ON p2p.user_profile USING btree (verification_date);


--
-- Name: user_profile_verified_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_profile_verified_idx ON p2p.user_profile USING btree (verified);


--
-- Name: user_rates_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX user_rates_user_id_idx ON p2p.user_rate USING btree (user_id);


--
-- Name: voucher_cashed_at_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX voucher_cashed_at_idx ON p2p.voucher USING btree (cashed_at);


--
-- Name: voucher_user_id_cc_code_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX voucher_user_id_cc_code_idx ON p2p.voucher USING btree (user_id, cc_code) WHERE ((cashed_at IS NULL) AND (deleted_at IS NULL));


--
-- Name: voucher_user_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX voucher_user_id_idx ON p2p.voucher USING btree (user_id);


--
-- Name: wallet_log_date_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX wallet_log_date_idx ON p2p."backup$wallet_log" USING btree (date);


--
-- Name: wallet_log_date_idx1; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX wallet_log_date_idx1 ON p2p.wallet_log USING btree (date);


--
-- Name: wallet_log_wallet_id; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX wallet_log_wallet_id ON p2p."backup$wallet_log" USING btree (wallet_id);


--
-- Name: wallet_log_wallet_id_idx; Type: INDEX; Schema: p2p; Owner: -
--

CREATE INDEX wallet_log_wallet_id_idx ON p2p.wallet_log USING btree (wallet_id);


--
-- Name: admin_user_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX admin_user_user_id_idx ON public.admin_user USING btree (user_id);


--
-- Name: deposit_cc_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX deposit_cc_code_idx ON public.deposit USING btree (cc_code);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: payments_address_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_address_idx ON public.withdrawal USING btree (address);


--
-- Name: payments_amount_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_amount_idx ON public.withdrawal USING btree (amount);


--
-- Name: payments_cc_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_cc_code_idx ON public.withdrawal USING btree (cc_code);


--
-- Name: payments_created_at_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_created_at_id_idx ON public.withdrawal USING btree (created_at);


--
-- Name: payments_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_status_idx ON public.withdrawal USING btree (status);


--
-- Name: payments_transaction_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_transaction_id_idx ON public.withdrawal USING btree (blockchain_tx_id);


--
-- Name: payments_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX payments_user_id_idx ON public.withdrawal USING btree (user_id);


--
-- Name: signed_operation_request_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX signed_operation_request_id_idx ON ONLY public.signed_operation_request USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211113_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211113_id_idx" ON public."signed_operation_request$20211113" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211114_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211114_id_idx" ON public."signed_operation_request$20211114" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211115_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211115_id_idx" ON public."signed_operation_request$20211115" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211116_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211116_id_idx" ON public."signed_operation_request$20211116" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211117_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211117_id_idx" ON public."signed_operation_request$20211117" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211118_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211118_id_idx" ON public."signed_operation_request$20211118" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211119_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211119_id_idx" ON public."signed_operation_request$20211119" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211120_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211120_id_idx" ON public."signed_operation_request$20211120" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211121_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211121_id_idx" ON public."signed_operation_request$20211121" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211122_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211122_id_idx" ON public."signed_operation_request$20211122" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211123_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211123_id_idx" ON public."signed_operation_request$20211123" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211124_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211124_id_idx" ON public."signed_operation_request$20211124" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211125_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211125_id_idx" ON public."signed_operation_request$20211125" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211126_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211126_id_idx" ON public."signed_operation_request$20211126" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211127_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211127_id_idx" ON public."signed_operation_request$20211127" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211128_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211128_id_idx" ON public."signed_operation_request$20211128" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211129_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211129_id_idx" ON public."signed_operation_request$20211129" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211130_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211130_id_idx" ON public."signed_operation_request$20211130" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211201_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211201_id_idx" ON public."signed_operation_request$20211201" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211202_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211202_id_idx" ON public."signed_operation_request$20211202" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211203_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211203_id_idx" ON public."signed_operation_request$20211203" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211204_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211204_id_idx" ON public."signed_operation_request$20211204" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211205_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211205_id_idx" ON public."signed_operation_request$20211205" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211206_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211206_id_idx" ON public."signed_operation_request$20211206" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211207_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211207_id_idx" ON public."signed_operation_request$20211207" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211208_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211208_id_idx" ON public."signed_operation_request$20211208" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211209_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211209_id_idx" ON public."signed_operation_request$20211209" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211210_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211210_id_idx" ON public."signed_operation_request$20211210" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211211_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211211_id_idx" ON public."signed_operation_request$20211211" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211212_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211212_id_idx" ON public."signed_operation_request$20211212" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211213_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211213_id_idx" ON public."signed_operation_request$20211213" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211214_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211214_id_idx" ON public."signed_operation_request$20211214" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211215_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211215_id_idx" ON public."signed_operation_request$20211215" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: signed_operation_request$20211216_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "signed_operation_request$20211216_id_idx" ON public."signed_operation_request$20211216" USING btree (id) WHERE (confirmed_at IS NULL);


--
-- Name: transactions_address_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_address_idx ON public.deposit USING btree (address);


--
-- Name: transactions_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_created_at_idx ON public.deposit USING btree (created_at);


--
-- Name: transactions_txid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_txid_idx ON public.deposit USING btree (blockchain_tx_id);


--
-- Name: transactions_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transactions_user_id_idx ON public.deposit USING btree (user_id);


--
-- Name: user_cryptocurrency_settings_user_id_cryptocurrency_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_cryptocurrency_settings_user_id_cryptocurrency_code_idx ON public.user_cryptocurrency_settings USING btree (user_id, cc_code) WHERE trading_enabled;


--
-- Name: users_real_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_real_email_idx ON public."user" USING btree (real_email) WHERE (deleted_at IS NULL);


--
-- Name: users_ref_parent_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_ref_parent_user_id_idx ON public."user" USING btree (ref_parent_user_id);


--
-- Name: users_subject_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_subject_idx ON public."user" USING btree (subject) WHERE (deleted_at IS NULL);


--
-- Name: users_subject_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_subject_idx1 ON public."user" USING btree (subject);


--
-- Name: users_telegram_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_telegram_id_idx ON public."user" USING btree (telegram_id) WHERE (deleted_at IS NULL);


--
-- Name: users_telegram_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_telegram_id_idx1 ON public."user" USING btree (telegram_id);


--
-- Name: users_username_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_username_idx1 ON public."user" USING btree (nickname);


--
-- Name: wallet_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX wallet_user_id ON public.wallet USING btree (user_id);


--
-- Name: signed_operation_request$20211113_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211113_id_idx";


--
-- Name: signed_operation_request$20211113_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211113_pkey";


--
-- Name: signed_operation_request$20211114_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211114_id_idx";


--
-- Name: signed_operation_request$20211114_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211114_pkey";


--
-- Name: signed_operation_request$20211115_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211115_id_idx";


--
-- Name: signed_operation_request$20211115_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211115_pkey";


--
-- Name: signed_operation_request$20211116_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211116_id_idx";


--
-- Name: signed_operation_request$20211116_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211116_pkey";


--
-- Name: signed_operation_request$20211117_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211117_id_idx";


--
-- Name: signed_operation_request$20211117_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211117_pkey";


--
-- Name: signed_operation_request$20211118_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211118_id_idx";


--
-- Name: signed_operation_request$20211118_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211118_pkey";


--
-- Name: signed_operation_request$20211119_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211119_id_idx";


--
-- Name: signed_operation_request$20211119_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211119_pkey";


--
-- Name: signed_operation_request$20211120_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211120_id_idx";


--
-- Name: signed_operation_request$20211120_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211120_pkey";


--
-- Name: signed_operation_request$20211121_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211121_id_idx";


--
-- Name: signed_operation_request$20211121_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211121_pkey";


--
-- Name: signed_operation_request$20211122_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211122_id_idx";


--
-- Name: signed_operation_request$20211122_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211122_pkey";


--
-- Name: signed_operation_request$20211123_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211123_id_idx";


--
-- Name: signed_operation_request$20211123_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211123_pkey";


--
-- Name: signed_operation_request$20211124_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211124_id_idx";


--
-- Name: signed_operation_request$20211124_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211124_pkey";


--
-- Name: signed_operation_request$20211125_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211125_id_idx";


--
-- Name: signed_operation_request$20211125_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211125_pkey";


--
-- Name: signed_operation_request$20211126_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211126_id_idx";


--
-- Name: signed_operation_request$20211126_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211126_pkey";


--
-- Name: signed_operation_request$20211127_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211127_id_idx";


--
-- Name: signed_operation_request$20211127_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211127_pkey";


--
-- Name: signed_operation_request$20211128_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211128_id_idx";


--
-- Name: signed_operation_request$20211128_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211128_pkey";


--
-- Name: signed_operation_request$20211129_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211129_id_idx";


--
-- Name: signed_operation_request$20211129_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211129_pkey";


--
-- Name: signed_operation_request$20211130_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211130_id_idx";


--
-- Name: signed_operation_request$20211130_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211130_pkey";


--
-- Name: signed_operation_request$20211201_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211201_id_idx";


--
-- Name: signed_operation_request$20211201_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211201_pkey";


--
-- Name: signed_operation_request$20211202_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211202_id_idx";


--
-- Name: signed_operation_request$20211202_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211202_pkey";


--
-- Name: signed_operation_request$20211203_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211203_id_idx";


--
-- Name: signed_operation_request$20211203_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211203_pkey";


--
-- Name: signed_operation_request$20211204_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211204_id_idx";


--
-- Name: signed_operation_request$20211204_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211204_pkey";


--
-- Name: signed_operation_request$20211205_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211205_id_idx";


--
-- Name: signed_operation_request$20211205_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211205_pkey";


--
-- Name: signed_operation_request$20211206_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211206_id_idx";


--
-- Name: signed_operation_request$20211206_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211206_pkey";


--
-- Name: signed_operation_request$20211207_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211207_id_idx";


--
-- Name: signed_operation_request$20211207_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211207_pkey";


--
-- Name: signed_operation_request$20211208_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211208_id_idx";


--
-- Name: signed_operation_request$20211208_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211208_pkey";


--
-- Name: signed_operation_request$20211209_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211209_id_idx";


--
-- Name: signed_operation_request$20211209_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211209_pkey";


--
-- Name: signed_operation_request$20211210_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211210_id_idx";


--
-- Name: signed_operation_request$20211210_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211210_pkey";


--
-- Name: signed_operation_request$20211211_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211211_id_idx";


--
-- Name: signed_operation_request$20211211_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211211_pkey";


--
-- Name: signed_operation_request$20211212_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211212_id_idx";


--
-- Name: signed_operation_request$20211212_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211212_pkey";


--
-- Name: signed_operation_request$20211213_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211213_id_idx";


--
-- Name: signed_operation_request$20211213_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211213_pkey";


--
-- Name: signed_operation_request$20211214_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211214_id_idx";


--
-- Name: signed_operation_request$20211214_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211214_pkey";


--
-- Name: signed_operation_request$20211215_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211215_id_idx";


--
-- Name: signed_operation_request$20211215_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211215_pkey";


--
-- Name: signed_operation_request$20211216_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_id_idx ATTACH PARTITION public."signed_operation_request$20211216_id_idx";


--
-- Name: signed_operation_request$20211216_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.signed_operation_request_pkey ATTACH PARTITION public."signed_operation_request$20211216_pkey";


--
-- Name: user_token_mfa$20211210_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.user_tokens_mfa_pkey ATTACH PARTITION public."user_token_mfa$20211210_pkey";


--
-- Name: user_token_mfa$20211211_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.user_tokens_mfa_pkey ATTACH PARTITION public."user_token_mfa$20211211_pkey";


--
-- Name: user_token_mfa$20211212_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.user_tokens_mfa_pkey ATTACH PARTITION public."user_token_mfa$20211212_pkey";


--
-- Name: user_token_mfa$20211213_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.user_tokens_mfa_pkey ATTACH PARTITION public."user_token_mfa$20211213_pkey";


--
-- Name: user_token_mfa$20211214_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.user_tokens_mfa_pkey ATTACH PARTITION public."user_token_mfa$20211214_pkey";


--
-- Name: user_token_mfa$20211215_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.user_tokens_mfa_pkey ATTACH PARTITION public."user_token_mfa$20211215_pkey";


--
-- Name: trade check_two_trades_trigger_after_insert; Type: TRIGGER; Schema: p2p; Owner: -
--

CREATE TRIGGER check_two_trades_trigger_after_insert AFTER INSERT ON p2p.trade FOR EACH ROW EXECUTE FUNCTION p2p.check_two_trades();


--
-- Name: user_rate check_two_user_rates_trigger_before_insert; Type: TRIGGER; Schema: p2p; Owner: -
--

CREATE TRIGGER check_two_user_rates_trigger_before_insert BEFORE INSERT ON p2p.user_rate FOR EACH ROW EXECUTE FUNCTION p2p.check_two_user_rates();


--
-- Name: payment_method_global global_paymethods_delete_handler; Type: TRIGGER; Schema: p2p; Owner: -
--

CREATE TRIGGER global_paymethods_delete_handler BEFORE DELETE ON p2p.payment_method_global FOR EACH ROW EXECUTE FUNCTION p2p.global_paymethods_delete();


--
-- Name: payment_method_global global_paymethods_insert_handler; Type: TRIGGER; Schema: p2p; Owner: -
--

CREATE TRIGGER global_paymethods_insert_handler AFTER INSERT ON p2p.payment_method_global FOR EACH ROW EXECUTE FUNCTION p2p.global_paymethods_insert();


--
-- Name: payment_method_global global_paymethods_update_handler; Type: TRIGGER; Schema: p2p; Owner: -
--

CREATE TRIGGER global_paymethods_update_handler AFTER UPDATE ON p2p.payment_method_global FOR EACH ROW EXECUTE FUNCTION p2p.global_paymethods_update();


--
-- Name: ad ads_cryptocurrency_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.ad
    ADD CONSTRAINT ads_cryptocurrency_fkey FOREIGN KEY (cc_code) REFERENCES p2p.cryptocurrency_settings(code);


--
-- Name: ad ads_paymethod_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.ad
    ADD CONSTRAINT ads_paymethod_fkey FOREIGN KEY (paymethod) REFERENCES p2p.payment_method(id);


--
-- Name: ad ads_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.ad
    ADD CONSTRAINT ads_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: chat chat_admin_file_uploaded_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.chat
    ADD CONSTRAINT chat_admin_file_uploaded_id_fkey FOREIGN KEY (admin_file_uploaded_id) REFERENCES p2p.admin_file_uploaded(id);


--
-- Name: chat chat_author_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.chat
    ADD CONSTRAINT chat_author_id_fkey FOREIGN KEY (author_id) REFERENCES public."user"(id) MATCH FULL;


--
-- Name: chat chat_trade_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.chat
    ADD CONSTRAINT chat_trade_id_fkey FOREIGN KEY (trade_id) REFERENCES p2p.trade(id);


--
-- Name: cryptocurrency_rate_source cryptocurrency_rate_source_cryptocurrency_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.cryptocurrency_rate_source
    ADD CONSTRAINT cryptocurrency_rate_source_cryptocurrency_code_fkey FOREIGN KEY (cc_code) REFERENCES public.cryptocurrency(code);


--
-- Name: cryptocurrency_rate_source cryptocurrency_rate_source_rate_source_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.cryptocurrency_rate_source
    ADD CONSTRAINT cryptocurrency_rate_source_rate_source_code_fkey FOREIGN KEY (rate_source_code) REFERENCES p2p.rate_source(code);


--
-- Name: cryptocurrency_settings cryptocurrency_settings_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.cryptocurrency_settings
    ADD CONSTRAINT cryptocurrency_settings_code_fkey FOREIGN KEY (code) REFERENCES public.cryptocurrency(code);


--
-- Name: debt debt_action_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.debt
    ADD CONSTRAINT debt_action_admin_code_fkey FOREIGN KEY (action_admin_code) REFERENCES public.admin_user(code);


--
-- Name: debt debt_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.debt
    ADD CONSTRAINT debt_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: debt debts_wallet_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.debt
    ADD CONSTRAINT debts_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.wallet(id);


--
-- Name: deep_link_referal_action deep_link_referal_action_deep_link_action_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.deep_link_referal_action
    ADD CONSTRAINT deep_link_referal_action_deep_link_action_id_fkey FOREIGN KEY (deep_link_action_id) REFERENCES p2p.deep_link_action(id);


--
-- Name: deep_link_referal_action deep_link_referal_action_parent_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.deep_link_referal_action
    ADD CONSTRAINT deep_link_referal_action_parent_user_id_fkey FOREIGN KEY (parent_user_id) REFERENCES public."user"(id);


--
-- Name: dispute dispute_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute
    ADD CONSTRAINT dispute_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: dispute_decision dispute_decision_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_decision
    ADD CONSTRAINT dispute_decision_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: dispute_decision dispute_decision_admin_code_fkey1; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_decision
    ADD CONSTRAINT dispute_decision_admin_code_fkey1 FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: dispute_decision dispute_decisions_dispute_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_decision
    ADD CONSTRAINT dispute_decisions_dispute_id_fkey FOREIGN KEY (dispute_id) REFERENCES p2p.dispute(id);


--
-- Name: dispute_decision dispute_decisions_trade_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_decision
    ADD CONSTRAINT dispute_decisions_trade_id_fkey FOREIGN KEY (trade_id) REFERENCES p2p.trade(id);


--
-- Name: dispute_video dispute_video_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_video
    ADD CONSTRAINT dispute_video_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: dispute_video dispute_video_admin_code_fkey1; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_video
    ADD CONSTRAINT dispute_video_admin_code_fkey1 FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: dispute_video dispute_video_dispute_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute_video
    ADD CONSTRAINT dispute_video_dispute_id_fkey FOREIGN KEY (dispute_id) REFERENCES p2p.dispute(id) ON UPDATE CASCADE;


--
-- Name: dispute disputes_buyer_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute
    ADD CONSTRAINT disputes_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public."user"(id);


--
-- Name: dispute disputes_seller_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute
    ADD CONSTRAINT disputes_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public."user"(id);


--
-- Name: dispute disputes_trade_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.dispute
    ADD CONSTRAINT disputes_trade_id_fkey FOREIGN KEY (trade_id) REFERENCES p2p.trade(id);


--
-- Name: feature features_required_feature_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.feature
    ADD CONSTRAINT features_required_feature_code_fkey FOREIGN KEY (required_feature_code) REFERENCES p2p.feature(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: feedback feedbacks_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.feedback
    ADD CONSTRAINT feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: identity_verification_attempt identity_verification_attempt_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.identity_verification_attempt
    ADD CONSTRAINT identity_verification_attempt_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: merge_token merge_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge_token
    ADD CONSTRAINT merge_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: merge merges_telegram_account_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge
    ADD CONSTRAINT merges_telegram_account_user_id_fkey FOREIGN KEY (telegram_account_user_id) REFERENCES public."user"(id);


--
-- Name: merge merges_web_account_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.merge
    ADD CONSTRAINT merges_web_account_user_id_fkey FOREIGN KEY (web_account_user_id) REFERENCES public."user"(id);


--
-- Name: muted_user muted_user_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.muted_user
    ADD CONSTRAINT muted_user_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: notebook notebook_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notebook
    ADD CONSTRAINT notebook_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: notification_token notification_token_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.notification_token
    ADD CONSTRAINT notification_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: old_data_profile old_data_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.old_data_profile
    ADD CONSTRAINT old_data_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: payment_method payment_method_currency_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method
    ADD CONSTRAINT payment_method_currency_fkey FOREIGN KEY (currency) REFERENCES p2p.currency(symbol);


--
-- Name: payment_method_global payment_method_global_payments_group_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method_global
    ADD CONSTRAINT payment_method_global_payments_group_fkey FOREIGN KEY (payments_group) REFERENCES p2p.payment_group(id);


--
-- Name: payment_method_hist payment_method_hist_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method_hist
    ADD CONSTRAINT payment_method_hist_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: payment_method_hist payment_method_hist_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method_hist
    ADD CONSTRAINT payment_method_hist_id_fkey FOREIGN KEY (id) REFERENCES p2p.payment_method(id);


--
-- Name: payment_method payment_method_payments_group_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_method
    ADD CONSTRAINT payment_method_payments_group_fkey FOREIGN KEY (payment_group) REFERENCES p2p.payment_group(id);


--
-- Name: payment_group_multilang payments_group_multilang_payments_group_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_group_multilang
    ADD CONSTRAINT payments_group_multilang_payments_group_id_fkey FOREIGN KEY (payments_group_id) REFERENCES p2p.payment_group(id) ON DELETE CASCADE;


--
-- Name: payment_list_precalculation payments_list_precalculation_payment_method_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_list_precalculation
    ADD CONSTRAINT payments_list_precalculation_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES p2p.payment_method(id);


--
-- Name: payment_list_precalculation payments_list_precalculation_payments_group_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.payment_list_precalculation
    ADD CONSTRAINT payments_list_precalculation_payments_group_fkey FOREIGN KEY (payment_group) REFERENCES p2p.payment_group(id);


--
-- Name: rate_plan_withdraw rate_plan_withdraw_cc_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate_plan_withdraw
    ADD CONSTRAINT rate_plan_withdraw_cc_code_fkey FOREIGN KEY (cc_code) REFERENCES public.cryptocurrency(code);


--
-- Name: rate rates_cryptocurrency_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate
    ADD CONSTRAINT rates_cryptocurrency_code_fkey FOREIGN KEY (cc_code) REFERENCES p2p.cryptocurrency_settings(code);


--
-- Name: rate rates_currency_symbol_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rate
    ADD CONSTRAINT rates_currency_symbol_fkey FOREIGN KEY (currency_symbol) REFERENCES p2p.currency(symbol);


--
-- Name: rating_change_log rating_change_log_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.rating_change_log
    ADD CONSTRAINT rating_change_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: referal_bonus referal_bonuses_cryptocurrency_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referal_bonus
    ADD CONSTRAINT referal_bonuses_cryptocurrency_fkey FOREIGN KEY (cc_code) REFERENCES public.cryptocurrency(code) ON UPDATE CASCADE;


--
-- Name: referal_bonus referal_bonuses_ref_parent_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referal_bonus
    ADD CONSTRAINT referal_bonuses_ref_parent_user_id_fkey FOREIGN KEY (ref_parent_user_id) REFERENCES public."user"(id) ON UPDATE CASCADE;


--
-- Name: referal_bonus referal_bonuses_referal_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referal_bonus
    ADD CONSTRAINT referal_bonuses_referal_id_fkey FOREIGN KEY (referal_id) REFERENCES public."user"(id);


--
-- Name: referal_bonus referal_bonuses_trade_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.referal_bonus
    ADD CONSTRAINT referal_bonuses_trade_id_fkey FOREIGN KEY (trade_id) REFERENCES p2p.trade(id);


--
-- Name: requisite requisites_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.requisite
    ADD CONSTRAINT requisites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: trade_history trade_history_trade_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_history
    ADD CONSTRAINT trade_history_trade_id_fkey FOREIGN KEY (trade_id) REFERENCES p2p.trade(id);


--
-- Name: trade_statistic trade_statistic_cryptocurrency_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic
    ADD CONSTRAINT trade_statistic_cryptocurrency_fkey FOREIGN KEY (cc_code) REFERENCES p2p.cryptocurrency_settings(code);


--
-- Name: trade_statistic trade_statistic_cryptocurrency_fkey1; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic
    ADD CONSTRAINT trade_statistic_cryptocurrency_fkey1 FOREIGN KEY (cc_code) REFERENCES public.cryptocurrency(code);


--
-- Name: trade_statistic_log trade_statistic_log_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic_log
    ADD CONSTRAINT trade_statistic_log_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: trade_statistic_log trade_statistic_log_admin_code_fkey1; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic_log
    ADD CONSTRAINT trade_statistic_log_admin_code_fkey1 FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: trade_statistic_log trade_statistic_log_ts_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic_log
    ADD CONSTRAINT trade_statistic_log_ts_id_fkey FOREIGN KEY (ts_id) REFERENCES p2p.trade_statistic(id);


--
-- Name: trade_statistic trade_statistic_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade_statistic
    ADD CONSTRAINT trade_statistic_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: trade trades_ad_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade
    ADD CONSTRAINT trades_ad_id_fkey FOREIGN KEY (ad_id) REFERENCES p2p.ad(id);


--
-- Name: trade trades_ad_initiator_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade
    ADD CONSTRAINT trades_ad_initiator_fkey FOREIGN KEY (trade_initiator) REFERENCES public."user"(id);


--
-- Name: trade trades_ad_paymethod_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade
    ADD CONSTRAINT trades_ad_paymethod_fkey FOREIGN KEY (ad_paymethod) REFERENCES p2p.payment_method(id);


--
-- Name: trade trades_crypto_buyer_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade
    ADD CONSTRAINT trades_crypto_buyer_fkey FOREIGN KEY (crypto_buyer) REFERENCES public."user"(id);


--
-- Name: trade trades_crypto_seller_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.trade
    ADD CONSTRAINT trades_crypto_seller_fkey FOREIGN KEY (crypto_seller) REFERENCES public."user"(id);


--
-- Name: untrusted_user untrusted_user_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.untrusted_user
    ADD CONSTRAINT untrusted_user_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: user_action_freeze user_action_freeze_admin_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_action_freeze
    ADD CONSTRAINT user_action_freeze_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: user_action_freeze user_actions_freeze_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_action_freeze
    ADD CONSTRAINT user_actions_freeze_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_ad_filter user_ad_filter_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_ad_filter
    ADD CONSTRAINT user_ad_filter_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_block user_block_blocked_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_block
    ADD CONSTRAINT user_block_blocked_user_id_fkey FOREIGN KEY (blocked_user_id) REFERENCES public."user"(id);


--
-- Name: user_block user_block_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_block
    ADD CONSTRAINT user_block_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_feature user_features_feature_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_feature
    ADD CONSTRAINT user_features_feature_code_fkey FOREIGN KEY (feature_code) REFERENCES p2p.feature(code) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_note user_notes_for_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_note
    ADD CONSTRAINT user_notes_for_user_id_fkey FOREIGN KEY (for_user_id) REFERENCES public."user"(id);


--
-- Name: user_note user_notes_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_note
    ADD CONSTRAINT user_notes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_profile user_profile_cryptocurrency_code_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_cryptocurrency_code_fkey FOREIGN KEY (cryptocurrency) REFERENCES p2p.cryptocurrency_settings(code);


--
-- Name: user_profile user_profile_currency_symbol_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_currency_symbol_fkey FOREIGN KEY (currency) REFERENCES p2p.currency(symbol);


--
-- Name: user_profile user_profile_lang_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_lang_fkey FOREIGN KEY (lang) REFERENCES p2p.lang(code);


--
-- Name: user_profile user_profile_lang_web_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_lang_web_fkey FOREIGN KEY (lang_web) REFERENCES p2p.lang(code);


--
-- Name: user_profile user_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_profile
    ADD CONSTRAINT user_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_rate user_rates_rate_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_rate
    ADD CONSTRAINT user_rates_rate_id_fkey FOREIGN KEY (rate_id) REFERENCES p2p.rate(id);


--
-- Name: user_rate user_rates_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_rate
    ADD CONSTRAINT user_rates_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_settings user_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_settings
    ADD CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: user_trust user_trust_trusted_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_trust
    ADD CONSTRAINT user_trust_trusted_user_id_fkey FOREIGN KEY (trusted_user_id) REFERENCES public."user"(id);


--
-- Name: user_trust user_trust_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_trust
    ADD CONSTRAINT user_trust_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_2fa users_2fa_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.user_2fa
    ADD CONSTRAINT users_2fa_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: utm_statistic utm_statistic_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.utm_statistic
    ADD CONSTRAINT utm_statistic_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: voucher voucher_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.voucher
    ADD CONSTRAINT voucher_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: backup$wallet_log wallet_log_wallet_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p."backup$wallet_log"
    ADD CONSTRAINT wallet_log_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.wallet(id);


--
-- Name: wallet_log wallet_log_wallet_id_fkey1; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.wallet_log
    ADD CONSTRAINT wallet_log_wallet_id_fkey1 FOREIGN KEY (wallet_id) REFERENCES public.wallet(id);


--
-- Name: withdraw_voucher withdraw_vouchers_payment_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.withdraw_voucher
    ADD CONSTRAINT withdraw_vouchers_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.withdrawal(id);


--
-- Name: withdraw_voucher withdraw_vouchers_prime_time_event_name_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.withdraw_voucher
    ADD CONSTRAINT withdraw_vouchers_prime_time_event_name_fkey FOREIGN KEY (prime_time_event_name) REFERENCES p2p.withdraw_voucher_prime_time(name) ON UPDATE CASCADE;


--
-- Name: withdraw_voucher withdraw_vouchers_user_id_fkey; Type: FK CONSTRAINT; Schema: p2p; Owner: -
--

ALTER TABLE ONLY p2p.withdraw_voucher
    ADD CONSTRAINT withdraw_vouchers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: account account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_id_fkey FOREIGN KEY (id) REFERENCES public."user"(id);


--
-- Name: account_kyc_hist account_kyc_hist_acc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_kyc_hist
    ADD CONSTRAINT account_kyc_hist_acc_id_fkey FOREIGN KEY (acc_id) REFERENCES public."user"(id);


--
-- Name: account_swap_log account_swap_log_admin_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_swap_log
    ADD CONSTRAINT account_swap_log_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: account_swap_log account_swap_log_new_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_swap_log
    ADD CONSTRAINT account_swap_log_new_user_id_fkey FOREIGN KEY (new_user_id) REFERENCES public."user"(id);


--
-- Name: account_swap_log account_swap_log_old_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_swap_log
    ADD CONSTRAINT account_swap_log_old_user_id_fkey FOREIGN KEY (old_user_id) REFERENCES public."user"(id);


--
-- Name: admin_user admin_user_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_user
    ADD CONSTRAINT admin_user_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: banned_user banned_user_admin_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banned_user
    ADD CONSTRAINT banned_user_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: deposit deposit_blockchain_tx_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deposit
    ADD CONSTRAINT deposit_blockchain_tx_id_fkey FOREIGN KEY (blockchain_tx_id) REFERENCES public.blockchain_tx(id);


--
-- Name: withdrawal payments_currency_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal
    ADD CONSTRAINT payments_currency_fkey FOREIGN KEY (cc_code) REFERENCES public.cryptocurrency(code);


--
-- Name: withdrawal payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal
    ADD CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: withdrawal payments_wallet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal
    ADD CONSTRAINT payments_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.wallet(id);


--
-- Name: signed_operation_request signed_operation_request_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.signed_operation_request
    ADD CONSTRAINT signed_operation_request_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_auth_pub_key user_auth_pub_key_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_auth_pub_key
    ADD CONSTRAINT user_auth_pub_key_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_cryptocurrency_settings user_cryptocurrency_settings_cryptocurrency_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_cryptocurrency_settings
    ADD CONSTRAINT user_cryptocurrency_settings_cryptocurrency_code_fkey FOREIGN KEY (cc_code) REFERENCES public.cryptocurrency(code);


--
-- Name: user_cryptocurrency_settings user_cryptocurrency_settings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_cryptocurrency_settings
    ADD CONSTRAINT user_cryptocurrency_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user_token_mfa user_tokens_mfa_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.user_token_mfa
    ADD CONSTRAINT user_tokens_mfa_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: user users_ref_parent_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT users_ref_parent_user_id_fkey FOREIGN KEY (ref_parent_user_id) REFERENCES public."user"(id);


--
-- Name: wallet_address_hist wallet_address_hist_admin_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_address_hist
    ADD CONSTRAINT wallet_address_hist_admin_code_fkey FOREIGN KEY (admin_code) REFERENCES public.admin_user(code);


--
-- Name: wallet_address_hist wallet_address_hist_cryptocurrency_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_address_hist
    ADD CONSTRAINT wallet_address_hist_cryptocurrency_code_fkey FOREIGN KEY (cryptocurrency_code) REFERENCES public.cryptocurrency(code);


--
-- Name: wallet_address_hist wallet_address_hist_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_address_hist
    ADD CONSTRAINT wallet_address_hist_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: wallet_address_hist wallet_address_hist_wallet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wallet_address_hist
    ADD CONSTRAINT wallet_address_hist_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.wallet(id);


--
-- Name: withdrawal withdrawal_blockchain_tx_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.withdrawal
    ADD CONSTRAINT withdrawal_blockchain_tx_id_fkey FOREIGN KEY (blockchain_tx_id) REFERENCES public.blockchain_tx(id);


--
-- PostgreSQL database dump complete
--

