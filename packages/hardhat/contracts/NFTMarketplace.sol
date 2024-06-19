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

    event ItemListed(uint256 indexed itemId, uint256 price, address seller);
    event ItemSold(uint256 indexed itemId, uint256 price, address buyer);

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
        require(msg.value >= _itemPrices[itemId], "Insufficient funds");
        
        address seller = _itemSellers[itemId];
        transferFrom(seller, msg.sender, itemId);
        _itemSellers[itemId] = address(0);
        _itemPrices[itemId] = 0;
        _itemsSold.increment();
        
        payable(seller).transfer(msg.value);
        emit ItemSold(itemId, msg.value, msg.sender);
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