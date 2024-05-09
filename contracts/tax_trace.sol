// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

error Owner_Authentication_failed(address payer);
error priority_is_Set_Already();

contract tax_trace{

    address owner;

    struct Departments {
        string p_first;
        string p_sec;
        string p_third;
        string p_fourth;
    }

    struct taxPayer {
        string Name;
        uint Age;
        uint Income;
        bool status;
    }
    
    struct eRupee {
        uint One;
        uint Five;
        uint Ten;
    }

    constructor () {
        owner = msg.sender;
    }

    event taxPayer_created(
        address indexed payer,
        bool status
    );

    event taxPaid(
        address indexed payer,
        bool status
    );

    event tokenCounted(
        address indexed payer,
        uint one,
        uint five,
        uint ten
    );

    modifier notPaidAlready(address payer) {
        if (taxPayersmap[payer].status == true) {
            revert("paid already");
        }
        else {
            _;
        }
    }

    modifier ownerAuth(address payer) {
        if (owner != payer) {
            revert Owner_Authentication_failed(payer);
        } else {
            _;
        }
    }

    modifier existAlready(address payer) {
        bool flag = false;
        for(uint i=0; i<payersArray.length; i++) {
            if (payersArray[i] == payer) {
                flag = true;
            } else {
                flag = false;
            }
        }
        if (flag) {
            revert("Payer Already exists");
        } else {
            _;
        }
    }

    modifier notExistAlready(address payer) {
        bool flag = false;
        for(uint i=0; i<payersArray.length; i++) {
            if (payersArray[i] == payer) {
                flag = true;
            }
        }
        if (!flag) {
            revert("Payer Does Not exist");
        } else {
            _;
        }
    }

    mapping (address => taxPayer) private taxPayersmap;
    mapping (address => uint256) private paidTaxPayersmap;
    address [] private paidTaxPayers;
    address[] private payersArray;
    mapping (address => eRupee) private tokenCountMap;
    uint [] private randomTokenArray;
    // mapping (address => Departments) private departmentCodes;
    // bool[4] private prioritiesSet; 

    function createTaxPayer(
        string memory name,
        uint age,
        uint income      //income in wei
    ) external existAlready(msg.sender) notPaidAlready(msg.sender) {
        
        taxPayer memory payer = taxPayer({
            Name: name, 
            Age: age, 
            Income: income * 1e18,
            status: false
        });
        
        taxPayersmap[msg.sender] = payer;
        payersArray.push(msg.sender);
        emit taxPayer_created(msg.sender,false);
    }

    function payTax(uint ones, uint fives, uint tens) external payable 
        notPaidAlready(msg.sender) 
        notExistAlready(msg.sender){

        taxPayer memory payer = taxPayersmap[msg.sender];
        eRupee memory tokenDivision;
        uint256 income = payer.Income;
        uint256 amount;
        
        if(0e18 < income && income <= 10e18) {
            amount = 1 * 1e18;
            require(msg.value == amount, "Payable amount is 1 Eth");
            require((ones * 1e18 + fives * 5e18 + tens * 10e18) == amount, "Check the token count");
            tokenDivision = eRupee({
                One: ones,
                Five: fives,
                Ten: tens
            });
            if (tokenDivision.One != 0) {randomTokenArray.push(tokenDivision.One * 1);}
            if (tokenDivision.Five != 0) {randomTokenArray.push(tokenDivision.Five * 5);}  
            if (tokenDivision.Ten != 0) {randomTokenArray.push(tokenDivision.Ten * 10);}

        }
        else if(10e18 < income && income <= 25e18) {
            amount = 5e18;
            require(msg.value == amount, "Payable amount is 5 Eth");
            require((ones * 1e18 + fives * 5e18 + tens * 10e18) == amount, "Check the token count");
            tokenDivision = eRupee({
                One: ones,
                Five: fives,
                Ten: tens
            });
            if (tokenDivision.One != 0) {randomTokenArray.push(tokenDivision.One * 1);}
            if (tokenDivision.Five != 0) {randomTokenArray.push(tokenDivision.Five * 5);}
            if (tokenDivision.Ten != 0) {randomTokenArray.push(tokenDivision.Ten * 10);}
            
        }
        else {
            amount = 10e18;
            require(msg.value == amount, "Payable amount is 10 Eth");
            require((ones * 1e18 + fives * 5e18 + tens * 10e18) == amount, "Check the token count");
            tokenDivision = eRupee({
                One: ones,
                Five: fives,
                Ten: tens
            });
            if (tokenDivision.One != 0) {randomTokenArray.push(tokenDivision.One * 1);}
            if (tokenDivision.Five != 0) {randomTokenArray.push(tokenDivision.Five * 5);} 
            if (tokenDivision.Ten != 0) {randomTokenArray.push(tokenDivision.Ten * 10);}
            
        }

        tokenCountMap[msg.sender] = tokenDivision;
        paidTaxPayersmap[msg.sender] += msg.value;
        taxPayersmap[msg.sender].status = true;
        paidTaxPayers.push(msg.sender);
        emit taxPaid(msg.sender, true);
        emit tokenCounted(msg.sender, ones, fives, tens);
    }

    function taxDistribution () ownerAuth(msg.sender) public view returns(uint [] memory ) {
        return randomTokenArray;
    }

    function showOwner() public view returns(address) {
        return owner;
    }

    function showPaidTaxPayers() public view returns(address[] memory ) {
        return paidTaxPayers;
    }

    function showDetails() notExistAlready(msg.sender) public view returns(taxPayer memory) {
        return taxPayersmap[msg.sender];
    }

    function showTokens() public view returns(eRupee memory) {
        return tokenCountMap[msg.sender];
    }

    function showTaxAmountPaid() public view returns(uint256) {
        return paidTaxPayersmap[msg.sender];
    }

    // function showPriorities() public view returns(Departments memory) {
    //     return departmentCodes[msg.sender];
    // }


}


