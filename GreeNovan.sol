// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    
    function add(uint a, uint b) internal pure returns (uint) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint a, uint b) internal pure returns (uint) {
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint a, uint b) internal pure returns (uint) {   
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
       

        return c;
    }
}
interface IERC20{
  function totalSupply()external view returns(uint256);

  function balanceOf(address account)external view returns(uint256);

  function transfer(address recipient,uint amount)external returns(bool);

  function allowance(address owner, address spender)external view returns(uint256);

  function approve(address spender,uint amount)external returns(bool);

  function transferFrom(address sender,address recipient,uint amount)external  returns(bool);

  event Transfer(address indexed from, address indexed to, uint value);


  event Approval(address indexed owner, address indexed spender, uint value);

}
contract GreenNova is IERC20 {
    using SafeMath for uint256;
    
    string public _name;                    //'GreenNova Token';
    string public _symbol;                  //'fire';
    uint256 public _totalSupply;            //100000
    uint256 public _decimals;               //18;
    
    address public admin;
    
    mapping(address => uint256) public _balanceOf;
    
    mapping(address => mapping(address => uint256)) public _allowance;
    
    constructor(
    string memory _Tname,
    string memory _Tsymbol,
    uint256 _TtotalSupply,
    uint256 _Tdecimals
) {
    require(_Tdecimals == 18, "Decimals must be 18");
    require(_TtotalSupply > 0, "Supply must be greater than zero");

    _name = _Tname;
    _symbol = _Tsymbol;
    _decimals = _Tdecimals;

    // Calculate total supply with 18 decimals
    _totalSupply = _TtotalSupply * (10 ** _Tdecimals);

    // Give all initial tokens to deployer
    _balanceOf[msg.sender] = _totalSupply;

    // Set admin
    admin = msg.sender;

    // Emit initial mint event
    emit Transfer(address(0), msg.sender, _totalSupply);
}
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint256) {
        return _decimals;
    }
    
    function totalSupply() override external view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) override external view returns (uint256) {
        return _balanceOf[account];
    }
    
    function transfer(address _to, uint256 _value) override public returns(bool success) {
        require(_to != address(0), "Invalid address");
        
        require(_value > 0, "Invalid amount");
        
        require(_balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    function approve(address _spender, uint256 _value) override public returns (bool success) {
        require(_spender != address(0), "Invalid address");
        
        require(_value > 0, "Invalid amount");
        
        require(_balanceOf[msg.sender] >= _value, "Owner doesn't have enough balance to approve");
        
        _allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    
    function allowance(address _owner, address _spender) override public view returns (uint256 remaining) {
        return _allowance[_owner][_spender];
    }
    
    function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
        require(_from != address(0), "Invalid address");
        
        require(_to != address(0), "Invalid address");
        
        require(_value > 0, "Invalid amount");
        
        require(_allowance[_from][msg.sender] >= _value, "You don't have the approval to spend this amount of tokens");
        
        require(_balanceOf[_from] >= _value, "From address doesn't have enough balance to transfer");
        
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    
    function mint(address to, uint256 value) public {
        require(msg.sender == admin, "Only creator of the contract can mint tokens");
        
        require(value > 0, "Invalid amount to mint");
        
        _totalSupply = _totalSupply.add(value);
        _balanceOf[to] = _balanceOf[to].add(value);
        
        emit Transfer(address(0), to, value);
    }
    
    function burn(address to, uint256 value) public {
        require(msg.sender == admin, "Only creator of the contract can burn tokens");
        
        require(value > 0, "Invalid amount to burn");
        
        require(_totalSupply > 0, "Total Supply should be greater than 0");
        
        require(value <= _totalSupply, "Value cannot be greater than total supply of tokens");
        
        require(_balanceOf[to] >= value, "Not enough balance to burn");
        
        _totalSupply = _totalSupply.sub(value);
        _balanceOf[to] = _balanceOf[to].sub(value);
        
        emit Transfer(to, address(0), value);
    }
}
