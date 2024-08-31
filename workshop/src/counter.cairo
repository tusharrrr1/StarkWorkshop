// counter contract
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState) -> u32;
}

#[starknet::contract]
pub mod Counter {
    #[storage]
    struct Storage {
        counter: u32
    }

    #[constructor]
    fn constructor(ref self: ContractState, _counter: u32) {
        self.counter.write(_counter);
    }

    #[abi(embed_v0)]
    impl counter_contract of super::ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32 {
            return self.counter.read();
        }
    }
}