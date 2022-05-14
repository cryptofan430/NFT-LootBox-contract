// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract LootBoxes is Ownable {

    string name;
    address private treasury = "0xa5E41Dd99960Dbb39497D1e06Fcc2F6A8508BAB1";
    uint[6] public probabilities  = [69, 16, 8, 4, 2, 1]; //need to be determined
    IERC20 TOKEN;
    IERC721[] NFT;
    uint256 seed;
    uint256 constant INVERSE_BASIS_POINT = 100;
    uint public price = 500;

    enum Class {
        token,
        NFT
    }

    struct Reward{
        Class class; // Whether token or NFT
        uint256 amount; //amount of token or NFT
    }

    //Personal info to be claim
    struct Loot{    
        uint256 token;
        uint256[] nft;
    }
    
    mapping(address => Loot) public earned;
    mapping(uint8 => Reward) public rewardList;

    event TreasuryUpdated(address previous, address updated);

    constructor( 
        string memory _name,
        address _token,
        address[] _NFT
        )
    {
        TOKEN = IERC20(_token);
        for(uint i = 0; i < _NFT.length; i ++) {
            NFT[i] = IERC721(_NFT[i]);
        }
        name = _name;
    }

    function claim() external {
        TOKEN.transfer(msg.sender, earned[msg.sender].token);
        for(uint i = 0; i < earned[msg.sender].nft.length; i ++) {
            NFT.safeTransferFrom(NFT.getOwner(), msg.sender, earned[msg.sender].nft[i]);
        }
    }

    function makeSpin() external view returns(uint){ //need to be changed return value
        require(TOKEN.balanceOf(msg.sender) >= price, "insufficient balance");
        TOKEN.transferFrom(msg.sender, address(this), price);
        uint8 item = getPickId();
        
        uint256 token;
        uint256 nft;
        uint32 uids;

        Reward reward = rewardList[item];
        if(reward.class == Class.NFT){
            uint256 totalSupply = NFT.totalSupply();
            for(uint i = 1; i <= reward.amount; i ++) {
                earned[msg.sender].nft.push(totalSupply + i);
            }   
        }
        else{
            earned[msg.sender].token += reward.amount;
        }
        // Loot tmp = Loot(gsm, nft);
        // earned[msg.sender] = Loot;
        
    }

    function getPickId() internal returns(uint){ 
        uint16 value = uint16(_random().mod(INVERSE_BASIS_POINT));

        for (uint256 i = probabilities.length - 1; i > 0; i--) {
            uint16 probability = probabilities[i];
            if (value < probability) {
                return i;
            } else {
                value = value - probability;
            }
        }
        return 0;
    }

    function setReward(uint256 id , bool class, uint256 amount) public onlyOwner{
        Reward tmp = Reward(class, amount);
        rewardList[id] = tmp;
    }

    function addItem(uint256 probability) public onlyOwner{
        probabilities.push(probability);
    }

    function removeItem(uint256 id) public onlyOwner{
        delete probabilities[id];
    }

    function setProbability(uint id, uint _value) external onlyOwner{
        probabilities[id] = _value;
    }
    
     /**
    * @dev Improve pseudorandom number generator by letting the owner set the seed manually,
    * making attacks more difficult
    * @param _newSeed The new seed to use for the next transaction
    */
    function setSeed(uint256 _newSeed) external onlyOwner {
        seed = _newSeed;
    }

    function setTreasury(address _treasury) external onlyOwner{
        emit TreasuryUpdated(treasury, _treasury);
        treasury = _treasury;
    }

    function setPrice(address _price) external onlyOwner{
        price = _price;
    }

    function withdraw() external onlyOwner{
      TOKEN.transfer(address(this).balance, treasury);
    }

    function _random() internal returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, seed)));
        seed = randomNumber;
        return randomNumber;
    }
}