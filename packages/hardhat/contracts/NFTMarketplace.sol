// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    mapping(uint256 => uint256) private _itemPrices;
    mapping(uint256 => address) private _itemSellers;
    mapping(uint256 => address) private _itemBuyers;
    mapping(uint256 => bool) private _itemSold;
    mapping(uint256 => bool) private _itemReceived;
    
    event ItemListed(uint256 indexed itemId, uint256 price, address seller);
    event ItemSold(uint256 indexed itemId, uint256 price, address buyer);
    event ItemReceived(uint256 indexed itemId, address buyer);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function listNewItem(uint256 price) public {
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        _itemPrices[itemId] = price;
        _itemSellers[itemId] = msg.sender;
        _mint(msg.sender, itemId);
        emit ItemListed(itemId, price, msg.sender);
    }

    function buyItem(uint256 itemId) public payable {
        require(_exists(itemId), "Item does not exist");
        require(!_itemSold[itemId], "Item is already sold");
        require(msg.value >= _itemPrices[itemId], "Insufficient funds");
        
        address seller = _itemSellers[itemId];
        _itemBuyers[itemId] = msg.sender;
        _itemSold[itemId] = true;
        
        emit ItemSold(itemId, msg.value, msg.sender);
    }

    function confirmReceived(uint256 itemId) public {
        require(_exists(itemId), "Item does not exist");
        require(_itemSold[itemId], "Item is not sold");
        require(msg.sender == _itemBuyers[itemId], "Only the buyer can confirm receipt");
        
        _itemReceived[itemId] = true;
        address seller = _itemSellers[itemId];
        transferFrom(seller, _itemBuyers[itemId], itemId);
        
        emit ItemReceived(itemId, _itemBuyers[itemId]);
    }

    function getItemPrice(uint256 itemId) public view returns(uint256) {
        require(_exists(itemId), "Item does not exist");
        return _itemPrices[itemId];
    }

    function getSellerAddress(uint256 itemId) public view returns(address) {
        require(_exists(itemId), "Item does not exist");
        return _itemSellers[itemId];
    }

    function totalItems() public view returns(uint256) {
        return _itemIds.current();
    }

    function totalItemsSold() public view returns(uint256) {
        return _itemsSold.current();
    }
}