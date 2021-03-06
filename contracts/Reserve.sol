pragma solidity ^0.4.24;

import './MultiVotes.sol';
import 'zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract Reserve is MultiVotes, PausableToken {
  using SafeMath for uint256;

  event Withdraw(address indexed to, uint256 amount);

  struct vote {
    address _address;
    uint256 _amount;
  }

  mapping(address => vote) private votes;

  uint256 private initial_reserve_amount;
  uint256 private total_withdrawed;
  uint256 private deployment_date;
  uint256 private distribution_duration;
  uint256 private votes_required;
  uint256 internal reserve_amount;

  constructor(uint256 _reserve_amount, uint256 _votes_required,
              uint256 _distribution_duration) public {
    initial_reserve_amount = _reserve_amount;
    total_withdrawed = 0;
    deployment_date = now;
    reserve_amount = _reserve_amount;
    votes_required = _votes_required;
    distribution_duration = _distribution_duration;
  }

  function reserveBalance() public view returns (uint256 balance) {
    return reserve_amount;
  }

  function withdraw(address _address, uint256 _amount) cantChangeVoters isVoter(msg.sender) public returns (bool) {
    uint256 vote_count = 0;
    votes[msg.sender] = vote({_address: _address, _amount: _amount});
    for (uint256 i = 0; i < voters.length; i++) {
      if(votes[voters[i]]._address == _address && votes[voters[i]]._amount == _amount) {
        vote_count = vote_count + 1;
        if(vote_count == votes_required) {
          require(now > deployment_date.add(distribution_duration) ||
                  _amount <= initial_reserve_amount.mul(now.sub(deployment_date)).div(distribution_duration).sub(total_withdrawed));
          total_withdrawed = total_withdrawed.add(_amount);
          reserve_amount = reserve_amount.sub(_amount);
          totalSupply_ = totalSupply_.add(_amount);
          balances[_address] = balances[_address].add(_amount);
          emit Withdraw(_address, _amount);
          emit Transfer(address(0), _address, _amount);
          return true;
        }
      }
    }
    return false;
  }

}
