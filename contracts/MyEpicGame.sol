// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import "./libraries/Base64.sol";

// Our contract inherits from ERC721, which is the standard NFT contract!
contract MyEpicGame is ERC721 {

  // We'll hold our character's attributes in a struct. Feel free to add
  // whatever you'd like as an attribute! (ex. defense, crit chance, etc).
  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
    uint defenseMin;
    uint defenseMax;
  }

  // The tokenId is the NFTs unique identifier, it's just a number that goes
  // 0, 1, 2, 3, etc.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // A lil array to help us hold the default data for our characters.
  // This will be helpful when we mint new characters and need to know
  // things like their HP, AD, etc.
  CharacterAttributes[] defaultCharacters;

  // We create a mapping from the nft's tokenId => that NFTs attributes.
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
    uint defenseMax;
  }

  BigBoss public bigBoss;

  // A mapping from an address => the NFTs tokenId. Gives me an ez way
  // to store the owner of the NFT and reference it later.
  mapping(address => uint256) public nftHolders;

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackComplete(uint newBossHp, uint newPlayerHp);

  // Data passed in to the contract when it's first created initializing the characters.
  // We're going to actually pass these values in from from run.js.
  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    uint[] memory characterDefenseMin,
    uint[] memory characterDefenseMax,
    string memory bossName, // These variables will be passed in via run.js or deploy.js
    string memory bossImageURI,
    uint[] memory bossHp,
    uint[] memory bossAttackDamage,
    uint[] memory bossDefenseMax
  )

  // Below, you can also see I added some special identifier symbols for our NFT.
  // This is the name and symbol for our token, ex Ethereum and ETH. I just call mine
  // Heroes and HERO. Remember, an NFT is just a token!
  ERC721("All Time Heroes", "ATH")
  {
    // Initialize the big boss. Save it to the global "bigBoss" state variable.
    bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp[0],
      maxHp: bossHp[0],
      attackDamage: bossAttackDamage[0],
      defenseMax:bossDefenseMax[0]
    });

    console.log("Done initializing big boss %s with HP %s, max defense %s", bigBoss.name, bigBoss.hp, bigBoss.defenseMax);

    // Loop through all the characters, and save their values in our contract so
    // we can use them later when we mint our NFTs.
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i],
        defenseMin: characterDefenseMin[i],
        defenseMax: characterDefenseMax[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];

      console.log("Done initializing %s with HP %s, min defense %s", c.name, c.hp, c.defenseMin);
    }

    // I increment tokenIds here so that my first NFT has an ID of 1.
    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
    string memory strDefenseMin = Strings.toString(charAttributes.defenseMin);
    string memory strDefenseMax = Strings.toString(charAttributes.defenseMax);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            charAttributes.name,
            ' - NFT #',
            Strings.toString(_tokenId),
            '", "description": "This NFT lets you play in the All Time Heroes game.", "image": "ipfs://',
            charAttributes.imageURI,
            '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
            strAttackDamage,'}, { "trait_type": "Defense", "min_value":',strDefenseMin,', "max_value":',strDefenseMax,'} ]}'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
  }

  // Users would be able to hit this function and get their NFT based on the
  // characterId they send in!
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // We map the tokenId => their character attributes. More on this in
    // the lesson below.
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].hp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage,
      defenseMin: defaultCharacters[_characterIndex].defenseMin,
      defenseMax: defaultCharacters[_characterIndex].defenseMax
    });

    console.log("Minted NFT with tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();

    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  // Initializing the state variable for a random() function
  uint nonce = 0;

  // random() for generating a random defense value for characters within their min/max defense range
  function random(uint _min, uint _max) internal returns (uint) {
    uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % (_max - _min + 1);
    randomnumber = randomnumber + _min;
    nonce++;
    return randomnumber;
  }

  function attackBoss() public {
    // Get the state of the player's NFT
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    console.log("\nPlayer %s is about to attack. Has %s HP and %s ATT", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s ATT", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

    // Make sure the player has more than 0 HP
      require (
        player.hp > 0,
        "Error: character must have HP to attack boss."
      );

    // Make sure the boss has more than 0 HP
      require (
        bigBoss.hp > 0,
        "Error: boss must have HP to attack boss."
      );

    // Determine bigBoss defense for this attack (random # between 0 and defenseMax)
    uint bigBossDefense = random(0, bigBoss.defenseMax);
    uint playerAttack;
   
    // Determine player attack value considering bigBoss defence
    console.log("Player attack damage: %s", player.attackDamage);
    if (player.attackDamage < bigBossDefense) {
      playerAttack = 0;
    } else {
      playerAttack = player.attackDamage - bigBossDefense;
    }
    console.log("Boss defense for this attack: %s", bigBossDefense);
    console.log("Total player attack damage: %s", playerAttack);

    // Player attacks boss
    if (bigBoss.hp < playerAttack) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp = bigBoss.hp - playerAttack;
    }
    console.log("Player attacked Boss. New Boss hp: %s\n", bigBoss.hp);

    // Determine player defense for this attack (random # between defenseMin and defenseMax)
    uint playerDefense = random(player.defenseMin, player.defenseMax);
    uint bossAttack;
   
    // Determine player attack value considering bigBoss defence
    console.log("Boss attack damage: %s", bigBoss.attackDamage);
    if (bigBoss.attackDamage < playerDefense) {
      bossAttack = 0;
    } else {
      bossAttack = bigBoss.attackDamage - playerDefense;
    }
    console.log("Player defense for this attack: %s", playerDefense);
    console.log("Total Boss attack damage: %s", bossAttack);

    // Boss attacks player
    if (player.hp < bossAttack) {
      player.hp = 0;
    } else {
      player.hp = player.hp - bossAttack;
    }
    console.log("Boss attacked player. New player hp: %s\n", player.hp);

    emit AttackComplete(bigBoss.hp, player.hp);
  }

  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
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

  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
    return defaultCharacters;
  }

  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }
}
