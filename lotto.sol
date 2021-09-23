//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LOTTO is ERC20 
{
    uint public LOTTERY_FEE;
    uint public counter;
    
    mapping(address => bool) public holders;
    mapping(uint => address) public indexes;
    uint public topindex;

    constructor(_lotteryTax) ERC20 ('Lotto','LOTTO') 
    {
        _mint(msg.sender, 10000000000000 * (10 ** 18));

        LOTTERY_FEE = _lotteryTax;
        counter = 0;

        holders[msg.sender] = true;
        indexes[topindex] = msg.sender;
        topindex += 1;
    }

    // Adds up the last 100 block hashes as source of rng
    function rng() public view returns (uint256) 
    {
        uint256 sum = 0;
        for(uint i = 1; i <= 100; i++)
        {
            sum += uint256(blockhash(block.number - i)) % topindex;
        }
        return sum;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool)
    {           
        uint lotteryAmount = (amount * LOTTERY_FEE) / 10000;
        _transfer(_msgSender(), address(this), lotteryAmount);
        _transfer(_msgSender(), recipient, amount - lotteryAmount);
         
        // Account for new holders       
        if (!holders[recipient]) 
        {
            holders[recipient] = true;
            indexes[topindex] = recipient;
            topindex += 1;
        }
        
        // Check if lottery should happen (10th transfer)    
        counter += 1;
        if (counter == 10) 
        {
            counter = 0;
            address payable winner = payable(indexes[rng() % topindex]);
            _transfer(address(this), winner, balanceOf(address(this)));
        }
          
        return true;
    }    
}