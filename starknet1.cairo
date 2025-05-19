#[starknet::interface]
trait IJoesContract<TContractState> {
    fn get_owner(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod JoesContract {
    use starknet::ContractAddress;
    
    #[storage]
    struct Storage {
        owner: felt252
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owner.write('Joe');
    }

    #[abi(embed_v0)]
    impl IJoesContractImpl of super::IJoesContract<ContractState> {
        fn get_owner(self: @ContractState) -> felt252 {
            self.owner.read()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{JoesContract, IJoesContractDispatcher, IJoesContractDispatcherTrait};
    use starknet::{ContractAddress, syscalls::deploy_syscall};
    use array::ArrayTrait;
    use box::BoxTrait;
    
    #[test]
    #[available_gas(2000000000)]
    fn test_contract_view() {
        let dispatcher = deploy_contract();
        let owner = dispatcher.get_owner();
        assert(owner == 'Joe', 'Joe should be the owner');
    }

    fn deploy_contract() -> IJoesContractDispatcher {
        let mut calldata = ArrayTrait::new();
        let (contract_address, _) = deploy_syscall(
            JoesContract::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            calldata.span(),
            false
        ).unwrap();
        
        IJoesContractDispatcher { contract_address }
    }
}