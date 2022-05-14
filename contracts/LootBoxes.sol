// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract LootBoxes is Ownable {
    string[3] public items          = ["Dragon Sword", "Silver Sword", "Common Sword"];
    uint  [3] public probabilities  = [7000, 2100, 400, 400, 50, 50];
       
    // mapping (string => uint) private blockLastPurchase;
    address private _treasury;
    IERC20 TOKEN;
    IERC721 NFT;
    uint256 seed;
    uint256 constant INVERSE_BASIS_POINT = 10000;
    uint public price = 1;
    // Must be sorted by rarity
    enum Class {
        Common,
        Rare,
        Epic,
        Legendary,
        Divine,
        Hidden
    }
    struct Loot {
        uint gsm;
        uint[] nft;
    }

    uint256 constant NUM_CLASSES = 6;
    function setProbabilities(uint[] memory _value) external {
        probabilities = _value;
    }
    mapping(address => Loot) public earned;
    struct OptionSettings {
        // Number of items to send per open.
        // Set to 0 to disable this Option.
        uint256 maxQuantityPerOpen;
        // Probability in basis points (out of 10,000) of receiving each class (descending)
        uint16[NUM_CLASSES] classProbabilities;
        // Whether to enable `guarantees` below
        bool hasGuaranteedClasses;
        // Number of items you're guaranteed to get, for each class
        uint16[NUM_CLASSES] guarantees;
    }

    event Draws(string item, string screenName);

    event TreasuryUpdated(address previous, address updated);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        address _GSM
    ) ERC721(_name, _symbol) {
        GSM = IERC20(_GSM);
        setBaseURI(_initBaseURI);
        mint(0xcf9b1f007f246c1D86735941Aeb4eddBc8C0016F, 104);
    }
    

    function addItem(string memory itemName, uint8 probability ) public onlyOwner(){

    }

    function claim() external {
        TOKEN.transfer(msg.sender, earned[msg.sender].gsm);
        for(uint i = 0; i < earned[msg.sender].nft.length; i ++) {
            // NFT.tran
        }
    }

    function pickRandomItem() public view returns(string memory){
        require(TOKEN.balanceOf(msg.sender) >= price, "insufficient balance");
        TOKEN.transferFrom(msg.sender, address(this), price);

        uint16 value = uint16(_random().mod(INVERSE_BASIS_POINT));

        for (uint256 i = probabilities.length - 1; i > 0; i--) {
            uint16 probability = probabilities[i];
            if (value < probability) {
                return Class(i);
            } else {
                value = value - probability;
            }
        }
        Loot tmp = Loot(gsm, nft);
        earned[msg.sender] = Loot;
        //
        return Class.Common;
    }
    
     /**
    * @dev Improve pseudorandom number generator by letting the owner set the seed manually,
    * making attacks more difficult
    * @param _newSeed The new seed to use for the next transaction
    */
    function setSeed(uint256 _newSeed) external onlyOwner {
        seed = _newSeed;
    }

    function setTreasury(address treasury_) external onlyOwner{
        emit TreasuryUpdated(_treasury, treasury_);
        _treasury = treasury_;
    }

    function withdraw() external onlyOwner {
      TOKEN.transfer(address(this).balance, treasury);
    }

    function _random() internal returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, seed)));
        seed = randomNumber;
        return randomNumber;
    }
}