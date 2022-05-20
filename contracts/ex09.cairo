# ######## Ex 09
# # 递归 - 高级
# 在这个练习中，您需要：
# - 使用这个合约的 claim_points() 函数
# - 由合约记入您的积分

%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_le
from starkware.starknet.common.syscalls import get_caller_address
from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer,
)

#
# 唯读函数
#
@view
func get_sum{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    array_len : felt, array : felt*
) -> (array_sum : felt):
    let (array_sum) = get_sum_internal(array_len, array)
    return (array_sum)
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
# 呼叫此函数，指定地址将得2分
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    array_len : felt, array : felt*
):
    # 检查阵列的长度是否至少为 4
    assert_le(4, array_len)

    # 计算用户提供的阵列的总和
    let (array_sum) = get_sum_internal(array_len, array)

    # 总和应高于 50
    assert_le(50, array_sum)
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

#
# 内部函数
#
#

func get_sum_internal{range_check_ptr}(length : felt, array : felt*) -> (sum : felt):
    # 该函数用于递归计算阵列中所有值的总和
    # 递归，我们先遍历阵列
    # 一旦在数组的末尾（长度 = 0），我们开始求和
    if length == 0:
        # Start with sum=0.
        # 以 sum=0 开始
        return (sum=0)
    end

    # 如果长度不为零，则函数通过向前移动一个slot，再次调用自身
    let (current_sum) = get_sum_internal(length=length - 1, array=array + 1)

    # 在length=0时，首次调用这部分函数
    # 检查阵列 ([array]) 中的第一个值是否不为 0
    assert_not_zero([array])
    # 开始求和
    let sum = [array] + current_sum

    assert_le(current_sum * 2, sum)
    # 返回函数的目标是这个函数的主体
    return (sum)
end
