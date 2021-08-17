// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SocialDapp.sol";

contract TestSocialDapp {
  SocialDapp sd = SocialDapp(DeployedAddresses.SocialDapp());
  address contractAddress = address(this);

  string handle = "user1";
  bytes32 city = "Mumbai";
  bytes32 state = "Maharashtra";
  bytes32 country = "India";
  string imageUrl = "https://www.trufflesuite.com/img/tutorials/pet-shop/ganache-migrated.png";
  bytes32 notaryHash = stringToBytes32("0x6c3e007e281f6948b37c511a11e43c8026d2a16a8a45fed4e83379b66b0ab927");

  function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(source, 32))
    }
  }

  function testRegisterNewUser() public {
    bool result = sd.registerNewUser(handle, city, state, country);
    Assert.equal(result, true, "New User should be created");
    result = sd.registerNewUser(handle, city, state, country);
    Assert.equal(result, false, "The User with this handle already exists");
    address registeredUser = sd.getUsers()[0];
    Assert.equal(registeredUser, contractAddress, "Addresses should match");
  }

  function testAddImageToUser() public {
    bool result = sd.addImageToUser(imageUrl, notaryHash);
    Assert.equal(result, true, "Image will be added to the user");
    string memory url;
    uint timestamp;
    (url, timestamp) = sd.getImage(notaryHash);
    Assert.equal(url, imageUrl, "Urls should match");
  }
}