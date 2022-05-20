# ######## Ex 03
# 使用合约函数来操作合约变量
# 在这个练习中，你需要：
# - 使用此合约的函数来操作您地址独有的内部计数器
# - 一旦这个计数器达到某个值，调用一个特定的函数
# - 合约记入您的积分

# # 您会学到：
# - 如何宣告映射
# - 如何读取和写入映射
# - H如何使用函数来操作存储变量

# ######## 內建函式库和输入
#
#

%lang starknet
%builtins pedersen range_check

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer,
)

#
# 宣告存储变量
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

# 宣告一个名为 user_counters_storage 的映射。 对于每个作为felt的“帐户”键，我们存储一个也是felt的值。
@storage_var
func user_counters_storage(account : felt) -> (user_counters_storage : felt):
end

#
# 宣告 getters
# 公共变量应明确地用 getter 宣告
#

# 为我们的映射宣告一个 getter。 它将一个argument作为参数，即您希望读取计数器的值的帐户
@view
func user_counters{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (user_counter : felt):
    let (user_counter) = user_counters_storage.read(account)
    return (user_counter)
end

#
# 建构函数
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _tderc20_address : felt, _players_registry : felt, _workshop_id : felt, _exercise_id : felt
):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id)
    return ()
end

#
# 外部函数
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # 检查用户的计数器的值是否等于 7
    let (current_counter_value) = user_counters_storage.read(sender_address)
    assert current_counter_value = 7

    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

@external
func reset_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # 重新初始化用户的计数器的值
    user_counters_storage.write(sender_address, 0)
    return ()
end

@external
func increment_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # 从存储中读取计数器的值
    let (current_counter_value) = user_counters_storage.read(sender_address)
    # 将更新的值写入存储
    user_counters_storage.write(sender_address, current_counter_value + 2)
    return ()
end

@external
func decrement_counter{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # 从存储中读取计数器的值
    let (current_counter_value) = user_counters_storage.read(sender_address)
    # 将更新的值写入存储
    user_counters_storage.write(sender_address, current_counter_value - 1)
    return ()
end
