pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./fxs.sol";


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for `accounts`'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }


    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal virtual {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of `from`'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


contract FRAXStablecoin is ERC20 {
    using SafeMath for uint256;
    string public symbol;
    uint8 public decimals = 18;
    address[] public owners;
    uint256 ownerCount; //number of different addresses that hold FRAX
    mapping(address => uint256) public balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    address[] public collateral; // all collateral tokens accepted for 1t1 minting, USDT BUSD. for later use
    address[] public frax_pools; //an array of frax pool addresses for future use
    uint256 collatCount = 0;
    
    
    uint256 public collateral_ratio = 100000000;
   
    uint256 phase2_startTime; //epoch time of phase 2 start 
    uint256 last_hop_time; //epoch time of last FRAX expansion
    uint256 public FRAX_price;
    uint256 public FXS_price;
    address collateral_address; //this is the address of tether/whatever collateral is accepted
    address oracle_address; //this is the address that can change the FRAX and FXS price
    ERC20 _tether = ERC20(collateral_address); 
    //ERC20 _frax = ERC20(collateral_address); why don't i need to do this for the frax token itself but need to for tether
     
    
     
    modifier onlyWhileOpen() {
        require(collateral_ratio == 100000000, "frax not in 100% phase");
        _;
    }

    //the fraxhop function can only be poked during the fractional phase and only when: 1) FRAX price is above $1 OR 2) 175200 blocks from successful hop
    modifier onlyWhenTime() {
        require(collateral_ratio < 100000000 && (FRAX_price > 1 || block.timestamp - last_hop_time <= 2592000) , "not the right time for a frax hop");
        _;
    }
    
    //only callable when FRAX supply needs to retract, when the price is below $1
    modifier onlyWhenRetraction() {
        require(FRAX_price < 1, "no retraction in supply necessary");
        _;
    }
    
    modifier onlyByOracle() {
        require(msg.sender == oracle_address, "you're not the oracle :p");
        _;
    }
    
    constructor(
    string memory _symbol, 
    address _collateral_address,
    address _oracle_address) 
    public 
    {
    symbol = _symbol;
    oracle_address = _oracle_address;
    collateral_address = _collateral_address;
}

    //adds collateral addresses supported, such as tether and busd, must be ERC20 
    function setCollateral(address col_address) public onlyByOracle {
        collateral.push(col_address); //should there be redundancy checks?
    }

    //adds pool addresses supported, such as tether and busd, must be ERC20 
    function setFraxPools(address new_pool) public onlyByOracle {
        frax_pools.push(new_pool); //should there be redundancy checks?
    }

    //changes the  original collateral address 
    function setOGcollateral(address col_add) public onlyByOracle {
        collateral_address = col_add; //should there be redundancy checks?
    }

    // the updated price must be within 10% of the old price
    // this is to prevent accidental mispricings 
    // a change of greater than 10% requires multiple transactions
    //need to create this logic
    function setPrices(uint256 FRAX_p,uint256 FXS_p) public onlyByOracle {
        FRAX_price = FRAX_p;
        FXS_price = FXS_p;
    //should there be a return statement here? 
    }

    function setOracle(address new_oracle) public onlyByOracle {
        oracle_address = new_oracle;
    }

    function mintFrax1t1(uint256 collateral_amount) public onlyWhileOpen {
    //first we must check if the collateral_ratio is  at 100%, if it is not, 1t1 minting is not active
    
    //caller must allow the frax contract to move collateral to the frax contract so that frax can be
    _tether.transferFrom(tx.origin, address(this), collateral_amount); //moves collateral to contract
    _mint(tx.origin, collateral_amount); //then mints 1:1 to the caller and increases total supply 
    
    }
    
    
    
    
    function redeem1t1(uint256 frax_amount) public onlyWhileOpen {
        
        //collaer must allow contract to burn frax from their balance first
        _burn(tx.origin, frax_amount);

        //sends tether back to the frax holder 1t1 after burning the frax
       _tether.transfer(tx.origin, frax_amount); 
        
    }
    
    
    
address hopBidder;
uint256 hopBid;
address fxs_address;
FRAXShares FXS = FRAXShares(fxs_address); 


function fraxHop() public {
    require(block.timestamp - last_hop_time >= 3600);
    
    // send previous hop winner their FRAX
// send previous hop winner their FRAX
    if (hopBidder != address(0)) {
        transfer(hopBidder, balanceOf(address(this)));
        FXS.burn(hopBid);
        hopBidder = address(0);
        hopBid = 0;
}
    
    // Mint new FRAX
    if (collateral_ratio < 100000000 && FRAX_price > 1) {
        uint256 new_supply = totalSupply().div(10000);
        _mint(address(this), new_supply);
        last_hop_time = block.timestamp; //set the time of the last expansion
    }
}
    
    function bidExpand (uint256 fxs) public {
        require(fxs > hopBid, "bid is not greater than previous bid");
        
        // refund previous bidder
    if (hopBidder != address(0)) {
    FXS.transfer(hopBidder, hopBid);
        
    }
        
        // record new bidder
        hopBidder = msg.sender;
        FXS.transferFrom(msg.sender, address(this), fxs);
    }
    
    address backHopBidder;
    uint256 backHopBid;
    uint256 backHopAmount;
    uint256 last_back_hop_time;
    
    function fraxBackstep() public {
    require(block.timestamp - last_back_hop_time >= 3600);
    
    // send previous hop winner their FXS
    if (backHopBidder != address(0)) {
        FXS.mint(backHopBidder, backHopBid);
        backHopBidder = address(0);
        backHopBid = 0;
        backHopAmount = 0;
    }
    
    // Start contraction
    if (collateral_ratio > 100000000 && FRAX_price < 1) {
        backHopAmount = totalSupply().div(10000);
        last_back_hop_time = block.timestamp; //set the time of the last contraction
    }
}

function bidContract (uint256 fxs) public {
    require(backHopAmount > 0, "no back hop currently bidding");
    require(block.timestamp - last_back_hop_time >= 3600);
    require(backHopBidder == address(0) || fxs < backHopBid, "bid is not less than previous bid");
    
    // refund previous bidder
    if (backHopBidder != address(0))
        transfer(backHopBidder, backHopAmount);
    
    // record new bidder
    backHopBidder = msg.sender;
    backHopBid = fxs;
    
    // take FRAX from bidder
    transferFrom(msg.sender, address(this), backHopAmount);
}
    
    
    
}
