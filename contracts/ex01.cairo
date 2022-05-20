# ######## Ex 01

# # 使用一个简单的公开合约函数

# 在这个练习中，您需要：
# --使用本合约的claim_points()函数
# --由合约记入您的积分

# # 您会学到什么
# --通用智能合约的语法
# --呼叫一个函数

# ######## 內建函式庫和输入
#
#

%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from contracts.utils.ex00_base import (
    tderc20_address,
    has_validated_exercise,
    distribute_points,
    validate_exercise,
    ex_initializer,
)

# ######## Constructor
# ######## 建构函数
# 部署合约时呼叫该函数
#
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    _tderc20_address : felt, _players_registry : felt, _workshop_id : felt, _exercise_id : felt
):
    ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id)
    return ()
end

# ######## External functions
# ######## 外部函数
# 这些函数可以被其他合约呼叫
#

# 这个函数是得分函数claim_points
# 它需要的输入是一个参数 (sender_address)，这是一个felt。在此处阅读有关felt的更多信息 https://www.cairo-lang.org/docs/hello_cairo/intro.html#field-element
# 它还包括隐含的参数（syscall_ptr：feel *、pedersen_ptr：HashBuiltin *、range_check_ptr）。在此处阅读有关隐含的参数的更多信息 https://www.cairo-lang.org/docs/how_cairo_works/builtins.html

@external
func claim_points{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 读取呼叫者您的地址
    let (sender_address) = get_caller_address()
    # 检查用户之前是否验证过练习

    validate_exercise(sender_address)
    # 发送分数给参数指定的地址
    distribute_points(sender_address, 2)
    return ()
end
