//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace{

    address payable public immutable feeAddress;
    uint8 public immutable feePercent;
    uint256 public totalFee;
    uint256 public itemCount;

    struct Item{
        uint256 itemId;
        IERC721 nft;
        uint32 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    mapping(uint256 => Item) items;

    event MarketplaceListed(
        uint256 itemId,
        address indexed nft,
        uint32 tokenId,
        uint256 price,
        address indexed seller
    );

    event MarketplaceNFTBought(
        uint256 itemId,
        address indexed nft,
        uint32 tokenId,
        uint256 price,
        uint256 fee,
        address indexed seller,
        address indexed buyer
    );

    modifier onlyAuth() {
        require(msg.sender == feeAddress, "You can't withdraw");
        _;
    }

    constructor(address _feeAddress, uint8 _feePercent){
        feeAddress = payable(_feeAddress);
        feePercent = _feePercent;
    }

    function makeItem(IERC721 _nft, uint32 _tokenId, uint256 _price) external{
        require(_price >=0, "Price must be greater than zero");
        
        itemCount++;


        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        _nft.transferFrom(msg.sender, address(this), _tokenId);

        emit MarketplaceListed(
            itemCount,
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );
    }

    function purchaseItem(uint256 _itemId) external payable{
        require(_itemId > 0 && _itemId <= itemCount, "Item doesn't exist");
        Item storage item = items[_itemId];
        require(msg.value >= item.price, "not enough ether");
        require(!item.sold, "Item already sold");

        uint256 itemFee = getFee(_itemId);
        uint256 priceToPay = item.price - itemFee;
        totalFee += itemFee; 

        item.sold = true;

        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        item.seller.transfer(priceToPay);
        (bool success, ) = item.seller.call{value: priceToPay}("");
        require(success, "Marketplace: Failed to transfer price");

        emit MarketplaceNFTBought(
            itemCount,
            address(item.nft),
            item.tokenId,
            priceToPay,
            itemFee,
            item.seller,
            msg.sender
        );
    }

    function withdraw() external onlyAuth {
        require(totalFee > 0, "No balance");

        (bool success, ) = feeAddress.call{value: totalFee}("");
        require(success, "Marketplace: Failed to withdraw fees");
    }
    
    function getFee(uint256 _itemId) view public returns(uint256){
        return ((items[_itemId].price * feePercent) / 100);
    }
}