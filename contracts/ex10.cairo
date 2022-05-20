# ######## Ex 10
# # Composability可组合性
# 在这个练习中，您需要：
# - 使用此合约检索合约 ex10b.cairo 的地址，该合约持有此练习的密钥
# - 在 ex10b.cairo 中找到密钥
# - 在这个练习中使用秘密值呼叫 claim_points()函数
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

from contracts.utils.Iex10b import Iex10b

#
# 宣告存储变量
# 默认情况下，存储变量通过 ABI 是不可见的。 它们类似于 Solidity 中的“private”变量
#

@storage_var
func ex10b_address_storage() -> (ex10b_address_storage : felt):
end

#
# 唯读函数
#
@view
func ex10b_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    ex10b_address : felt
):
    let (ex10b_address) = ex10b_address_storage.read()
    return (ex10b_address)
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
    secret_value_i_guess : felt, next_secret_value_i_chose : felt
):
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()

    # 通过 读取 拿到秘密值
    let (ex10b_address) = ex10b_address_storage.read()
    let (secret_value) = Iex10b.secret_value(contract_address=ex10b_address)
    assert secret_value = secret_value_i_guess

    # 为合约 10b 选择下一个 secret_value。 不要0！
    assert_not_zero(next_secret_value_i_chose)
    Iex10b.change_secret_value(
        contract_address=ex10b_address, new_secret_value=next_secret_value_i_chose
    )

    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end

##
# # 临时功能，一旦帐户合同生效并可与Nile使用，将被删除
##
##
@storage_var
func setup_is_finished() -> (setup_is_finished : felt):
end

@external
func set_ex_10b_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ex10b_address : felt
):
    let (permission) = setup_is_finished.read()
    assert permission = 0
    ex10b_address_storage.write(ex10b_address)
    setup_is_finished.write(1)
    return ()
end
