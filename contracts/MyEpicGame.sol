// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT standard to inheit from
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions from openzeppelin
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Helper function from hardhat to use console.log() in solidity
import "hardhat/console.sol";
import "./libraries/Base64.sol";

contract MyEpicGame is ERC721 {
    // event to check if the character has been minted
    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );

    // Event to check if the attack was complete or not
    event AttackComplete(
        address sender,
        uint256 newBossHp,
        uint256 newPlayerHp
    );
    // emits when a new character's attributes is added to the game
    event NewCharacter(
        uint256 characterIndex,
        string name,
        string imageURI,
        uint256 hp,
        uint256 maxHp,
        uint256 attackDamage
    );


    // specifying all the functions from library are attached to Counter type
    using Counters for Counters.Counter;

    // Counter to count the token id
    Counters.Counter private _tokenIds;

    // Counter for character index
    Counters.Counter private _characterId;

    // Limiter set to for number of characters created
    // This is not a limiter for minting a specific character
    uint charactersLimit;


    address owner;

    /*
    This is the struct that will represent the characters of our game characters
    characterIndex - represent the charater of the game
    name - represent the name of the character
    imageURI - image of the character
    hp - represent the horse power
    maxHp - represent the max power
    attack damage - represent the max attack damage
     */
    struct CharacterAttributes {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }
    // An array to store default data for characters of the game
    mapping(uint => CharacterAttributes) private defaultCharacters;

    // A mapping for a particular nft token id to its character attributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // mapping to from an address => to NFT token id
    // An easy way to store the owner of the nft
    mapping(address => uint256) public nftHolders;

    /* So, in our game our character NFT will be able to attack a boss
     The whole goal of the game is to attack the boss and bring its HP to 0!
     But, the catch is that the boss has a lot of HP and every time we hit the boss
     it will hit us back and bring our HP down. If our character's HP falls below 0,
     then our character will no longer be able to hit the boss and it'll be "dead"
     */

    /**
     The boss will basically have a name, an image, attack damage, and HP. 
     The boss will not be an NFT. The boss’s data will just live on our smart contract 
     */

    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    // a boss variable to hold the data of our the boss
    BigBoss public bigBoss;

    // initialises a boss for individual players
    mapping(uint => BigBoss) bossInstances;

    // Initializing the charaters of the game and boss during run time
    constructor(
        uint _charactersLimit,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    ) ERC721("End Game", "MCQ") {
        require(
            bytes(bossName).length > 0 &&
                bytes(bossImageURI).length > 0,
            "Invalid boss metadata"
        );
        require(bossHp > 0 && bossAttackDamage > 0,"Invalid boss combat's properties");
        charactersLimit = _charactersLimit;
        // Initialize the boss. Save it to our global "bigBoss" state variable.
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });
        owner = msg.sender;

        // i am increamenting the tokenid here so that my first nft has a token id of 1
        _tokenIds.increment();
    }
    // allows the game owner to add a new character's attributes to the game
    function addCharacter(string memory _name, string memory _imageURI, uint _hp, uint _attackDamage) public {
        require(charactersLimit >  _characterId.current(), "You can't add anymore characters");
        require(owner == msg.sender, "Unauthorized user");
        require(
            bytes(_name).length > 0 &&
            bytes(_imageURI).length > 0,
            "Invalid character metadata"
        );
        // ensures competitiveness is kept
        require(_hp > 0 && (bigBoss.maxHp / _hp) <= 3, "Hp has to be less than or equal to a third of the boss's hp");
        // ensures boss isn't unbeateable
        require(_attackDamage > 0 && (bigBoss.attackDamage / _attackDamage) <= 3, "Invalid character damage");
        uint id =  _characterId.current();
         _characterId.increment();
         defaultCharacters[id] = CharacterAttributes(_name, _imageURI, _hp, _hp, _attackDamage);
        emit  NewCharacter(id ,_name, _imageURI, _hp, _hp, _attackDamage);
    }
    // allows the game owner to increase the characters limit to add a new character to the game
    function increaseCharactersLimit(uint amount) public {
        require(owner == msg.sender, "Unauthorized user");
        require(_characterId.current() == charactersLimit, "You are only allowed to increase the charactersLimit after it has been reached");
        require(amount >  charactersLimit, "new amount has to be greater than the current charactersLimit");
        charactersLimit = amount;
    }


    // User will be able to hit this function and mint their nft
    // using the index because we want the user to choose which charater they want to mint
    function mintCharacterNFT(uint256 _characterIndex) external {
        // getting the current tokenid
        uint256 newItemId = _tokenIds.current();

        // minting the tokenid through safemint
        _safeMint(msg.sender, newItemId);

        // updating the mapping for tokenId=> attributes
        // As the palyers attack each other we need to change their hp according to the damage
        // therefore we need the data of all individual nft and we need a way to store this nft
        // or if we want to upgrade our character by giving it a sword
        nftHolderAttributes[newItemId] = CharacterAttributes({
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        bossInstances[newItemId] = bigBoss;

        // updating the mapping of address => NFT token id
        nftHolders[msg.sender] = newItemId;
        //Incrementing the token id for the next person to use it
        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    // function to convert my NFT data into json format
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        //fetching the information of our nftHolderAttributes mapping
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        // Converting all the characters to string using the helper function
        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        // encoding the meta data
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                " -- NFT # :",
                Strings.toString(_tokenId),
                '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',
                strHp,
                ', "max_value":',
                strMaxHp,
                '}, { "trait_type": "Attack Damage", "value": ',
                strAttackDamage,
                "} ]}"
            )
        );

        /*
        Basically, what we did was we formatted our JSON file and then encoded it in Base64. 
        So it turns the JSON file into this super long, encoded string that is readable by our 
        browser when we prepend it with data:application/json;base64,.
        */
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {
        // In attack function the player attacks the boss
        // In turn the player also get attacked by the boss

        // Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];

        // Getting the attributes of the player using storage because
        // on attacking we want to change our player hp
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        BigBoss storage boss = bossInstances[nftTokenIdOfPlayer];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            boss.name,
            boss.hp,
            boss.attackDamage
        );

        // makes sure the player has more than 0 hp
        require(player.hp > 0, "Error: character msut have hp to attack boss");

        // make sure the boss has more than 0 hp
        require(boss.hp > 0, "Error boss must have hp to attack characters");

        // We are doing this because we are using uint
        // Allow player to attack boss.
        if (boss.hp < player.attackDamage) {
            boss.hp = 0;
        } else {
            boss.hp = boss.hp - player.attackDamage;
        }

        // Allow boss to attack player.
        if (player.hp < boss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - boss.attackDamage;
        }

        emit AttackComplete(msg.sender, boss.hp, player.hp);
        // Console for ease.
        console.log("Player attacked boss. New boss hp: %s", boss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);
    }

    // This is the function to check if the user has any minted nft previously
    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        // If the user has a tokenId in the map, return their character.
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        }
        // Else, return an empty character.
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    // function to get all the available characters's attributes
    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        CharacterAttributes[] memory characters = new CharacterAttributes[](_characterId.current());
       for(uint i = 0; i < charactersLimit;i++){
            characters[i] = defaultCharacters[i];
       }

       return characters;
    }

    // function to return the boss
    function getBigBoss(uint tokenId) public view returns (BigBoss memory) {
        return bossInstances[tokenId];
    }
}
