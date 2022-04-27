// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public _owner;
    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;


    constructor() {
        _name = "MyERC20Token";
        _symbol = "MET";
        _decimals = 8;
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Access denied, only owner");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return _balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(_balances[msg.sender] >= value, "value smaller than balance");

        _balances[msg.sender] = _balances[msg.sender] - value;
        _balances[to] = _balances[to] + value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(_balances[from] >= value, "not enough balance");
        require(_allowances[from][msg.sender] >= value, "not enough allowance");

        _balances[from] = _balances[from] - value;
        _balances[to] = _balances[to] + value;
        _allowances[from][msg.sender] = _allowances[from][msg.sender] - value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256 remaining) {
        return _allowances[owner][spender];
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _totalSupply = _totalSupply + amount;
        _balances[to] = _balances[to] + amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        require(_balances[from] >= amount, "amount lower than existent");

        _totalSupply = _totalSupply - amount;
        _balances[from] = _balances[from] - amount;
        emit Transfer(from, address(0), amount);
    }
}