pragma solidity 0.5.8;

import './ITRC20.sol';
import './Ownable.sol';
import './Pauseable.sol';
import "./SafeMath.sol";


contract ProcessPresaleBroker is Pauseable
{
	using SafeMath for uint256;
	using SafeMath for uint8;
	
	address payable _token;
	address payable _tokenOwner;
	uint256 private	_maxTokenAmount;
	uint256 private _minTokenAmount;
	uint256 private _rate;
	
	mapping(address => uint256) internal _swapped;  
	
	event Swapped(address, address, uint256, uint256);
	
	
	constructor() public {
	}
	
	
	/*
		@dev returns swapped trc20 token amount for specific account address
	*/
	
	function swappedTokenAmount() public view returns(uint256)
	{
		return _swapped[msg.sender];
	}
	
	
	/*
		@dev returns remaining trc20 token amount to buy
	*/
	
	function remainingTokenAmount() public view returns(uint256)
	{
		return _maxTokenAmount.sub(_swapped[msg.sender]);
	}
	
	
	/*
		@dev swap a payable function enables users to swap their TRX with trc20 token
	*/
	
	function swap() public payable stoppable returns(bool)
	{
		 uint256 amount = msg.value; 
		 amount = amount.mul(_rate);
		 amount = amount.mul(10 ** 12);
		 require(validateSwap(amount));
		 require(ITRC20(_token).transferFrom(_tokenOwner ,msg.sender, amount));
		 emit Swapped(msg.sender, address(this), msg.value, amount);
		 return true;
	}
	
	
	/*
		@dev enables token owner to register or modify information of token, max, min allowed token amount, and the rate.
	*/
	
	function registerInformation(address payable token, address payable tokenOwner ,uint256 minAmount, uint256 maxAmount, uint256 rate) public onlyOwner returns(bool)
	{
		_token = token;
		_tokenOwner = tokenOwner;
		_minTokenAmount = minAmount;
		_maxTokenAmount =  maxAmount; 
		_rate = rate;
		return true;
	}
	
	
	/*
		@dev validateSwap an internal functions validates users request to buy trc20 tokens according to the conditions defined by token owner.
	*/
	
	function validateSwap(uint256 trc20TokenAmount) internal returns(bool)
	{	
		uint256 amount = _swapped[msg.sender].add(trc20TokenAmount);
		require(trc20TokenAmount >= _minTokenAmount, 'less than minimum  allowed amount'); 
		require(amount <= _maxTokenAmount, 'greater than maximum  allowed amount');
		_swapped[msg.sender] = amount;
		return true;
	}
	
	/*
		@dev minCredit , returns minimum allowed token amount to swap
		this function is called via the dapp application to set limit on client side
	*/
	
	function minTokenAmount() external view returns(uint256)
	{
		return _minTokenAmount;
	}
	
	/*
		@dev manCredit , returns maximum allowed token amount to swap
		this function is called via the dapp application to set limit on client side
	*/
	
	function maxTokenAmount() external view returns(uint256)
	{
		return _maxTokenAmount; 
	}
	
	/*
		@dev rate , returns the token's rate relative to tron
		this function is used via dapp application to calculate the amount of payed tron 
		
	*/
	
	function tokenRate() external view returns(uint256)
	{
		return _rate;
	}
	
	/*
		@dev enables token owner to withdraw TRX 
	*/
	
	function widthdrawTrx() public onlyOwner returns(bool)
	{
		msg.sender.transfer(address(this).balance);
        return true;
	}
	
	function() external payable { }
}