// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
Hitchens UnorderedKeySet v1.0

Library for managing CRUD operations in dynamic key sets.

https://github.com/rob-Hitchens/UnorderedKeySet

Copyright (c), 2019, Rob Hitchens, the MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

THIS SOFTWARE IS NOT TESTED OR AUDITED. DO NOT USE FOR PRODUCTION.
*/

library HitchensUnorderedKeySetLib {

    struct Set {
        mapping(bytes32 => uint) keyPointers;
        bytes32[] keyList;
    }

    function insert(Set storage self, bytes32 key) internal {
        require(key != bytes32(0), "UnorderedKeySet(100) - Key cannot be 0x0");
        require(!exists(self, key), "UnorderedKeySet(101) - Key already exists in the set.");
        self.keyPointers[key] = self.keyList.length;
        self.keyList.push(key);
    }

    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "UnorderedKeySet(102) - Key does not exist in the set.");
        bytes32 keyToMove = self.keyList[self.keyList.length - 1];
        uint rowToReplace = self.keyPointers[key];
        self.keyPointers[keyToMove] = rowToReplace;
        self.keyList[rowToReplace] = keyToMove;
        delete self.keyPointers[key];
        self.keyList.pop();
    }

    function count(Set storage self) internal view returns(uint) {
        return self.keyList.length;
    }

    function exists(Set storage self, bytes32 key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    function keyAtIndex(Set storage self, uint index) internal view returns(bytes32) {
        require(index < self.keyList.length, "UnorderedKeySet(103) - Index out of bounds.");
        return self.keyList[index];
    }

    function nukeSet(Set storage self) internal {
        delete self.keyList;
    }
}

contract HitchensUnorderedKeySet {

    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    HitchensUnorderedKeySetLib.Set private set;

    event LogUpdate(address sender, string action, bytes32 key);

    function exists(bytes32 key) public view returns(bool) {
        return set.exists(key);
    }

    function insert(bytes32 key) public {
        set.insert(key);
        emit LogUpdate(msg.sender, "insert", key);
    }

    function remove(bytes32 key) public {
        set.remove(key);
        emit LogUpdate(msg.sender, "remove", key);
    }

    function count() public view returns(uint) {
        return set.count();
    }

    function keyAtIndex(uint index) public view returns(bytes32) {
        return set.keyAtIndex(index);
    }

    function nukeSet() public {
        set.nukeSet();
    }
}
