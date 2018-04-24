contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract StandardToken is Token {
    address public owner = 0x0;   // Gamer
    address public teamHoler= 0x0;  //Team
    uint256 public holdersBalance;
    uint public totalHolders;
    uint public timeToFreeze = 1;  // Freeze Team %
    mapping (address => bool) registeredHolders;
    mapping (uint => address) holders;

      function() external payable {
     if (msg.value > 0 && totalHolders > 0) {
            uint256 balance = msg.value;
            for (uint i = 1; i <= totalHolders; i++) {
                uint256 currentBalance = balances[holders[i]];
                if (currentBalance > 0) {
                    uint256 amount = balance * currentBalance / 100;
                    holders[i].transfer(amount);
                }
            }
        }
    }
 
     function insertShareholder(address _holder) internal returns (bool) {
        if (registeredHolders[_holder] == true) {

        } else {
            totalHolders += 1;
            holders[totalHolders] = _holder;
            registeredHolders[_holder] = true;
            return true;
        }
        return false;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if(msg.sender == owner && (balances[msg.sender] - _value) < 30){ //Permanent % value of Gamer
             { return false; }
        }
        if(msg.sender == teamHoler && timeToFreeze < now ){
             { return false; }
        }
            if (balances[msg.sender] >= _value && _value > 0 ) {
                balances[msg.sender] -= _value;
                balances[_to] += _value;
             if (msg.sender == owner && _to != owner) {
                 holdersBalance += _value;
             }

        if (msg.sender != owner && _to == owner) {
            holdersBalance -= _value;
        }

        if (owner == _to) {
            // sender is owner
        } else {
            insertShareholder(_to);
        }
                Transfer(msg.sender, _to, _value);
            return true;
        } 
        else
         { return false; }
    
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
   

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function balanceOf2(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    mapping (address => mapping(bool => address)) dllIndex;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}


contract erc20GS is StandardToken {
    
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'v';   
    

    function erc20GS(
        uint8 _decimalUnits 
        ) {
        balances[owner] = 80;               // Give the creator 
        balances[teamHoler] = 20; 
        totalSupply = 100;                        // Update total supply  initial tokens 100 =100%
        name = "Contract name";                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = "Tiker";                               // Set the symbol for display purposes
        insertShareholder(msg.sender);
    }


    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}
