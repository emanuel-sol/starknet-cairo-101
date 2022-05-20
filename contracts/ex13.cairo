# ######## Ex 13
# 隐私
# “零知识”这个用词可能会令人困惑。 开发者倾向于假设 Zk Rollups 上的活动是私有/不公开的。
# 但其实不是。 它们可以是不公开的; 但默认情况下它们不是私密的。
# 在本练习中，您需要：
# - 使用发送到合约的交易中的过去数据，来查找应该是“秘密”的值

%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address

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

@storage_var
func user_slots_storage(account : felt) -> (user_slots_storage : felt):
end

@storage_var
func values_mapped_secret_storage(slot : felt) -> (values_mapped_secret_storage : felt):
end

@storage_var
func was_initialized() -> (was_initialized : felt):
end

@storage_var
func next_slot() -> (next_slot : felt):
end

@event
func assign_user_slot_called(account : felt, rank : felt):
end

#
# 宣告 getters
# 公共变量应明确地用 getter 宣告
#

@view
func user_slots{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (user_slot : felt):
    let (user_slot) = user_slots_storage.read(account)
    return (user_slot)
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
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    expected_value : felt
):
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # 检查用户之前是否验证过练习
    let (user_slot) = user_slots_storage.read(sender_address)
    assert_not_zero(user_slot)

    # 检查用户提供的值是否是我们期望的值
    let (value) = values_mapped_secret_storage.read(user_slot)
    assert value = expected_value

    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

@external
func assign_user_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    let (next_slot_temp) = next_slot.read()
    let (next_value) = values_mapped_secret_storage.read(next_slot_temp + 1)
    if next_value == 0:
        user_slots_storage.write(sender_address, 1)
        next_slot.write(0)
    else:
        user_slots_storage.write(sender_address, next_slot_temp + 1)
        next_slot.write(next_slot_temp + 1)
    end
    let (user_slot) = user_slots_storage.read(sender_address)
    # 发出含有秘密值的event
    assign_user_slot_called.emit(sender_address, user_slot)
    return ()
end

#
# 外部函数 - 管理
# 只有管理员可以呼叫这些函数。 您无需了解它们即可完成练习。
#

@external
func set_random_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    values_len : felt, values : felt*
):
    # 检查随机值是否已经初始化
    let (was_initialized_read) = was_initialized.read()
    assert was_initialized_read = 0

    # 将通过的值存储在 store 中

    set_a_random_value(values_len, values)

    # 标记值存储已初始化
    was_initialized.write(1)
    return ()
end

func set_a_random_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    values_len : felt, values : felt*
):
    if values_len == 0:
        # 以 sum=0 开头
        return ()
    end

    set_a_random_value(values_len=values_len - 1, values=values + 1)
    values_mapped_secret_storage.write(values_len - 1, [values])

    return ()
end
