// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Roles.sol";
import "./HitchensUnorderedKeySet.sol";

contract ChamaGroup {
    using Roles for Roles.Role;
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    struct Member {
        address memberAddress;
        string role;
    }

    struct Group {
        uint id;
        string name;
        address creator;
        Member[] members;
        mapping(address => string) roles;
        mapping(address => Roles.Role) memberRoles;
    }

    uint public groupCount = 0;
    mapping(uint => Group) public groups;
    mapping(address => HitchensUnorderedKeySetLib.Set) private userGroups;

    event GroupCreated(uint groupId, string groupName, address creator);
    event MemberAdded(uint groupId, address memberAddress, string role);

    modifier onlyCreator(uint groupId) {
        require(groups[groupId].creator == msg.sender, "Only the group creator can perform this action");
        _;
    }

    constructor() {
        // Initial setup can be done here if needed
    }

    function createGroup(string memory _name) public {
        groupCount++;
        Group storage newGroup = groups[groupCount];
        newGroup.id = groupCount;
        newGroup.name = _name;
        newGroup.creator = msg.sender;

        // Add the creator as the first member with the role "creator"
        newGroup.members.push(Member(msg.sender, "creator"));
        newGroup.roles[msg.sender] = "creator";
        newGroup.memberRoles[msg.sender].add(msg.sender);
        userGroups[msg.sender].insert(bytes32(groupCount));

        emit GroupCreated(groupCount, _name, msg.sender);
    }

    function addMember(uint groupId, address _memberAddress, string memory _role) public onlyCreator(groupId) {
        Group storage group = groups[groupId];
        group.members.push(Member(_memberAddress, _role));
        group.roles[_memberAddress] = _role;
        group.memberRoles[_memberAddress].add(_memberAddress);
        userGroups[_memberAddress].insert(bytes32(groupId));

        emit MemberAdded(groupId, _memberAddress, _role);
    }

    function getGroup(uint groupId) public view returns (uint, string memory, address, Member[] memory) {
        Group storage group = groups[groupId];
        return (group.id, group.name, group.creator, group.members);
    }

    function getUserGroups(address _user) public view returns (uint[] memory) {
        uint count = userGroups[_user].count();
        uint[] memory groupIds = new uint[](count);
        for (uint i = 0; i < count; i++) {
            groupIds[i] = uint(userGroups[_user].keyAtIndex(i));
        }
        return groupIds;
    }

    function isMemberInGroup(uint groupId, address _user) public view returns (bool) {
        return userGroups[_user].exists(bytes32(groupId));
    }
}
