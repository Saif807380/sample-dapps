// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SocialDapp {

  address Admin;

  struct notarizedImage {
    string imageURL;
    uint timeStamp;
  }

  struct User {
    string handle;
    bytes32 city;
    bytes32 state;
    bytes32 country;
    bytes32[] myImages;
  }

  mapping ( bytes32 => notarizedImage) notarizedImages; // this allows to look up notarizedImages by their SHA256notaryHash
  bytes32[] imagesByNotaryHash; // this is like a whitepages of all images, by SHA256notaryHash

  mapping ( address => User ) Users;   // this allows to look up Users by their ethereum address
  address[] usersByAddress;  // this is like a whitepages of all users, by ethereum address

  function registerNewUser(string memory handle, bytes32 city, bytes32 state, bytes32 country) public returns (bool success) {
    address thisNewAddress = msg.sender;
    // don't overwrite existing entries, and make sure handle isn't null
    if(bytes(Users[msg.sender].handle).length == 0 && bytes(handle).length != 0){
      Users[thisNewAddress].handle = handle;
      Users[thisNewAddress].city = city;
      Users[thisNewAddress].state = state;
      Users[thisNewAddress].country = country;
      usersByAddress.push(thisNewAddress);  // adds an entry for this user to the user 'whitepages'
      return true;
    } else {
      return false; // either handle was null, or a user with this handle already existed
    }
  }

  function addImageToUser(string memory imageURL, bytes32 SHA256notaryHash) public returns (bool success) {
    address thisNewAddress = msg.sender;
    if(bytes(Users[thisNewAddress].handle).length != 0) {
      if(bytes(imageURL).length != 0) {
        // prevent users from fighting over sha->image listings in the whitepages, but still allow them to add a personal ref to any sha
        if(bytes(notarizedImages[SHA256notaryHash].imageURL).length == 0) {
          imagesByNotaryHash.push(SHA256notaryHash); // adds entry for this image to our image whitepages
        }
        notarizedImages[SHA256notaryHash].imageURL = imageURL;
        notarizedImages[SHA256notaryHash].timeStamp = block.timestamp; // note that updating an image also updates the timestamp
        Users[thisNewAddress].myImages.push(SHA256notaryHash); // add the image hash to this users .myImages array
        return true;
      } else {
        return false; // imageURL was null, couldn't store image
      }
    } else {
      return false; // user didn't have an account yet, couldn't store image
    }
  }

  function getUsers() public view returns (address[] memory) { return usersByAddress; }

  function getUser(address userAddress) public view returns (string memory, bytes32, bytes32, bytes32, bytes32[] memory) {
    return (Users[userAddress].handle,Users[userAddress].city,Users[userAddress].state,Users[userAddress].country,Users[userAddress].myImages);
  }

  function getAllImages() public view returns (bytes32[] memory) { return imagesByNotaryHash; }

  function getUserImages(address userAddress) public view returns (bytes32[] memory) { return Users[userAddress].myImages; }

  function getImage(bytes32 SHA256notaryHash) public view returns (string memory,uint) {
    return (notarizedImages[SHA256notaryHash].imageURL,notarizedImages[SHA256notaryHash].timeStamp);
  }
}