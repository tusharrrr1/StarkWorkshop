// counter contract
#[starknet::contract]
pub mod counter_contract {
    #[storage]
    struct Storage {
        counter: u32
    }

    fn constructor(ref self: ContractState, _counter: u32) {
        self.counter.write(_counter);
    }
}