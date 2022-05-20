# ######## Ex 04
# 读取映射
# 在这个练习中，您需要：
# - 使用函数读取变量
# - 使用函数读取映射中的值，其中您读取的slot是第一次调用的值
# - 使用函数显示您知道映射中值的正确值
# - 由合约记入您的积分

%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero
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
func values_mapped_storage(slot : felt) -> (values_mapped_storage : felt):
end

@storage_var
func was_initialized() -> (was_initialized : felt):
end

@storage_var
func next_slot() -> (next_slot : felt):
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

@view
func values_mapped{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    slot : felt
) -> (value : felt):
    let (value) = values_mapped_storage.read(slot)
    return (value)
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
    # 检查用户是否获得了分配的slot
    let (user_slot) = user_slots_storage.read(sender_address)
    assert_not_zero(user_slot)

    # 检查用户提供的值是否是我们期望的值
    # 皮一下！
    let (value) = values_mapped_storage.read(user_slot)
    assert value = expected_value + 32

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
    let (next_value) = values_mapped_storage.read(next_slot_temp + 1)
    if next_value == 0:
        user_slots_storage.write(sender_address, 1)
        next_slot.write(0)
    else:
        user_slots_storage.write(sender_address, next_slot_temp + 1)
        next_slot.write(next_slot_temp + 1)
    end
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

    # 在存储中存储通过的值
    set_a_random_value(values_len, values)

    # 标记值存储已初始化
    was_initialized.write(1)
    return ()
end

func set_a_random_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    values_len : felt, values : felt*
):
    if values_len == 0:
        # 以 sum=0 开始
        return ()
    end

    set_a_random_value(values_len=values_len - 1, values=values + 1)
    values_mapped_storage.write(values_len - 1, [values])

    return ()
end
