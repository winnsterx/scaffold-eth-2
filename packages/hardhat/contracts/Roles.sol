// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        return role.bearer[account];
    }
}

contract RoleBasedAccess {
    using Roles for Roles.Role;

    Roles.Role private admins;

    constructor() {
        // Add the deployer of the contract as an admin
        admins.add(msg.sender);
    }

    /**
     * @dev Check if an account is an admin
     */
    function isAdmin(address account) public view returns (bool) {
        return admins.has(account);
    }

    /**
     * @dev Add an admin
     */
    function addAdmin(address account) public {
        // Only an admin can add another admin
        require(isAdmin(msg.sender), "Only admins can add other admins");
        admins.add(account);
    }

    /**
     * @dev Remove an admin
     */
    function removeAdmin(address account) public {
        // Only an admin can remove another admin
        require(isAdmin(msg.sender), "Only admins can remove other admins");
        admins.remove(account);
    }
}
