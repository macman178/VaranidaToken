pragma solidity ^0.4.18;

import './libraries/ERC20/BasicToken.sol';
import './libraries/ownership/Ownable.sol';
import './libraries/math/SafeMath.sol';

contract Vesting is BasicToken, Ownable {
  using SafeMath for uint256;

  event Allocate(address indexed to, uint256 amount);

  struct grantState {
    uint256 totalAmount;
    uint256 totalDistributed;
  }

  mapping(address => grantState) private advisors_grants;
  mapping(address => grantState) private founders_grants;
  mapping(address => grantState) private technicals_grants;

  uint256 private advisors_amount_to_distribute;
  uint256 private founders_amount_to_distribute;
  uint256 private technicals_amount_to_distribute;
  uint256 private holders_amount_to_distribute;

  uint256 private advisors_cliff;
  uint256 private founders_cliff;
  uint256 private technicals_cliff;

  uint256 private advisors_duration;
  uint256 private founders_duration;
  uint256 private technicals_duration;

  function Vesting(uint256 _advisors_amount, uint256 _advisors_cliff, uint256 _advisors_duration,
                   uint256 _founders_amount, uint256 _founders_cliff, uint256 _founders_duration,
                   uint256 _technicals_amount, uint256 _technicals_cliff, uint256 _technicals_duration,
                   uint256 _holders_amount) public {
    uint256 ico_supply = _advisors_amount + _founders_amount + _technicals_amount + _holders_amount;
    totalSupply_ = totalSupply_.add(ico_supply);

    advisors_amount_to_distribute = _advisors_amount;
    advisors_cliff = now + _advisors_cliff;
    advisors_duration = _advisors_duration;

    founders_amount_to_distribute = _founders_amount;
    founders_cliff = now + _founders_cliff;
    founders_duration = _founders_duration;

    technicals_amount_to_distribute = _technicals_amount;
    technicals_cliff = now + _technicals_cliff;
    technicals_duration = _technicals_duration;

    holders_amount_to_distribute = _holders_amount;
  }

  function allocate(address _to, uint256 _amount, uint8 _type) public onlyOwner returns (bool success) {
    if (_type == 0) { // advisor
      require(_amount <= advisors_amount_to_distribute);
      advisors_amount_to_distribute = advisors_amount_to_distribute.sub(_amount);
      advisors_grants[_to] = grantState({totalAmount: _amount, totalDistributed: 0});
    } else if (_type == 1) { // founder
      require(_amount <= founders_amount_to_distribute);
      founders_amount_to_distribute = founders_amount_to_distribute.sub(_amount);
      founders_grants[_to] = grantState({totalAmount: _amount, totalDistributed: 0});
    } else if (_type == 2) { // technical
      require(_amount <= technicals_amount_to_distribute);
      technicals_amount_to_distribute = technicals_amount_to_distribute.sub(_amount);
      technicals_grants[_to] = grantState({totalAmount: _amount, totalDistributed: 0});
    } else { // holders
      require(_amount <= holders_amount_to_distribute);
      holders_amount_to_distribute = holders_amount_to_distribute.sub(_amount);
      balances[_to] = balances[_to].add(_amount);
      Transfer(address(0), _to, _amount);
    }
    Allocate(_to, _amount);
    return true;
  }

  function claimTokens(address _to, uint256 _amount, uint8 _type) public returns (bool success) {
    uint256 available_to_distribute = 0;
    uint256 cliff;
    uint256 duration;
    grantState storage grant;

    if (_type == 0) { // advisor
      cliff = advisors_cliff;
      duration = advisors_duration;
      grant = advisors_grants[_to];
    } else if (_type == 1) { // founder
      cliff = founders_cliff;
      duration = founders_duration;
      grant = founders_grants[_to];
    } else if (_type == 2) { // technical
      cliff = technicals_cliff;
      duration = technicals_duration;
      grant = technicals_grants[_to];
    } else { // holders
      revert();
    }

    if (now >= cliff.add(duration)) {
      available_to_distribute = grant.totalAmount.sub(grant.totalDistributed);
    } else if (now > cliff) {
      available_to_distribute = grant.totalAmount.mul(now.sub(cliff)).div(duration).sub(grant.totalDistributed);
    }

    require(_amount <= available_to_distribute);
    grant.totalDistributed = grant.totalDistributed.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

}
