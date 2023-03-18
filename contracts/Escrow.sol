//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow {
    address public lender;
    address public inspector;
    address  payable public seller;
    address public nftAddress;

       modifier onlyBuyer(uint256 _nftID) {
        require(msg.sender == buyer[_nftID], "Only buyer can call this method");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }

    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;

    constructor(address _lender, address payable _seller , address _inspector,address _nftAddress){
        lender = _lender;
        seller= _seller;
        inspector = _inspector;
        nftAddress = _nftAddress;   
    }
    function list(uint256 _nftId, uint256 _purchasePrice,uint256 _escrowAmount,address _buyer) public payable onlySeller {
        IERC721(nftAddress).transferFrom(msg.sender,address(this), _nftId);
        isListed[_nftId] = true;
        purchasePrice[_nftId] = _purchasePrice;
        escrowAmount[_nftId] = _escrowAmount;
        buyer[_nftId] = _buyer;
    }
    function depositEarnest(uint256 _nftId)public payable onlyBuyer(_nftId){
        require(msg.value >= escrowAmount[_nftId]);
    }   

    receive() external payable {}
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }

    function updateInspectionStatus(uint256 _nftId, bool _passed) public onlyInspector{
        inspectionPassed[_nftId] = _passed;
    }    
    
    function approveSale(uint _nftId) public {
        approval[_nftId][msg.sender] = true;
    }
    // Flow of Finalize Sale Func
    //  1. Inspection status
    //  2. Sale Authorized
    //  3. Fund == Corect
    //  4. Sends NFT to Buyer
    //  5. Sends Funds to Seller
    function finalizeSale(uint256 _nftId) public {
        require(inspectionPassed[_nftId]);
        require(approval[_nftId][buyer[_nftId]]);        
        require(approval[_nftId][seller]);
        require(approval[_nftId][lender]);
        require(address(this).balance >= purchasePrice[_nftId]);
        (bool success, ) = payable(seller).call{value: address(this).balance}("");
        require(success);

        isListed[_nftId] = false;

        IERC721(nftAddress).transferFrom(address(this),buyer[_nftId], _nftId);

    }   
     function cancelSale(uint256 _nftID) public {
        if (inspectionPassed[_nftID] == false) {
            payable(buyer[_nftID]).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }
}
