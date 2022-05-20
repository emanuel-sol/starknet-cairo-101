# ######## Ex 02
# # 理解 asserts
# 在本练习中，您需要：
# - 使用此合约的 claim_points() 函数
# - 您的积分由合约记入

# # What you'll learn
# # 您将学习
# - 使用 asserts
# - 如何宣告存储变量
# - 如何读取存储变量
# - 如何创建getter函数
# Asserts是一个基本的构建块，允许您验证两个值是否相同。
# 它们类似于 Solidity 中的 require()
# 有关基本存储的更多信息 https://www.cairo-by-example.com/basics/storage

# ######## General directives and imports
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
# 这个变量是一个felt，被称为 my_secret_value_storage
# 在智能合约中，可以使用 my_secret_value_storage.read() 读取，或使用 my_secret_value_storage.write() 写入

@storage_var
func my_secret_value_storage() -> (my_secret_value_storage : felt):
end

#
# 宣告 getters
# 公共变量应明确地用 getter 宣告
#

@view
func my_secret_value{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    my_secret_value : felt
):
    let (my_secret_value) = my_secret_value_storage.read()
    return (my_secret_value)
end

# ######## 构造函数
# 部署合约时呼叫该函数
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _tderc20_address : felt,
    _players_registry : felt,
    _workshop_id : felt,
    _exercise_id : felt,
    my_secret_value : felt,
):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id)
    my_secret_value_storage.write(my_secret_value)
    return ()
end

# ######## 外部函数
# 这些函数可以被其他合约呼叫
#

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    my_value : felt
):
    # 读取呼叫者的地址
    let (sender_address) = get_caller_address()
    # 从存储中读取存储的值
    let (my_secret_value) = my_secret_value_storage.read()
    # 检查发送的值是否正确
    # assert 类似于在 Solidity 中使用“require”
    assert my_value = my_secret_value
    # 检查用户之前是否验证过练习
    validate_exercise(sender_address)
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end
