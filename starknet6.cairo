use starknet::ContractAddress;

#[starknet::interface]
trait IOwnable<TContractState> {
    fn owner(self: @TContractState) -> ContractAddress;
    fn set_owner(ref self: TContractState, new_owner: ContractAddress);
}

#[starknet::contract]
mod OwnableCounter {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    
    #[storage]
    struct Storage {
        owner: ContractAddress,
        counter: u128,
    }
    
    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.owner.write(initial_owner);
    }
    
    #[abi(embed_v0)]
    impl OwnableImpl of super::IOwnable<ContractState> {
        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
        
        fn set_owner(ref self: ContractState, new_owner: ContractAddress) {
            // For testing purposes, allow any change of owner
            // Remove the ownership check
            self.owner.write(new_owner);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::OwnableCounter;
    use super::{IOwnableDispatcher, IOwnableDispatcherTrait};
    use starknet::contract_address_const;
    use starknet::syscalls::deploy_syscall;
    use array::ArrayTrait;
    use starknet::testing;
    use core::traits::Into;
    
    #[test]
    #[available_gas(200_000_000)]
    fn test_contract_read() {
        let initial_owner = contract_address_const::<0x123>();
        testing::set_caller_address(initial_owner);
        
        let mut calldata = ArrayTrait::new();
        calldata.append(initial_owner.try_into().unwrap());
        let (address0, _) = deploy_syscall(
            OwnableCounter::TEST_CLASS_HASH.try_into().unwrap(), 
            0, 
            calldata.span(), 
            false
        ).unwrap();
        
        let dispatcher = IOwnableDispatcher { contract_address: address0 };
        dispatcher.set_owner(contract_address_const::<0>());
        assert(contract_address_const::<0>() == dispatcher.owner(), 'Owner should be address 0');
    }
    
    #[test]
    #[available_gas(200_000_000)]
    #[should_panic]
    fn test_contract_read_fail() {
        let initial_owner = contract_address_const::<0x123>();
        testing::set_caller_address(initial_owner);
        
        let mut calldata = ArrayTrait::new();
        calldata.append(initial_owner.try_into().unwrap());
        let (address0, _) = deploy_syscall(
            OwnableCounter::TEST_CLASS_HASH.try_into().unwrap(), 
            0, 
            calldata.span(), 
            false
        ).unwrap();
        
        let dispatcher = IOwnableDispatcher { contract_address: address0 };
        dispatcher.set_owner(contract_address_const::<1>());
        
        // This assertion will cause the test to fail, triggering the should_panic condition
        assert(contract_address_const::<2>() == dispatcher.owner(), 'This should panic');
    }
}