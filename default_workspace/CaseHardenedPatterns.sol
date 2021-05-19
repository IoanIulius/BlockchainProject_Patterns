pragma solidity >=0.5.0 <0.6.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC721.sol";

contract CaseHardenedPatterns is Ownable, ERC721 {

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  event NewChp(uint chpId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;

  struct Chp {
    string name;
    uint dna;
  }

  Chp[] public chps;

  mapping (uint => address) public chpToOwner;
  mapping (address => uint) ownerChpCount;
  mapping (uint => address) chpApprovals;

  function _createChp(string memory _name, uint _dna) internal {
    uint id = chps.push(Chp(_name, _dna)) - 1;
    chpToOwner[id] = msg.sender;
    ownerChpCount[msg.sender] = ownerChpCount[msg.sender].add(1);
    emit NewChp(id, _name, _dna);
  }

  function createRandomChp(string memory _name) public {
    uint randDna = uint(keccak256(abi.encodePacked(_name)));
    _createChp(_name, randDna);
  }
  
  modifier onlyOwnerOf(uint _chpId) {
    require(msg.sender == chpToOwner[_chpId]);
    _;
  }
  
  function changeName(uint _chpId, string calldata _newName) external onlyOwnerOf(_chpId) {
    chps[_chpId].name = _newName;
  }
  
  function getChpsByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerChpCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < chps.length; i++) {
      if (chpToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerChpCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return chpToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerChpCount[_to] = ownerChpCount[_to].add(1);
    ownerChpCount[msg.sender] = ownerChpCount[msg.sender].sub(1);
    chpToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    require (chpToOwner[_tokenId] == msg.sender || chpApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
    chpApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }
  
}
