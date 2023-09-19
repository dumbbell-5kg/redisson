--RedissonSpinLock:127
--KEYS[1]:lock
--ARGV[1]:30000
--ARGV[2]:getLockName(threadId)   4db4fec7-e81c-47a5-bdb6-93061e1d966d:53           ServiceManager.id:threadId   ServiceManager.id应该是用来区分不同客户端的   

if (redis.call('exists', KEYS[1]) == 0) then-- 如果锁的key不存在
    redis.call('hincrby', KEYS[1], ARGV[2], 1);--hincrby(hash increase by):为哈希表中的字段值加上指定增量值。KEYS[1]为key，ARGV[2]为hashKey
    redis.call('pexpire', KEYS[1], ARGV[1]);--pexpire：以毫秒为单位设置key的生存时间
    return nil;--nil 可以理解为null
end ;
if (redis.call('hexists', KEYS[1], ARGV[2]) == 1) then -- hash exists，如果锁存在，而且是被同一线程id持有的
    redis.call('hincrby', KEYS[1], ARGV[2], 1);--锁计数+1
    redis.call('pexpire', KEYS[1], ARGV[1]);--重置存活时间
    return nil;
end ;
return redis.call('pttl', KEYS[1]); -- key存在，但被另一线程持有，以ms返回剩余时间

-- 脚本首先检查是否已存在指定的 Redis 键（key）表示的锁，如果不存在，就创建一个新的锁。
-- 如果锁已存在，脚本会检查是否由同一个线程（通过 threadId 标识）持有锁。如果是同一个线程，它会增加锁的计数并更新锁的过期时间（租期），然后返回 nil，表示成功获取锁。
-- 如果不是同一个线程，脚本将返回当前锁的剩余过期时间。
