# ######## Ex 08
# # 递归 - 基础
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
# 宣告存储变量
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func user_values_storage(account : felt, slot : felt) -> (user_values_storage : felt):
end

#
# 宣告 getters
# 公共变量应明确地用 getter 宣告
#

@view
func user_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt, slot : felt
) -> (value : felt):
    let (value) = user_values_storage.read(account, slot)
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
# 呼叫此函数，指定地址将得2分
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()

    # 检查用户第10个slot的 user_values_storage 的值
    let (user_value_at_slot_ten) = user_values_storage.read(sender_address, 10)

    # 第10个slot的 user_values_storage 的值应该为 10
    assert user_value_at_slot_ten = 10

    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

# 该函数接收的参数为一个阵列
# 为了通过该练习，用户需要提供阵列和它的长度
# 操作被 voyager 抽象掉了，您只需要在voyager中给它一个阵列
@external
func set_user_values{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt, array_len : felt, array : felt*
):
    set_user_values_internal(account, array_len, array)
    return ()
end

#
# 内部函数
#
#

func set_user_values_internal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt, length : felt, array : felt*
):
    # 此函数用于递归地设置所有值
    # 递归，我们先遍历阵列
    # 一旦在阵列的末尾（长度 = 0），我们开始重新排列阵列
    if length == 0:
        # 从阵列末尾开始
        return ()
    end

    # 如果长度不为零，则函数通过向前移动一个slot，再次调用自身
    set_user_values_internal(account=account, length=length - 1, array=array + 1)

    # 在length=0时，首次调用这部分函数
    user_values_storage.write(account, length - 1, [array])
    return ()
end
