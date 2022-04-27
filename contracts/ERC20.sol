// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
    @title ERC20 compliant token
    @author Nuno Leite
    @dev An implementation of a standard ERC20 token
 */
contract ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public _owner;
    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    /**
        @dev The constructor for this token
        @param initialAmount The initial amount of tokens in existence
        @param tName the name of the token
        @param tSymbol a symbol representative of the token
        @param decimalUnits the number of decimal units that is used for token division
     */
    constructor(uint256 initialAmount, string memory tName, string memory tSymbol, uint8 decimalUnits) {
        _name = tName;
        _symbol = tSymbol;
        _decimals = decimalUnits;
        _owner = msg.sender;
        _balances[msg.sender] = initialAmount;
        _totalSupply = initialAmount;
    }

    /**
        @dev Modifier that only allows the owner of the contract to perform an operation
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Access denied, only owner");
        _;
    }

    /**
        @dev Event that is triggered when a token transfer occurs
        @param from The address where the value was retrieved from
        @param to The address that received the value
        @param value The amount to be sent
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /**
        @dev Event that is triggered when an account approves an allowance for another account
        @param owner The address that contains the tokens being allowed
        @param spender The address of the account that is allowed to spend from owner
        @param value The amount of tokens spender is allowed to use
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
        @dev Get the name of the token
        @return name A string representing the name of the token
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
        @dev Get the symbol of the token
        @return symbol A string representing the symbol of the token
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
        @dev Get the number of decimal units used in this token
        @return decimals An uint8 representing the number of decimal units used
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
        @dev Get the total token supply
        @return totalSupply An uint256 representing the amount of tokens that exist
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
        @dev Get the balance of a certain account
        @param owner The address of the account that we wish to obtain the balance
        @return balance An uint256 representing the balance of the account provided
     */
    function balanceOf(address owner) public view returns (uint256 balance) {
        return _balances[owner];
    }

    /**
        @dev Transfer funds from the contract to another account
        @dev Emits a Transfer event
        @param to The address of the account that will receive the funds
        @param value The amount of tokens that will be transferred to the account
        @return success true if the operation succeeded, false otherwise
     */
    function transfer(address to, uint256 value) public returns (bool success) {
        require(_balances[msg.sender] >= value, "value higher than balance");

        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
        @dev Transfer funds from one account to another based on allowances (previous approvals)
        @dev Emits a Transfer event
        @param from The address of the account from which the funds will be withdrawn
        @param to The address of the account that will receive the funds
        @param value The amount of tokens that will be transferred
        @return success true if the operation succeeded, false otherwise
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(_balances[from] >= value, "not enough balance");
        require(_allowances[from][msg.sender] >= value, "not enough allowance");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    /**
        @dev Allows the transaction caller to approve an account to send funds for them, specifying the funds
        @dev Emits an Approval event
        @param spender The address of the account that will be able to transfer up to 'value' funds
        @param value The amount of tokens that 'spender' will be able to use in the name of the transaction caller
        @return success true if the operation succeeded, false otherwise
     */
    function approve(address spender, uint256 value) public returns (bool success) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
        @dev Get the allowance for a certain spender, relating to another account
        @param owner The address of the account in which to check the spender's allowance
        @param spender The address of the account to look up the amount of tokens it has of allowance
        @return remaining An uint256 representing the amount of token spender can use in the name of owner
     */
    function allowance(address owner, address spender) public view returns (uint256 remaining) {
        return _allowances[owner][spender];
    }

    /**
        @dev Creates new tokens for a certain account and adds them to the total supply
        @dev This method can only be called by the owner of the contract
        @dev Emits a Transfer event
        @param to The address of the account that will receive the tokens
        @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    /**
        @dev Removes tokens from a certain account and the total supply
        @dev This method can only be called by the owner of the contract
        @dev Emits a Transfer event
        @param from The address of the account from which the tokens will be removed
        @param amount The amount of tokens to burn
     */
    function burn(address from, uint256 amount) public onlyOwner {
        require(_balances[from] >= amount, "amount lower than existent");

        _totalSupply -= amount;
        _balances[from] -= amount;
        emit Transfer(from, address(0), amount);
    }
}