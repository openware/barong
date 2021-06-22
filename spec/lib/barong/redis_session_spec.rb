# frozen_string_literal: true

describe Barong::RedisSession do
  let!(:create_member_permission) do
    create :permission,
           role: 'member'
  end

  let!(:user) { create(:user) }
  let!(:session_id) { SecureRandom.hex(16) }
  let!(:hash_sid) { Barong::RedisSession.hexdigest_session(session_id) }
  let!(:encrypted_value) { Barong::RedisSession.encrypted_session(session_id) }

  after(:each) { clear_redis }

  context 'add' do
    before(:each) { clear_redis }

    it 'add session key' do
      Barong::RedisSession.add(user.uid, session_id, 120)

      key = Barong::RedisSession.key_name(user.uid, session_id)
      expect(Rails.cache.read(key)).to eq encrypted_value
    end
  end

  context 'delete' do
    before(:each) { clear_redis }

    it 'delete key from redis list' do
      Barong::RedisSession.add(user.uid, session_id, 120)

      key = Barong::RedisSession.key_name(user.uid, session_id)
      expect(Rails.cache.read(key)).to eq encrypted_value

      res = Barong::RedisSession.delete(user.uid, session_id)
      expect(res).to eq 1

      expect(Rails.cache.read(key)).to eq nil
    end
  end

  context 'update' do
    before(:each) { clear_redis }

    it 'should update redis session expire time' do
      key = Barong::RedisSession.key_name(user.uid, session_id)
      Barong::RedisSession.add(user.uid, session_id, 10)
      expect(Rails.cache.read(key)).to eq encrypted_value

      Barong::RedisSession.update(user.uid, session_id, 0.00000001)
      expect(Rails.cache.read(key)).to eq nil
    end
  end

  context 'invalidate_all' do
    before(:each) { clear_redis }

    before(:each) do
      5.times {
        session_id = SecureRandom.hex(16)
        Barong::RedisSession.add(user.uid, session_id, 60)
      }
    end

    context 'without session id' do
      it 'should invalidate all sessions' do
        expect(Rails.cache.redis.keys.length).to eq 5
        Barong::RedisSession.invalidate_all(user.uid)
        expect(Rails.cache.redis.keys).to eq []
      end
    end

    context 'with session id' do
      it 'should invalidate all sessions except one' do
        sid = SecureRandom.hex(16)
        Barong::RedisSession.add(user.uid, sid, 60)

        expect(Rails.cache.redis.keys.length).to eq 6
        Barong::RedisSession.invalidate_all(user.uid, sid)
        expect(Rails.cache.redis.keys.length).to eq 1
      end
    end
  end
end
