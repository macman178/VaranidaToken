pragma solidity ^0.4.24;

import 'zeppelin-solidity/contracts/token/ERC20/BasicToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract Ico is BasicToken, Ownable {
  using SafeMath for uint256;

  event Allocate(address indexed to, uint256 amount);
  event Burn(address indexed from, uint256 amount);

  uint256 private ico_amount_to_distribute;

  constructor(uint256 _ico_amount) public {
    ico_amount_to_distribute = _ico_amount;
  }

  function allocateTokens(address _to, uint256 _amount) public onlyOwner returns (bool) {
    ico_amount_to_distribute = ico_amount_to_distribute.sub(_amount);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Allocate(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function burnUndistributedTokens() public onlyOwner returns (bool) {
    require(ico_amount_to_distribute > 0);
    ico_amount_to_distribute = 0;
    emit Burn(msg.sender, ico_amount_to_distribute);
    return true;
  }

}
